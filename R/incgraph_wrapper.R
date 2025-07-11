loadModule("IncGraphModule", TRUE)

network.check <- function(network) {
  if (!inherits(network, "Rcpp_incgraph.network")) {
    stop("network must be created by new.network or matrix.as.network.")
  }
}
node.id.check <- function(network, i, var.name) {
  if (i <= 0 || network$amnt.nodes < i) {
    stop(var.name, " must have a value between 1 and ", network$amnt.nodes)
  }
}
amnt.nodes.check <- function(amnt.nodes) {
  if (amnt.nodes < 1) {
    stop("The network must contain at least 1 node.")
  }
}
links.check <- function(links, amnt.nodes) {
  if (!all(0 < links & links <= amnt.nodes))
    stop(
      "links must be a N-by-2 matrix with values between 1 and ",
      amnt.nodes,
      ", each row representing one edge in the network."
    )
}

#' @title IncGraph network
#'
#' @description
#' `new.incgraph.network` creates a new IncGraph object containing either
#' an empty network or a network initialised from a given matrix.
#'
#' @details
#' This creates a new instance of the incgraph.network class. At least one of the parameters
#' (`amnt.nodes` or `links`) needs to be passed to this function.
#' Please note that this is a stateful object.
#'
#' @usage
#' new.incgraph.network(amnt.nodes, links=NULL)
#'
#' new.incgraph.network(amnt.nodes=NULL, links)
#'
#' new.incgraph.network(amnt.nodes, links)
#'
#' @param amnt.nodes The number of nodes in the network
#' @param links A matrix with 2 columns and N rows, 1 row for each edge to be loaded in the network
#' @return An instance of the incgraph.network class
#'
#'
#' @examples
#' # Create a new (empty) network with 4 nodes
#' net <- new.incgraph.network(amnt.nodes = 4)
#'
#' # Create a new network with 4 nodes and some edges
#' net <- new.incgraph.network(links = matrix(c(1, 2, 2, 3, 1, 4), ncol=2))
#'
#' # Create a new network with 10 nodes and some edges
#' net <- new.incgraph.network(amnt.nodes = 10, links = matrix(c(1, 2, 2, 3, 1, 4), ncol=2))
#'
#' # Create a more complex network from a matrix
#' mat <- matrix(c(1, 2,
#'                 1, 3,
#'                 1, 4,
#'                 1, 5,
#'                 1, 6,
#'                 1, 7,
#'                 2, 7,
#'                 2, 8,
#'                 2, 9,
#'                 2, 10), ncol=2)
#' net <- new.incgraph.network(links=mat)
#' # Calculate the initial orbit counts using orca
#' orb.counts <- calculate.orbit.counts(net)
#' # Modify an edge and calculate the differences in orbit counts
#' flip(net, 5, 10) # add (5,10)
#' delta1 <- calculate.delta(net, 5, 10)
#' # Modify another edge
#' flip(net, 6, 10) # add (6, 10)
#' delta2 <- calculate.delta(net, 6, 10)
#' # And another
#' flip(net, 1, 5)  # remove (1, 5)
#' delta3 <- calculate.delta(net, 1, 5)
#' # Verify that the new orbit counts equals the old orbit counts plus the delta counts
#' new.orb.counts.incremental <- orb.counts +
#'   delta1$add - delta1$rem +
#'   delta2$add - delta2$rem +
#'   delta3$add - delta3$rem
#' new.orb.counts <- calculate.orbit.counts(net)
#' all(new.orb.counts.incremental == new.orb.counts) # TRUE
#'
#' ## Additional helper functions
#' # Transform the network to a matrix
#' network.as.matrix(net)
#' # Get all neighbours of a node
#' get.neighbours(net, 1)
#' # Does the network contain a specific interaction?
#' contains(net, 5, 10)
#' contains(net, 7, 10)
#' # Reinitialise to an empty network
#' reset(net)
#' network.as.matrix(net)
#'
#' @seealso [incgraph()], [calculate.orbit.counts()], [calculate.delta()]
#'
#' @export
new.incgraph.network <- function(amnt.nodes = NULL, links = NULL) {
  if (is.null(links) && is.null(amnt.nodes)) {
    stop("Either amnt.nodes or links need to be passed a value")
  }
  if (is.null(amnt.nodes)) {
    amnt.nodes <- max(links)
  }
  amnt.nodes.check(amnt.nodes)
  network <- new(incgraph.network, amnt.nodes)
  if (!is.null(links)) {
    set.network(network, links)
  }
  network
}

