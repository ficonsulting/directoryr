context("test-build_dirs")

test_that("More than two sub-directories should is not supported", {
  expect_error(build_dirs("app-nest.yml"))
})

test_that("Duplicate packages are not allowed", {
  expect_error(build_dirs("app-dup.yml"))
})
