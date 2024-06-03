test_that("terminal output is correct; no appendix, no notes", {
  test_file <- test_file_parts(here::here("tests/testthat/test-terminal-output-no-app-notes.qmd"))
  
  create_local_quarto_project(test_file = test_file)

  actual_output <- capture.output(
    quarto::quarto_render(input = test_file$qmd, quiet = FALSE)
  ) |> extract_output()
  
  true_output <- "Overall totals:
--------------------------------
• 40 total words
• 6 words in body and notes

Section totals:
--------------------------------
• 6 words in text body
• 34 words in reference section
"
  
  expect_equal(actual_output, true_output)
})

test_that("terminal output is correct; all sections", {
  test_file <- test_file_parts(here::here("tests/testthat/test-terminal-output-all-sections.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  actual_output <- capture.output(
    quarto::quarto_render(input = test_file$qmd, quiet = FALSE)
  ) |> extract_output()
  
  true_output <- "Overall totals:
--------------------------------
• 47 total words
• 8 words in body and notes

Section totals:
--------------------------------
• 6 words in text body
• 2 words in notes
• 34 words in reference section
• 5 words in appendix section
"
  
  expect_equal(actual_output, true_output)
})

test_that("terminal output is correct; singular 'word' works", {
  test_file <- test_file_parts(here::here("tests/testthat/test-terminal-output-single-word.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  actual_output <- capture.output(
    quarto::quarto_render(input = test_file$qmd, quiet = FALSE)
  ) |> extract_output()
  
  true_output <- "Overall totals:
----------------------------
• 5 total words
• 5 words in body and notes

Section totals:
----------------------------
• 4 words in text body
• 1 word in notes
"
  
  expect_equal(actual_output, true_output)
})