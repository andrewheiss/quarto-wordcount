test_that("counting the body text and appendix works", {
  test_file <- test_file_parts(here::here("tests/testthat/test-body-appendix.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  quarto::quarto_render(input = test_file$qmd, quiet = TRUE)
  
  counts <- get_wordcounts(test_file$md)
  
  expect_equal(counts$wordcount_appendix_words, 5)
  expect_equal(counts$wordcount_body_words, 4)
  expect_equal(counts$wordcount_note_words, 0)
  expect_equal(counts$wordcount_ref_words, 0)
  expect_equal(counts$wordcount_total_words, 9)
})
