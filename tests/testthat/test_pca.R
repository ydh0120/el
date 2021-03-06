context("PCA")

test_that("Check PCA modeling", {
  
  set.seed(1)
  
  data <- iris[,-5]
  pca <- el.pca(data)
  
  expect_true(is.matrix(pca$fit$loading))
  
  # TODO expect_equal fails while expect_true works. why?
  expect_true(round(pca$fit$vaCusum[2], 5) == 0.95813)
})

test_that("Check PCA scoring", {
  set.seed(1)
  
  data <- iris[,-5]
  pca <- el.pca(data)
  score <- el.pcaScore(data, pca$fit)
  
  expect_true( abs(sum(pca$score - score)) < 1E-4 )
})

test_that("Check PCA unscoring", {
  set.seed(1)
  
  data <- iris[,-5]
  pca <- el.pca(data)
  score <- el.pcaScore(data, pca$fit)
  d2 <- el.pcaUnscore(score, pca$fit)
  
  expect_true( abs(sum(data - d2)) < 1E-4 )
})

test_that("Check plot with temporal coloring", {
  set.seed(1)
  
  data <- iris[,-5]
  pca <- el.pca(data)
})