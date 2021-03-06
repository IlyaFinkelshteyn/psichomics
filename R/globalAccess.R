## Functions to get and set globally accessible variables

#' @include utils.R 
NULL

# Global variable with all the data of a session
sharedData <- reactiveValues()

#' Get global data
#' @return Variable containing all data of interest
getData <- reactive(sharedData$data)

#' Get number of cores to use
#' @return Numeric value with the number of cores to use
getCores <- reactive(sharedData$cores)

#' Get number of significant digits
#' @return Numeric value regarding the number of significant digits
getSignificant <- reactive(sharedData$significant)

#' Get number of decimal places
#' @return Numeric value regarding the number of decimal places
getPrecision <- reactive(sharedData$precision)

#' Get selected alternative splicing event's identifer
#' @return Alternative splicing event's identifier as a string
getEvent <- reactive(sharedData$event)

#' Get available data categories
#' @return Name of all data categories
getCategories <- reactive(names(getData()))

#' Get selected data category
#' @return Name of selected data category
getCategory <- reactive(sharedData$category)

#' Get data of selected data category
#' @return If category is selected, returns the respective data as a data frame;
#' otherwise, returns NULL
getCategoryData <- reactive(
    if(!is.null(getCategory())) getData()[[getCategory()]])

#' Get selected dataset
#' @return List of data frames
getActiveDataset <- reactive(sharedData$activeDataset)

#' Get clinical data of the data category
#' @return Data frame with clinical data
getClinicalData <- reactive(getCategoryData()[["Clinical data"]])

#' Get junction quantification data
#' @note Needs to be called inside reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @return List of data frames of junction quantification
getJunctionQuantification <- function(category=getCategory()) {
    if (!is.null(category)) {
        data <- getData()[[category]]
        match <- sapply(data, attr, "dataType") == "Junction quantification"
        if (any(match)) return(data[match])
    }
}

#' Get alternative splicing quantification of the selected data category
#' @return Data frame with the alternative splicing quantification
getInclusionLevels <- reactive(getCategoryData()[["Inclusion levels"]])

#' Get data from global data
#' @param ... Arguments to identify a variable
#' @param sep Character to separate identifiers
#' @return Data from global data
getGlobal <- function(..., sep="_") sharedData[[paste(..., sep=sep)]]

#' Get the table of differential analyses of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Data frame of differential analyses
getDifferentialAnalyses <- function(category = getCategory())
    getGlobal(category, "differentialAnalyses")

#' Get the table of differential analyses' survival data of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Data frame of differential analyses' survival data
getDifferentialAnalysesSurvival <- function(category = getCategory())
    getGlobal(category, "diffAnalysesSurv")

#' Get the species of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character value with the species
getSpecies <- function(category = getCategory())
    getGlobal(category, "species")

#' Get the assembly version of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character value with the assembly version
getAssemblyVersion <- function(category = getCategory())
    getGlobal(category, "assemblyVersion")

#' Get groups from a given data type
#' @note Needs to be called inside reactive function
#' 
#' @param dataset Character: data set (e.g. "Clinical data")
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' @param full Boolean: return all the information on groups (TRUE) or just the
#' group names and respective indexes (FALSE)? FALSE by default
#' 
#' @return Matrix with groups of a given dataset
getGroupsFrom <- function(dataset, category = getCategory(), full=FALSE) {
    groups <- getGlobal(category, dataset, "groups")
    if (full)
        return(groups)
    else
        return(groups[, "Rows"])
}

#' Get clinical matches from a given data type
#' @note Needs to be called inside reactive function
#' 
#' @param dataset Character: data set (e.g. "Junction quantification")
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Integer with clinical matches to a given dataset
getClinicalMatchFrom <- function(dataset, category = getCategory())
    getGlobal(category, dataset, "clinicalMatch")

#' Get the groups column for differential splicing analysis of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
#' 
#' @return Character value with the groups column used for differential splicing
#' analysis
getDiffSplicingGroups <- function(category = getCategory())
    getGlobal(category, "diffSplicingGroups")

#' Set element as globally accessible
#' @details Set element inside the global variable
#' @note Needs to be called inside reactive function
#' 
#' @param ... Arguments to identify a variable
#' @param value Any value to attribute to element
#' @param sep Character to separate identifier
setGlobal <- function(..., value, sep="_") {
    sharedData[[paste(..., sep=sep)]] <- value
}

#' Set data of the global data
#' @note Needs to be called inside reactive function
#' @param data Data frame or matrix to set as data
setData <- function(data) setGlobal("data", value=data)

#' Set number of cores
#' @param cores Character: number of cores
#' @note Needs to be called inside reactive function
setCores <- function(cores) setGlobal("cores", value=cores)

#' Set number of significant digits
#' @param significant Character: number of significant digits
#' @note Needs to be called inside reactive function
setSignificant <- function(significant) setGlobal("significant", value=significant)

#' Set number of decimal places
#' @param precision Numeric: number of decimal places
#' @note Needs to be called inside reactive function
setPrecision <- function(precision) setGlobal("precision", value=precision)

#' Set event
#' @param event Character: event
#' @note Needs to be called inside reactive function
setEvent <- function(event) setGlobal("event", value=event)

#' Set data category
#' @param category Character: data category
#' @note Needs to be called inside reactive function
setCategory <- function(category) setGlobal("category", value=category)

#' Set active dataset
#' @param dataset Character: dataset
#' @note Needs to be called inside reactive function
setActiveDataset <- function(dataset) setGlobal("activeDataset", value=dataset)

#' Set inclusion levels for a given data category
#' @note Needs to be called inside reactive function
#' 
#' @param value Data frame or matrix: inclusion levels
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setInclusionLevels <- function(value, category = getCategory())
    sharedData$data[[category]][["Inclusion levels"]] <- value

#' Set groups from a given data type
#' @note Needs to be called inside reactive function
#' 
#' @param dataset Character: data set (e.g. "Clinical data")
#' @param groups Matrix: groups of dataset
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setGroupsFrom <- function(dataset, groups, category = getCategory())
    setGlobal(category, dataset, "groups", value=groups)

#' Set the table of differential analyses of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param table Character: differential analyses table
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setDifferentialAnalyses <- function(table, category = getCategory())
    setGlobal(category, "differentialAnalyses", value=table)

#' Set the table of differential analyses' survival data of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param table Character: differential analyses' survival data
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setDifferentialAnalysesSurvival <- function(table, category = getCategory())
    setGlobal(category, "diffAnalysesSurv", value=table)

#' Set the species of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param value Character: species
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setSpecies <- function(value, category = getCategory())
    setGlobal(category, "species", value=value)

#' Set the assembly version of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param value Character: assembly version
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setAssemblyVersion <- function(value, category = getCategory())
    setGlobal(category, "assemblyVersion", value=value)

#' Set the groups column for differential splicing analysis of a data category
#' @note Needs to be called inside reactive function
#' 
#' @param value Character: assembly version
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setDiffSplicingGroups <- function(value, category = getCategory())
    setGlobal(category, "diffSplicingGroups", value=value)

#' Set clinical matches from a given data type
#' @note Needs to be called inside reactive function
#' 
#' @param dataset Character: data set (e.g. "Clinical data")
#' @param matches Vector of integers: clinical matches of dataset
#' @param category Character: data category (e.g. "Carcinoma 2016"); by default,
#' it uses the selected data category
setClinicalMatchFrom <- function(dataset, matches, category = getCategory())
    setGlobal(category, dataset, "clinicalMatch", value=matches)