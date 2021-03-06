#' @include events_mats.R
#' @include events_miso.R
#' @include events_vastTools.R
#' @include events_suppa.R
NULL

#' Creates a template of alternative splicing junctions
#' 
#' @param nrow Integer: Number of rows
#' @param program Character: Program used to get the junctions
#' @param event.type Character: Event type of the respective events
#' @param chromosome Character: Chromosome of the junctions
#' @param strand Character: positive ("+") or negative ("-") strand of the event
#' @param id Character: events' ID
#' 
#' @return A data frame with the junctions coordinate names pre-filled with NAs
#' 
#' @examples
#' psichomics:::createJunctionsTemplate(nrow = 8)
createJunctionsTemplate <- function(nrow, program = character(0),
                                    event.type = character(0),
                                    chromosome = character(0),
                                    strand = character(0),
                                    id = character(0)) {
    ## TODO(NunoA): only accept a "+" or a "-" strand
    parsed <- as.data.frame(matrix(NA, nrow = nrow, ncol = 8),
                            stringsAsFactors = FALSE)
    names(parsed) <- c("C1.start", "C1.end",
                       "A1.start", "A1.end",
                       "A2.start", "A2.end",
                       "C2.start", "C2.end")
    
    if (length(program) > 0)    parsed[["Program"]] <- "MISO"
    if (length(event.type) > 0) parsed[["Event.type"]] <- event.type
    if (length(chromosome) > 0) parsed[["Chromosome"]] <- chromosome
    if (length(strand) > 0)     parsed[["Strand"]] <- strand
    if (length(id) > 0)         parsed[["Event.ID"]] <- id
    return(parsed)
}

#' Get MISO alternative splicing annotation
#' @importFrom utils read.delim
#' @return Retrieve annotation from MISO
getMisoAnnotation <- function() {
    types <- c("SE", "AFE", "ALE", "MXE", "A5SS", "A3SS", "RI", "TandemUTR")
    typesFile <- paste0("/genedata/Resources/Annotations/MISO/hg19/", types,
                        ".hg19.gff3")
    annot <- lapply(typesFile, read.delim, stringsAsFactors = FALSE,
                    comment.char="#", header=FALSE)
    
    ## TODO: ALE events are baldy formatted, they have two consecutive gene
    ## lines... remove them for now
    annot[[3]] <- annot[[3]][-c(49507, 49508), ]
    return(annot)
}

#' @rdname parseMatsAnnotation
#' @importFrom plyr rbind.fill
parseMisoAnnotation <- function(annot) {
    events <- lapply(annot, parseMisoEvent)
    events <- rbind.fill(events)
    return(events)
}

#' Get SUPPA alternative splicing annotation
#' @importFrom utils read.delim
#' @return Retrieve annotation from SUPPA
getSuppaAnnotation <- function() {
    types <- c("SE", "AF", "AL", "MX", "A5", "A3", "RI")
    typesFile <- paste0("~/Documents/psi_calculation/suppa/suppaEvents/hg19_", 
                        types, ".ioe")
    annot <- lapply(typesFile, read.delim, stringsAsFactors = FALSE,
                    comment.char="#", header=TRUE)
    return(annot)
}

#' @rdname parseMatsAnnotation
#' @importFrom plyr rbind.fill
parseSuppaAnnotation <- function(annot) {
    eventsID <- lapply(annot, "[[", "event_id")
    events <- lapply(eventsID, parseSuppaEvent)
    events <- rbind.fill(events)
    return(events)
}

#' Get MATS alternative splicing annotation
#' @importFrom utils read.delim
#' @return Retrieve annotation from MATS
getMatsAnnotation <- function() {
    types <- c("SE", "AFE", "ALE", "MXE", "A5SS", "A3SS", "RI")
    typesFile <- paste("~/Documents/psi_calculation/mats_out/ASEvents/fromGTF",
                       c(types, paste0("novelEvents.", types)), "txt",
                       sep = ".")
    names(typesFile) <- rep(types, 2)
    annot <- lapply(typesFile, read.delim, stringsAsFactors = FALSE,
                    comment.char="#", header=TRUE)
    return(annot)
}

