print.rgccad <- function(x, ...) 
{

    cat("Call: ")
    dput(x$call[!names(x$call)%in%c("A")])
    
  cat("\n\n")
  
  if(is.list(x$crit))
  {
      critByNcomp=sapply(x$crit,function(t){return(t[length(t)])})
      cat("Sum_{j,k} c_jk g(cov(X_ja_j, X_ka_k) = ", sep = "", 
          paste(round(sum(critByNcomp), 4), sep = "", " "), fill = TRUE)
  }
  else
  {
      cat("Sum_{j,k} c_jk g(cov(X_ja_j, X_ka_k) = ", sep = "", 
          paste(round(x$crit[length(x$crit)], 4), sep = "", " "), fill = TRUE)
  }
  cat("There are J =", NCOL(x$call$C), "blocks.", fill = TRUE)
  cat("The design matrix is:\n") 
  colnames(x$call$C) = rownames(x$call$C) = names(x$a) ; print(x$call$C)
  cat("The", x$call$scheme, "scheme was used.", fill = TRUE)

 param="regularization"

  if(is.vector(x$tau))
  {
      for (i in 1:NCOL(x$call$C)) {
          cat("The ",param," parameter used for block", i, "was:", 
              round(x$call$tau[i], 4), fill = TRUE)
      }
  }
 
  if(is.matrix(x$tau))
  {
      
      cat("The",param,"parameter matrix was:",fill=TRUE)
      print(round(x$call$tau,4))
  }
  
}

