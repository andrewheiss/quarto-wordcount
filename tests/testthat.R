# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)

# If running interactively, make sure you source tests/testthat/helper.R
# source(here::here("tests/testthat/helper.R"))

# Run all the tests in the testthat/ folder. In regular testthat situations,
# this would use `test_check()`, but that's designed for R packages, and this
# extension isn't a package.
test_dir(here::here("tests/testthat"))