#' Parse alternative splicing annotation
#' @param annot Data frame or matrix: alternative splicing annotation
#' @importFrom plyr rbind.fill
#' @return Parsed annotation
parseMatsAnnotation <- function(annot) {
    types <- names(annot)
    events <- lapply(seq_along(annot), function(i)
        if (nrow(annot[[i]]) > 0) 
            return(parseMatsEvent(annot[[i]], types[[i]])))
    events <- rbind.fill(events)
    
    # Sum 1 position to the start/end of MATS events (depending on the strand)
    matsNames <- names(events)
    plus <- events$Strand == "+"
    # Plus
    start <- matsNames[grep(".start", matsNames)]
    events[plus, start] <- events[plus, start] + 1
    # Minus
    end <- matsNames[grep(".end", matsNames)]
    events[!plus, end] <- events[!plus, end] + 1
    
    return(events)
}

#' Get VAST-TOOLS alternative splicing annotation
#' @importFrom utils read.delim
#' @return Retrieve annotation from VAST-TOOLS
getVastToolsAnnotation <- function() {
    types <- c("ALT3", "ALT5", "COMBI", "IR", "MERGE3m", "MIC",
               rep(c("EXSK", "MULTI"), 1))
    typesFile <- sprintf(
        "/genedata/Resources/Software/vast-tools/VASTDB/Hsa/TEMPLATES/Hsa.%s.Template%s.txt",
        types, c(rep("", 6), rep(".2", 2))#, rep(".2", 2))
    )
    names(typesFile) <- types
    
    annot <- lapply(typesFile, read.delim, stringsAsFactors = FALSE,
                    comment.char="#", header=TRUE)
    return(annot)
}

#' @rdname parseMatsAnnotation
#' @importFrom plyr rbind.fill
parseVastToolsAnnotation <- function(annot) {
    types <- names(annot)
    events <- lapply(seq_along(annot),
                     function(i) {
                         cat(types[i], fill=TRUE)
                         a <- annot[[i]]
                         if (nrow(a) > 0)
                             return(parseVastToolsEvent(a))
                     })
    events <- rbind.fill(events)
    events <- unique(events)
    return(events)
}

#' Returns the coordinates of interest for a given event type
#' @param type Character: alternative splicing event type
#' @return Coordinates of interest according to the alternative splicing event 
#' type
getSplicingEventCoordinates <- function(type) {
    switch(type,
           "SE"   = c("C1.end", "A1.start", "A1.end", "C2.start"),
           "A3SS" = c("C1.end", "C2.start", "A1.start"),
           "A5SS" = c("C1.end", "C2.start", "A1.end"),
           "AFE"  = c("C1.start", "C1.end", "A1.start", "A1.end"),
           "ALE"  = c("A1.start", "A1.end", "C2.start", "C2.end"),
           "RI"   = c("C1.start", "C1.end", "C2.start", "C2.end"),
           "MXE"  = c("C1.end", "A1.start", "A1.end",
                      "A2.start", "A2.end", "C2.start"), 
           "TandemUTR" = c("C1.start", "C1.end", "A1.end"))
}

#' Get the annotation for all event types
#' @return Parsed annotation
getParsedAnnotation <- function() {
    cat("Retrieving MISO annotation...", fill=TRUE)
    annot <- getMisoAnnotation()
    cat("Parsing MISO annotation...", fill=TRUE)
    miso <- parseMisoAnnotation(annot)
    
    cat("Retrieving SUPPA annotation...", fill=TRUE)
    annot <- getSuppaAnnotation()
    cat("Parsing SUPPA annotation...", fill=TRUE)
    suppa <- parseSuppaAnnotation(annot)
    
    cat("Retrieving VAST-TOOLS annotation...", fill=TRUE)
    annot <- getVastToolsAnnotation()
    cat("Parsing VAST-TOOLS annotation...", fill=TRUE)
    vast <- parseVastToolsAnnotation(annot)
    
    cat("Retrieving MATS annotation...", fill=TRUE)
    annot <- getMatsAnnotation()
    cat("Parsing MATS annotation...", fill=TRUE)
    mats <- parseMatsAnnotation(annot)
    
    events <- list(
        "miso" = miso, "mats" = mats, "vast-tools" = vast, "suppa" = suppa)
    
    # Remove the "chr" prefix from the chromosome field
    cat("Standarising chromosome field", fill=TRUE)
    for (each in seq_along(events)) {
        chr <- grepl("chr", events[[each]]$Chromosome)
        events[[each]]$Chromosome[chr] <-
            gsub("chr", "", events[[each]]$Chromosome[chr])
    }
    
    events <- rbind.fill(events)
    events <- dlply(events, .(Event.type))
    events <- lapply(events, dlply, .(Program))
    return(events)
}

