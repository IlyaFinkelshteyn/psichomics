% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/events_miso.R
\name{parseMisoEventID}
\alias{parseMisoEventID}
\title{Match MISO's splicing event IDs with the IDs present in the alternative
splicing annotation file and get events in a data frame}
\usage{
parseMisoEventID(eventID, annotation, IDcolumn)
}
\arguments{
\item{eventID}{Character: alternative event IDs}

\item{annotation}{Data.frame: alternative event annotation file}

\item{IDcolumn}{Integer: index of the column with the event ID's in the
alternative event annotation file}
}
\value{
Data frame of the matching events (or NA when nothing is matched)
}
\description{
Match MISO's splicing event IDs with the IDs present in the alternative
splicing annotation file and get events in a data frame
}
\details{
For faster execution times, provide a vector of event IDs.

For more information about MISO, see \url{http://miso.readthedocs.org}.
}
\note{
If possible, it's recommend to use smaller subsets of the alternative
events' annotation instead of all data for faster runs. For example, when
trying to match only skipped exons event IDs, only use the annotation of
skipped exons instead of using a mega annotation with all event types.
}
\examples{
eventID <- c("2217@uc002poi.1@uc002poe.1", "57705@uc009xob.1@uc001jgy.2")
# the annotation is one of the GFF3 files needed to run MISO
gff3 <- system.file("extdata", "miso_AS_annot_example.gff3", 
                    package="psichomics")
annotation <- read.delim(gff3, header=FALSE, comment.char="#")
IDcolumn <- 9
psichomics:::parseMisoEventID(eventID, annotation, IDcolumn)
}

