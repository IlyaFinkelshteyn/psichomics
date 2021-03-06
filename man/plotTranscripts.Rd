% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_information.R
\name{plotTranscripts}
\alias{plotTranscripts}
\title{Plot transcripts}
\usage{
plotTranscripts(info, eventPosition)
}
\arguments{
\item{info}{Information retrieved from ENSEMBL}

\item{eventPosition}{Numeric: coordinates of the alternative splicing event}
}
\description{
Plot transcripts
}
\examples{
event <- "SE_12_-_7985318_7984360_7984200_7982602_SLC2A14"
info  <- queryEnsemblByEvent(event, species="human", assembly="hg19")
pos   <- parseSplicingEvent(event)$pos[[1]]
\dontrun{
plotTranscripts(info, pos)
}
}