#' Convert a column to numeric if possible and ignore given columns composed
#' of lists
#' 
#' @param table Data matrix: table
#' @param by Character: column names of interest
#' @param toNumeric Boolean: which columns to convert to numeric (FALSE by 
#' default)
#' 
#' @return Processed data matrix
#' @examples
#' event <- read.table(text = "ABC123 + 250 300 350
#'                             DEF456 - 900 800 700")
#' names(event) <- c("Event ID", "Strand", "C1.end", "A1.end", "A1.start")
#' 
#' # Let's change one column to character
#' event[ , "C1.end"] <- as.character(event[ , "C1.end"])
#' is.character(event[ , "C1.end"])
#' 
#' event <- psichomics:::getNumerics(event, by = c("Strand", "C1.end", "A1.end",
#'                                   "A1.start"),
#'                                   toNumeric = c(FALSE, TRUE, TRUE, TRUE))
#' # Let's check if the same column is now integer
#' is.numeric(event[ , "C1.end"])
getNumerics <- function(table, by = NULL, toNumeric = FALSE) {
    # Check which elements are lists of specified length
    bool <- TRUE
    for (each in by)
        bool <- bool & vapply(table[[each]], length, integer(1)) == 1
    
    table <- table[bool, ]
    # Convert elements to numeric
    conv <- by[toNumeric]
    table[conv] <- as.numeric(as.character(unlist(table[conv])))
    return(table)
}

#' Full outer join all given annotation based on select columns
#' @param annotation Data frame or matrix: alternative splicing annotation
#' @param types Character: alternative splicing types
#' @return List of annotation joined by alternative splicing event type
joinAnnotation <- function(annotation, types) {
    if (missing(types)) types <- names(annotation)
    joint <- lapply(types, function(type, annotation) {
        cat(type, fill=TRUE)
        # Create vector with comparable columns
        id <- c("Strand", "Chromosome", "Event.type")
        by <- c(id, getSplicingEventCoordinates(type))
        toNumeric <- !by %in% id
        
        # Convert given columns to numeric if possible
        tables <- lapply(annotation[[type]], getNumerics, by, toNumeric)
        
        # Make the names of non-comparable columns distinct
        cols <- lapply(names(tables), function(k) {
            ns <- names(tables[[k]])
            inBy <- ns %in% by
            ifelse(inBy, ns, paste(k, ns, sep="."))
        })
        
        # Full join all the tables
        res <- Reduce(function(x, y) dplyr::full_join(x, y, by), tables)
        names(res) <- unique(unlist(cols))
        
        # Remove equal rows
        return(unique(res))
    }, annotation)
    names(joint) <- types
    return(joint)
}

