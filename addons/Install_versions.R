#!/usr/bin/env Rscript

## Packages_analytics.R pins every package as install.versions(pkg, version), in
## dependency order and covering the whole site library, so each tarball can be
## fetched and installed directly: no repository index lookup, and no dependency
## resolution that could pull in an unpinned version. A genuinely missing
## dependency fails during R CMD INSTALL, naming the package.
##
## repos supplies only the base URL for the fetch, since the pin list fixes every
## version. The repository therefore needs to be complete rather than
## contemporary: a dated snapshot cannot hold a version released after its date,
## while the CRAN archive only accumulates. The base image's own default is an
## MRAN snapshot, which no longer exists.
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

install.versions <- function(pkg, version) {
  base <- getOption("repos")[["CRAN"]]
  urls <- c(
    sprintf("%s/src/contrib/%s_%s.tar.gz", base, pkg, version),
    sprintf("%s/src/contrib/Archive/%s/%s_%s.tar.gz", base, pkg, pkg, version)
  )
  tarball <- file.path(tempdir(), sprintf("%s_%s.tar.gz", pkg, version))

  for (u in urls) {
    got <- tryCatch(
      download.file(u, tarball, quiet = TRUE, mode = "wb") == 0L,
      error = function(e) FALSE,
      warning = function(w) FALSE
    )
    if (got) {
      install.packages(tarball, repos = NULL, type = "source")
      ## the raw DESCRIPTION string, not packageVersion(): the version class
      ## normalises '0.1-3' to '0.1.3', and Test_packages.R compares raw strings
      have <- tryCatch(
        as.character(utils::packageDescription(pkg, fields = "Version")),
        error = function(e) NA_character_,
        warning = function(w) NA_character_
      )
      if (identical(have, version)) {
        return(invisible(TRUE))
      }
      stop(sprintf("installed %s %s but wanted %s", pkg, have, version))
    }
  }

  stop(sprintf("could not download %s %s from %s", pkg, version, base))
}
