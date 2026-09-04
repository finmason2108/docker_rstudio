#!/bin/sh
# Emit an install.versions() line for every CRAN package present in the current
# analytics image, in dependency order.
#
#   sh tools/extract-pins.sh > /tmp/pins.R
#
# then replace the install.versions() block of Packages_analytics.R with the
# output, keeping that file's header comment.
#
# Override the image with IMAGE=... if you want a different tag.

set -e

IMAGE="${IMAGE:-657399224926.dkr.ecr.us-east-1.amazonaws.com/rstudio:test-2.1.21}"

# --entrypoint R bypasses /entrypoint.sh, which prints banner lines onto stdout.
# --slave is the R 3.6 spelling of --no-echo.
docker run --rm -i --entrypoint R "$IMAGE" --slave --no-save <<'EOF' | grep '^install\.versions('
db <- installed.packages()

# site-library only. Base and recommended packages ship with R itself and must
# not be reinstalled from CRAN. HazelcastClient is built from source later in the
# Dockerfile and has no CRAN release; versions is no longer used.
keep <- grepl("site-library", db[, "LibPath"], fixed = TRUE) &
        !db[, "Package"] %in% c("HazelcastClient", "versions")
db <- db[keep, , drop = FALSE]
pkgs <- db[, "Package"]

# Direct dependencies inside the pinned set. Suggests is ignored: it is not
# needed to build or load a package, and it would introduce cycles.
deps <- lapply(pkgs, function(p) {
  d <- db[p, c("Depends", "Imports", "LinkingTo")]
  d <- unlist(strsplit(d[!is.na(d)], ","))
  d <- sub("\\(.*", "", d)
  intersect(trimws(d), pkgs)
})
names(deps) <- pkgs

# Topological order, so each package compiles against the pinned versions of its
# dependencies instead of whatever the snapshot's current versions happen to be.
ordered <- character(0)
remaining <- pkgs
while (length(remaining) > 0) {
  ready <- remaining[vapply(deps[remaining], function(d) all(d %in% ordered), logical(1))]
  if (length(ready) == 0) {
    stop("dependency cycle among: ", paste(remaining, collapse = ", "))
  }
  ordered <- c(ordered, sort(ready))
  remaining <- setdiff(remaining, ready)
}

cat(sprintf("install.versions('%s','%s')", ordered, db[ordered, "Version"]), sep = "\n")
EOF
