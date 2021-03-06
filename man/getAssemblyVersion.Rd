% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/globalAccess.R
\name{getAssemblyVersion}
\alias{getAssemblyVersion}
\title{Get the assembly version of a data category}
\usage{
getAssemblyVersion(category = getCategory())
}
\arguments{
\item{category}{Character: data category (e.g. "Carcinoma 2016"); by default,
it uses the selected data category}
}
\value{
Character value with the assembly version
}
\description{
Get the assembly version of a data category
}
\note{
Needs to be called inside reactive function
}