#' Write the annotation of an event type to a file
#' 
#' @param jointEvents List of lists of data frame
#' @param eventType Character: type of event
#' @param filename Character: path to the annotation file
#' @param showID Boolean: show the events' ID? FALSE by default
#' @param rds Boolean: write to a RDS file? TRUE by default; otherwise, write to
#' TXT
#' 
#' @importFrom utils write.table
#' 
#' @return Invisible TRUE if everything's okay
writeAnnotation <- function(jointEvents, eventType,
                            filename = paste0("data/annotation_",
                                              eventType, ".txt"),
                            showID = FALSE, rds = TRUE) {
    res <- jointEvents[[eventType]]
    # Show the columns Chromosome, Strand and coordinates of interest
    by <- c("Chromosome", "Strand", getSplicingEventCoordinates(eventType))
    ord <- 0
    
    # Show the events' ID if desired
    if (showID) {
        cols <- grep("Event.ID", names(res), value = TRUE)
        by <- c(cols, by)
        ord <- length(cols)
    }
    res <- subset(res, select = by)
    
    ## TODO(NunoA): clean this mess
    # Order by chromosome and coordinates
    orderBy <- lapply(c(1 + ord, (3 + ord):ncol(res)),
                      function(x) return(res[[x]]))
    res <- res[do.call(order, orderBy), ]
    
    res <- unique(res)
    
    if (rds)
        saveRDS(res, file = filename)
    else
        write.table(res, file = filename, quote = FALSE, row.names = FALSE, 
                    sep = "\t")
    return(invisible(TRUE))
}

#' Read the annotation of an event type from a file
#' 
#' @inheritParams writeAnnotation
#' @param rds Boolean: read from a RDS file? TRUE by default; otherwise, read
#' from table format
#' @importFrom utils read.table
#' 
#' @return Data frame with the annotation
readAnnotation <- function(eventType, filename, rds = TRUE) {
    if (missing(filename)) {
        filename <- file.path("data", paste0("annotation_", eventType))
        filename <- paste0(filename, ifelse(rds, ".RDS", ".txt"))
    }
    
    if (!file.exists(filename))
        stop("Missing file.")
    
    if (rds)
        read <- readRDS(filename)
    else 
        read <- read.table(filename, header = TRUE, stringsAsFactors = FALSE)
    return(read)
}

#' Compare the number of events from the different programs in a Venn diagram
#' 
#' @param join List of lists of data frame
#' @param eventType Character: type of event
#' 
#' @return Venn diagram
vennEvents <- function(join, eventType) {
    join <- join[[eventType]]
    
    programs <- join[grep("Program", names(join))]
    nas <- !is.na(programs)
    nas <- ifelse(nas, row(nas), NA)
    p <- lapply(1:ncol(nas), function(col) nas[!is.na(nas[ , col]), col])
    names(p) <- sapply(programs, function(x) unique(x[!is.na(x)]))
    gplots::venn(p)
}

#' String used to search for matches in a junction quantification file
#' @param chr Character: chromosome
#' @param strand Character: strand
#' @param junc5 Integer: 5' end junction
#' @param junc3 Integer: 3' end junction
#' 
#' @return Formatted character string
junctionString <- function(chr, strand, junc5, junc3) {
    plus <- strand == "+"
    first <- ifelse(plus, junc5, junc3)
    last <- ifelse(plus, junc3, junc5)
    res <- sprintf("chr%s:%s:%s,chr%s:%s:%s",
                   chr, first, strand, chr, last, strand)
    return(res)
}

