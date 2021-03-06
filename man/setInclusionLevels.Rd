% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/globalAccess.R
\name{setInclusionLevels}
\alias{setInclusionLevels}
\title{Set inclusion levels for a given data category}
\usage{
setInclusionLevels(value, category = getCategory())
}
\arguments{
\item{value}{Data frame or matrix: inclusion levels}

\item{category}{Character: data category (e.g. "Carcinoma 2016"); by default,
it uses the selected data category}
}
\description{
Set inclusion levels for a given data category
}
\note{
Needs to be called inside reactive function
}

