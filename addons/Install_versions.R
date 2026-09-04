#!/usr/bin/env Rscript

## Packages_*.R pin every package as install.versions(pkg, version).
## remotes::install_version() resolves those from the CRAN Archive.
##
## repos must be set here, and to something that works: install_version builds
## its CRAN Archive URLs from it, and the base image defaults to an MRAN snapshot,
## which no longer exists. A dated snapshot rather than current CRAN, so that the
## remotes version and anything not covered by the pin list stay contemporary
## with R 3.6.2. The date is the one the base image itself declares
## (rocker/r-ver:3.6.2 pins MRAN 2020-02-28).
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2020-02-28"))

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

install.versions <- function(pkg, version) {
  remotes::install_version(pkg, version = version, upgrade = "never")
}