#' Calculate inclusion levels using alternative splicing event annotation and
#' junction quantification for many samples
#' 
#' @param eventType Character: type of the alternative event to calculate
#' @param junctionQuant Data.frame: junction quantification with samples as
#' columns and junctions as rows
#' @param annotation Data.frame: alternative splicing annotation related to
#' event type
#' @param minReads Integer: minimum of total reads required to consider the
#' quantification as valid (10 by default)
#' 
#' @importFrom fastmatch fmatch
#' @return Matrix with inclusion levels
calculateInclusionLevels <- function(eventType, junctionQuant, annotation,
                                     minReads = 10) {
    chr <- annotation$Chromosome
    strand <- annotation$Strand
    
    if (eventType == "SE") {
        # Create searchable strings for junctions
        incAstr <- junctionString(chr, strand,
                                  annotation$C1.end, annotation$A1.start)
        incBstr <- junctionString(chr, strand,
                                  annotation$A1.end, annotation$C2.start)
        exclstr <- junctionString(chr, strand, 
                                  annotation$C1.end, annotation$C2.start)
        
        # Get specific junction quantification
        coords <- rownames(junctionQuant)
        incA <- junctionQuant[fmatch(incAstr, coords), ]
        incB <- junctionQuant[fmatch(incBstr, coords), ]
        excl <- junctionQuant[fmatch(exclstr, coords), ]
        rm(incAstr, incBstr, exclstr)
        
        # Calculate inclusion levels
        inc <- (incA + incB) / 2
        rm(incA, incB)
        
        tot <- excl + inc
        rm(excl)
        
        # Ignore PSI values when total reads are below the threshold
        less <- tot < minReads | is.na(tot)
        psi <- as.data.frame(matrix(ncol=ncol(tot), nrow=nrow(tot)))
        psi[!less] <- inc[!less]/tot[!less]
        colnames(psi) <- colnames(inc)
        rm(inc)
        
        rownames(psi) <- paste(eventType, chr, strand, annotation$C1.end, 
                               annotation$A1.start, annotation$A1.end,
                               annotation$C2.start, annotation$Gene, sep="_")
    } else if (eventType == "MXE") {
        # Create searchable strings for junctions
        incAstr <- junctionString(chr, strand,
                                  annotation$C1.end, annotation$A1.start)
        incBstr <- junctionString(chr, strand,
                                  annotation$A1.end, annotation$C2.start)
        excAstr <- junctionString(chr, strand,
                                  annotation$C1.end, annotation$A2.start)
        excBstr <- junctionString(chr, strand,
                                  annotation$A2.end, annotation$C2.start)
        
        # Get specific junction quantification
        coords <- rownames(junctionQuant)
        incA <- junctionQuant[fmatch(incAstr, coords), ]
        incB <- junctionQuant[fmatch(incBstr, coords), ]
        excA <- junctionQuant[fmatch(excAstr, coords), ]
        excB <- junctionQuant[fmatch(excBstr, coords), ]
        
        # Calculate inclusion levels
        inc <- (incA + incB)
        exc <- (excA + excB)
        tot <- inc + exc
        psi <- inc/tot
        # Ignore PSI where total reads are below the threshold
        psi[tot < minReads] <- NA
        rownames(psi) <- paste(eventType, chr, strand, annotation$C1.end,
                               annotation$A1.start, annotation$A1.end, 
                               annotation$A2.start, annotation$A2.end,
                               annotation$C2.start, annotation$Gene, sep="_")
    } else if (eventType == "A5SS" || eventType == "AFE") {
        # Create searchable strings for junctions
        incStr <- junctionString(chr, strand,
                                 annotation$A1.end, annotation$C2.start)
        excStr <- junctionString(chr, strand,
                                 annotation$C1.end, annotation$C2.start)
        
        # Get specific junction quantification
        coords <- rownames(junctionQuant)
        inc <- junctionQuant[fmatch(incStr, coords), ]
        exc <- junctionQuant[fmatch(excStr, coords), ]
        tot <- inc + exc
        
        # Calculate inclusion levels
        psi <- inc/tot
        # Ignore PSI where total reads are below the threshold
        psi[tot < minReads] <- NA
        
        rownames(psi) <- paste(eventType, chr, strand, annotation$C1.end, 
                               annotation$A1.end, annotation$C2.start, 
                               annotation$Gene, sep="_")
    } else if (eventType == "A3SS" || eventType == "ALE") {
        # Create searchable strings for junctions
        incStr <- junctionString(chr, strand,
                                 annotation$C1.end, annotation$A1.start)
        excStr <- junctionString(chr, strand,
                                 annotation$C1.end, annotation$C2.start)
        
        # Get specific junction quantification
        coords <- rownames(junctionQuant)
        inc <- junctionQuant[fmatch(incStr, coords), ]
        exc <- junctionQuant[fmatch(excStr, coords), ]
        tot <- inc + exc
        
        # Calculate inclusion levels
        psi <- inc/tot
        # Ignore PSI where total reads are below the threshold
        psi[tot < minReads] <- NA
        
        rownames(psi) <- paste(eventType, chr, strand, annotation$C1.end,
                               annotation$A1.start, annotation$C2.start, 
                               annotation$Gene, sep = "_")
    }
    
    # Clear rows with nothing but NAs
    naRows <- rowSums(!is.na(psi)) == 0
    return(psi[!naRows, ])
}