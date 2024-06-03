test_that("disabling code block counting works", {
  test_file <- test_file_parts(here::here("tests/testthat/test-code-blocks-disabled.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  quarto::quarto_render(input = test_file$qmd, quiet = TRUE)
  
  counts <- get_wordcounts(test_file$md)
  
  expect_equal(counts$wordcount_appendix_words, 5)
  expect_equal(counts$wordcount_body_words, 7)
  expect_equal(counts$wordcount_note_words, 3)
  expect_equal(counts$wordcount_ref_words, 0)
  expect_equal(counts$wordcount_total_words, 15)
})

test_that("enabling code block counting works", {
  test_file <- test_file_parts(here::here("tests/testthat/test-code-blocks-enabled.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  quarto::quarto_render(input = test_file$qmd, quiet = TRUE)
  
  counts <- get_wordcounts(test_file$md)
  
  expect_equal(counts$wordcount_appendix_words, 11)
  expect_equal(counts$wordcount_body_words, 13)
  expect_equal(counts$wordcount_note_words, 9)
  expect_equal(counts$wordcount_ref_words, 0)
  expect_equal(counts$wordcount_total_words, 33)
})

test_that("as-is output from echo=false chunks gets counted", {
  test_file <- test_file_parts(here::here("tests/testthat/test-code-blocks-asis.qmd"))
  
  create_local_quarto_project(test_file = test_file)
  
  quarto::quarto_render(input = test_file$qmd, quiet = TRUE)
  
  counts <- get_wordcounts(test_file$md)
  
  expect_equal(counts$wordcount_appendix_words, 0)
  expect_equal(counts$wordcount_body_words, 9)
  expect_equal(counts$wordcount_note_words, 0)
  expect_equal(counts$wordcount_ref_words, 0)
  expect_equal(counts$wordcount_total_words, 9)
})
