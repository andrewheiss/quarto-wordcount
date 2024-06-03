#' Create a temporary directory for testing
#'
#' This function uses a test fixture
#' (https://testthat.r-lib.org/articles/test-fixtures.html) to create a
#' temporary directory and copies the "_extensions" folder into it for running
#' tests. Everything is deleted when the tests are finished.
#'
#' @param env The environment in which to run the deferred cleanup code.
#'   Defaults to the parent frame.
#' @param test_file An optional file to copy into the temporary directory.
#' @return The path to the temporary directory.
create_local_quarto_project <- function(env = parent.frame(), test_file = NULL) {
  # Create temporary folder
  dir <- tempfile(pattern = "test-")
  dir.create(dir)
  
  # Record the starting state
  old_wd <- getwd()
  
  # Things to undo when this is all done
  withr::defer(
    {
      setwd(old_wd)         # Restore working directory (-B)
      fs::dir_delete(dir)   # Delete temporary folder   (-A)
    },
    envir = env
  )
  
  # Things to do
  setwd(dir)  # Change working directory (B)
  
  # Copy _extensions folder and test file to temporary folder (A)
  file.copy(from = here::here("_extensions"), to = ".", recursive = TRUE)
  if (!is.null(test_file)) {
    file.copy(from = test_file$absolute, to = test_file$qmd)
  }
  
  invisible(dir)
}

#' Get the parts of a test file name
#'
#' This function takes a filename and returns a list containing the absolute
#' path, the base filename with the .qmd extension, and the base filename with
#' the .md extension.
#'
#' @param filename The name of the file.
#' @returns A list containing the absolute path, the base filename with the .qmd
#'   extension, and the base filename with the .md extension.
test_file_parts <- function(filename) {
  list(
    absolute = filename, 
    qmd = basename(filename),
    md = paste0(tools::file_path_sans_ext(basename(filename)), ".md")
  )
}

#' Extract word count section from terminal output
#'
#' This function locates the content between "Overall totals" and Quarto's
#' "Output created" line in the terminal output that Quarto emits.
#'
#' @param raw_output The results from `quarto::quarto_render()`, captured with
#'   `capture.output()`
#' @returns A character object containing the word count section from the
#'   terminal output
extract_output <- function(raw_output) {
  start_index <- grep("^Overall totals:", raw_output)
  end_index <- grep("^Output created:", raw_output) - 1
  actual_output <- paste0(raw_output[start_index:end_index], collapse = "\n")
  
  # Switch Windows-style \r\n linebreaks to \n
  actual_output <- gsub("\r\n", "\n", actual_output)
  
  actual_output
}


#' Get word counts from a Markdown file
#'
#' This function parses the YAML front matter of a markdown file, which should
#' contain keys with `wordcount_*_words` entries with the calculated word
#' counts.
#'
#' @param filename The name of the file.
#' @returns A list containing all the `wordcount__words*` entries.
get_wordcounts <- function(filename) {
  yaml_metadata <- rmarkdown::yaml_front_matter(filename)
  yaml_metadata <- yaml_metadata[grep("^wordcount", names(yaml_metadata))]
  yaml_metadata
}
