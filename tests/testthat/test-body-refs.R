test_that("counting the body text and references works", {
  test_file <- test_file_parts(here::here("tests/testthat/test-body-refs.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  quarto::quarto_render(input = test_file$qmd, quiet = TRUE)
  
  counts <- get_wordcounts(test_file$md)

  expect_equal(counts$wordcount_appendix_words, 0)
  expect_equal(counts$wordcount_body_words, 6)
  expect_equal(counts$wordcount_note_words, 0)
  expect_equal(counts$wordcount_ref_words, 34)
  expect_equal(counts$wordcount_total_words, 40)
})