#' @title Reset network
#'
#' @description
#' `reset` resets all the data structures so that all edges are removed from the network.
#'
#' @usage
#' reset(network)
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#'
#' @export
reset <- function(network) {
  network.check(network)
  network$reset()
}

#' @title Modify edge
#'
#' @description
#' `flip` modifies an edge in the network. If it is contained in the network, it is removed from the network, otherwise it is added to the network.
#'
#' @usage
#' flip(network, i, j)
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#' @param i A node in `network`
#' @param j A node in `network`
#' @export
flip <- function(network, i, j) {
  network.check(network)
  node.id.check(network, i, var.name = "i")
  node.id.check(network, j, var.name = "j")
  network$flip(i - 1, j - 1)
}

#' @title Set a given network to contain the given links
#'
#' @description
#' `set.network` sets a given network to contain the given links.
#'
#' @details
#' This first resets the network and adds all given links. For minor changes to the network,
#' the usage of [flip()] is recommended.
#'
#' @usage
#' set.network(network, links)
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#' @param links A matrix with 2 columns and N rows, 1 row for each edge to be loaded in the network
#'
#' @export
set.network <- function(network, links) {
  network.check(network)
  links.check(links, network$amnt.nodes)
  network$set.network(links - 1)
}

#' @title Calculate orbit counts from scratch
#'
#' @description
#' `calculate.orbit.counts` calculates the orbit counts of the current network.
#'
#' @details
#' The complete orbit counts is calcucated using the [orca::count5()].
#'
#' Calling this method repeatedly becomes very inefficient for evolving networks. For evolving networks, the usage
#' of [calculate.delta()] is recommended.
#'
#' For more details on this method, see Hočevar and Demšar (2014).
#'
#' @usage
#' calculate.orbit.counts(network)
#'
#' @references
#' Hočevar, T. and Demšar J. (2014) A combinatorial approach to graphlet counting. Bioinformatics.
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#' @return An N-by-73 matrix, with N the number of nodes in the network and 1 column for each possible orbit.
#' The value of `mat[i,j]` is the number of times node `i` has orbit `j` in a subgraph in the network.
#'
#' @export
calculate.orbit.counts <- function(network) {
  network.check(network)
  # todo: include orca code in own cpp file?
  amnt.nodes <- network$amnt.nodes
  mat <- network.as.matrix(network)
  elems <- mat
  dim(elems) <- NULL
  elems <- unique(elems)
  map <- match(seq_len(amnt.nodes), elems)
  new.mat <- apply(mat, c(1, 2), function(x) map[x])
  orbit.counts <- orca::count5(new.mat)
  do.call(
    "rbind",
    lapply(map, function(x) {
      if (is.na(x)) rep.int(0, 73) else orbit.counts[x, ]
    })
  )
}

