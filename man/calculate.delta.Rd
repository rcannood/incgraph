% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/incgraph_wrapper.R
\name{calculate.delta}
\alias{calculate.delta}
\title{Calculate changes in orbit counts}
\usage{
calculate.delta(network, i, j)
}
\arguments{
\item{network}{An instance of the incgraph.network class}

\item{i}{A node in \code{network}}

\item{j}{A node in \code{network}}
}
\value{
A list containing two N-by-73 matrices, with N the number of nodes in the network and 1 column for each possible orbit.
The value of \code{list$add[i,j]} (resp. \code{list$rem[i,j]}) is the number of times a subgraph was added to (resp. removed from)
the network such that node \code{i} has orbit \code{j} in that subgraph.
}
\description{
\code{calculate.delta} calculates the changes in orbit counts as a result of a single edge modification.
}
\details{
This method iterates over and counts all graphlets which were added to or removed from the network due to one edge modification.
}
\references{
Cannoodt, R. et al. (2015) IncGraph: A graphlet-based approach for characterising
topological changes in evolving networks. Submitted to Bioinformatics.
}
\seealso{
See \code{\link[=new.incgraph.network]{new.incgraph.network()}} for examples and usage.
}
