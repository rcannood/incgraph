incgraph
========

[![Build Status](https://travis-ci.org/rcannood/incgraph.png?branch=master)](https://travis-ci.org/rcannood/incgraph)

incgraph incrementally calculates the differences in orbit counts when performing single edge modifications in a network. For evolving networks, calculating the differences in orbit counts is much more performant than recalculating all orbit counts from scratch for each time point.

Install
-------

incgraph currently needs to be installed using devtools. When building for Windows, the correct version of Rtools also needs to be installed.

``` r
devtools::install_github("rcannood/incgraph")
```

Examples
--------

Create a new (empty) network with 4 nodes

``` r
library(incgraph)
net <- new.incgraph.network(amnt.nodes = 4)
```

Create a new network with 4 nodes and some edges

``` r
net <- new.incgraph.network(links = matrix(c(1, 2, 2, 3, 1, 4), ncol=2))
```

Create a new network with 10 nodes and some edges

``` r
net <- new.incgraph.network(amnt.nodes = 10, links = matrix(c(1, 2, 2, 3, 1, 4), ncol=2))
```

Create a more complex network from a matrix

``` r
mat <- matrix(c(1, 2, 
                1, 3, 
                1, 4, 
                1, 5, 
                1, 6, 
                1, 7, 
                2, 7, 
                2, 8, 
                2, 9, 
                2, 10), ncol=2)
net <- new.incgraph.network(links=mat)
```

Calculate the initial orbit counts using orca

``` r
orb.counts <- calculate.orbit.counts(net)
```

Modify an edge and calculate the differences in orbit counts

``` r
flip(net, 5, 10) # add (5,10)
delta1 <- calculate.delta(net, 5, 10)
```

Modify another edge

``` r
flip(net, 6, 10) # add (6, 10)
delta2 <- calculate.delta(net, 6, 10)
```

And another

``` r
flip(net, 1, 5)  # remove (1, 5)
delta3 <- calculate.delta(net, 1, 5)
```

Verify that the new orbit counts equals the old orbit counts plus the delta counts

``` r
new.orb.counts.incremental <- orb.counts + 
  delta1$add - delta1$rem +
  delta2$add - delta2$rem +
  delta3$add - delta3$rem
new.orb.counts <- calculate.orbit.counts(net)
all(new.orb.counts.incremental == new.orb.counts) # TRUE
```

    ## [1] TRUE

Examples of additional helper functions
---------------------------------------

Transform the network to a matrix

``` r
network.as.matrix(net)
```

    ##      [,1] [,2]
    ## [1,]    1    2
    ## [2,]    1    5
    ## [3,]    2    7
    ## [4,]    3    7
    ## [5,]    4    8
    ## [6,]    5    9
    ## [7,]    5   10

Get all neighbours of a node

``` r
get.neighbours(net, 1)
```

    ## [1] 0 1 4

Does the network contain a specific interaction?

``` r
contains(net, 5, 10)
```

    ## [1] TRUE

``` r
contains(net, 7, 10)
```

    ## [1] FALSE

Reinitialise to an empty network

``` r
reset(net)
network.as.matrix(net)
```

    ##      [,1] [,2]
