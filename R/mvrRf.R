requireNamespace('randomForest')

#' Multivariate regression with random forest model
#'
#' @param data  matrix or data.frame.   
#' @param alpha numeric. Critical level
#' @param ntree numeric. Number of treed for random forest model
#' @param plot  logical. Plot or not
#'
#' @return list(fit, score).
#' @export
#'
#' @examples
#' model <- el.mvrRf(tr, alpha = 0.01) 
#' score <- el.mvrRfScore(ob, model$fit)
#' 
el.mvrRf <- function(data, alpha = 0.01, ntree = 100, plot = TRUE) {
  
  if(!el.isValid(data, 'multiple')) return()
  
  d <- as.data.frame(data[stats::complete.cases(data),])
  
  if (nrow(d) < ncol(d)) {
    logger.error("Non-NA data is too small")
    return()
  }
  
  forests <- lapply(1:ncol(d), function(i) {
    randomForest::randomForest(stats::as.formula(paste(colnames(d)[i], '~ .')),
                               data = d, ntree = ntree)
    
    # c.f. following code is incorrect
    # randomForest::randomForest(d[,i] ~ .,  data = d, ntree = ntree)
  })
  
  est <- as.data.frame(sapply(1:ncol(d), function(i){
    stats::predict(forests[[i]], d)
  }))
  
  resi <- d - est
  
  ucl = apply(resi, 2, function(x) {
    el.limit(x, alpha = alpha / 2)
  })
  
  lcl = apply(resi, 2, function(x) {
    el.limit(x, alpha = alpha / 2, upper = F)
  })
  
  if (plot) { el.plot.resi(resi, ucl, lcl) }
  
  list(
    fit = list(forests = forests,
               alpha = alpha,
               ucl = ucl,
               lcl = lcl),
    score = resi
  )
} 

#' Compute scores given multivariate regression model with random forest
#'
#' @param data  matrix or data.frame.
#' @param fit   list(forests, alpha, ucl, lcl). mvrLm model
#' @param plot  logical. Plot or not
#'
#' @return residual to estimation
#' @export
#'
#' @examples 
#' model <- el.mvrRf(tr, alpha = 0.01) 
#' score <- el.mvrRfScore(ob, model$fit)
#' 
el.mvrRfScore <- function(data, fit, plot = TRUE) {
  
  if(!el.isValid(data, 'multiple')) return()
  
  d <- as.data.frame(data)
  
  if (ncol(d) != length(fit$forests)) {
    logger.error("Number of columms in data is different from model")
    return()
  }
  
  est <- as.data.frame(sapply(1:ncol(d), function(i){
    stats::predict(fit$forests[[i]], d)
  }))
  
  resi = d - est

  if (plot) { el.plot.resi(resi, fit$ucl, fit$lcl) }
  
  resi
}