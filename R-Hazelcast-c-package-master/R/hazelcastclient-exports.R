
#' Hazelcast client backed by the Hazelcast C++ client
#'
#' An Rcpp module class wrapping the Hazelcast C++ client. Values are stored and
#' retrieved as raw vectors, so callers serialise and unserialise R objects
#' themselves.
#'
#' @param ip character Address of a cluster member.
#' @param clusterName character Name of the Hazelcast cluster.
#' @param port integer Port of the cluster member. Defaults to 5701.
#'
#' @return
#' A `HazelcastClient` object from the _C++_ HazelcastClient class.
#'
#' @section Methods:
#' \describe{
#'   \item{`GetUrl()`}{Address, port and current map name, as used in error messages.}
#'   \item{`SetMap(mapName)`}{Select the distributed map used by `Get`, `TryGet` and `Put`.}
#'   \item{`SetVerboseMode(verboseMode)`}{Print a line on each successful fetch.}
#'   \item{`Get(key)`}{Return the stored raw vector. Throws if the key is absent.}
#'   \item{`TryGet(key)`}{Return the stored raw vector, or an empty vector if the key is absent.}
#'   \item{`Put(key, value)`}{Store a raw vector under `key`.}
#' }
#'
#' @examples
#' \dontrun{
#' hz <- new(HazelcastClient, ip = "10.30.100.180", clusterName = "DEV", port = 5701)
#' hz$SetMap("binarymap")
#' hz$Put("42:asset_info", serialize(data.frame(a = 1), NULL))
#' unserialize(hz$Get("42:asset_info"))
#' }
#' @name HazelcastClient
#' @export HazelcastClient

# ^^^^^^^^^^^^^^^^
# Export the "HazelcastClient" C++ class by explicitly requesting HazelcastClient be
# exported via roxygen2's export tag.
# Also, provide a name for the Rd file.


# Load the Rcpp module exposed with RCPP_MODULE( ... ) macro.
loadModule(module = "HazelcastClientEx", TRUE)
