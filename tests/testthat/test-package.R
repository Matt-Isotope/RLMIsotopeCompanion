testthat::test_that("the addin entry point exists", {
  testthat::expect_true(
    is.function(RLMIsotopeCompanion::R_LM_Isotope_Companion)
  )
})