#' @title Modify edge
#'
#' @description
#' `orca.halfdelta` calculates the orca counts for a network that has just been changed.
#'
#' @usage
#' orca.halfdelta(network, i, j)
#'
#' @param network An instance of the incgraph.network class
#' @param i A node in `network`
#' @param j A node in `network`
#'
#' @export
orca.halfdelta <- function(network, i, j) {
  network.check(network)
  node.id.check(network, i, var.name = "i")
  node.id.check(network, j, var.name = "j")

  amnt.nodes <- network$amnt.nodes
  mat <- network.as.matrix(network)
  if (network$contains(i - 1, j - 1)) {
    filt <- (mat[, 1] == i & mat[, 2] == j) | (mat[, 1] == j & mat[, 2] == i)
    mat <- mat[!filt, , drop = FALSE]
  } else {
    mat <- rbind(mat, c(i, j))
  }

  elems <- mat
  dim(elems) <- NULL
  elems <- unique(elems)
  map <- match(seq_len(amnt.nodes), elems)
  new.mat <- apply(mat, c(1, 2), function(x) map[x])
  orbit.counts <- orca::count5(new.mat)
  do.call(
    "rbind",
    lapply(map, function(x) {
      if (is.na(x)) {
        rep.int(0, 73)
      } else {
        orbit.counts[x, ]
      }
    })
  )
}

#' @title Calculate changes in orbit counts
#'
#' @description
#' `calculate.delta` calculates the changes in orbit counts as a result of a single edge modification.
#'
#' @usage
#' calculate.delta(network, i, j)
#'
#' @details
#' This method iterates over and counts all graphlets which were added to or removed from the network due to one edge modification.
#'
#' @references Cannoodt, R. et al. (2015) IncGraph: A graphlet-based approach for characterising
#' topological changes in evolving networks. Submitted to Bioinformatics.
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#' @param i A node in `network`
#' @param j A node in `network`
#' @return A list containing two N-by-73 matrices, with N the number of nodes in the network and 1 column for each possible orbit.
#' The value of `list$add[i,j]` (resp. `list$rem[i,j]`) is the number of times a subgraph was added to (resp. removed from)
#' the network such that node `i` has orbit `j` in that subgraph.
#'
#' @export
calculate.delta <- function(network, i, j) {
  network.check(network)
  node.id.check(network, i, var.name = "i")
  node.id.check(network, j, var.name = "j")
  out <- network$calculate.delta(i - 1, j - 1)
  colnames(out$add) <- paste0("O", seq_len(73) - 1)
  colnames(out$rem) <- paste0("O", seq_len(73) - 1)
  out
}

#' @title Neighbours
#'
#' @description
#' `get.neighbours` returns a vector of all neighbours of `i`.
#'
#' @usage
#' get.neighbours(network, i)
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#' @param i A node in `network`
#' @return Returns all neighbours of node `i`
#'
#' @export
get.neighbours <- function(network, i) {
  network.check(network)
  node.id.check(network, i, var.name = "i")
  network$get.neighbours(i - 1) + 1
}

#' @title Contains
#'
#' @description
#' `contains` returns `TRUE` if the network contains the edge (i, j).
#'
#' @usage
#' contains(network, i, j)
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#' @param i A node in `network`
#' @param j A node in `network`
#' @return `TRUE` if the network contains (i, j)
#'
#' @export
contains <- function(network, i, j) {
  network.check(network)
  node.id.check(network, i, var.name = "i")
  node.id.check(network, j, var.name = "j")
  network$contains(i - 1, j - 1)
}

#' @title Network as matrix
#'
#' @description
#' `network.as.matrix` returns the network as a matrix
#'
#' @usage
#' network.as.matrix(network)
#'
#' @seealso See [new.incgraph.network()] for examples and usage.
#'
#' @param network An instance of the incgraph.network class
#'
#' @export
network.as.matrix <- function(network) {
  network.check(network)
  amnt.nodes <- network$amnt.nodes
  mat <-
    do.call(
      "rbind",
      sapply(seq_len(amnt.nodes - 1) - 1, function(i) {
        right <- network$get.neighbours(i)
        right <- right[right > i]
        left <- rep.int(i, length(right))
        cbind(left, right)
      })
    ) +
    1
  class(mat) <- "integer"
  colnames(mat) <- NULL
  mat
}
