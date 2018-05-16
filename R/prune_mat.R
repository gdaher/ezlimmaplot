#' Prune matrix
#'
#' Prune matrix before plotting as heatmap.
#'
#' @param object Matrix-like object.
#' @param symbols Labels corresponding to rows, e.g. gene symbols.
#' @param only.symbols Logical, if \code{TRUE} only include rows with a symbol.
#' @param unique.rows Logical, indicating if to remove duplicated row labels to make rows unique.
#' @param ntop Scalar number of rows to include.
#' @param na.lab Character vector of labels in \code{lab.col} to treat as missing, in addition to \code{NA}.
#' @param verbose Logical indicating whether to print messages to console.

prune_mat <- function(object, symbols=NULL, only.symbols=FALSE, unique.rows=FALSE, ntop=NULL, na.lab=c('---', ''), verbose=TRUE){
  if (!is.matrix(object)) object <- data.matrix(object)
  if (!is.null(symbols)){
    stopifnot(length(symbols)==nrow(object), names(symbols)==rownames(object))
    na.sym.ind <- which(is.na(symbols) | sym %in% na.lab)
    if (length(na.sym.ind) > 0){
      rownames(object)[-na.sym.ind] <- symbols[-na.sym.ind]
    } else {
      rownames(object) <- symbols
    }

    if (only.symbols){
      if (verbose) cat('Removing', length(na.sym.ind), 'rows without gene symbols\n')
      object <- object[-na.sym.ind,]
    }
    if (unique.rows){
      if (verbose) cat('Removing', sum(duplicated(rownames(object))), 'rows with duplicated names\n')
      object <- object[!duplicated(rownames(object)),]
    }
  }

  if (!is.null(ntop)){
    if (verbose) cat('Selecting top', ntop, 'rows\n')
    if (ntop >= nrow(object)){
      object <- object[1:ntop,]
    } else {
      if (verbose) cat("After processing, object has only", nrow(object), "rows, so cannot subset to", ntop, "rows.\n")
    }
  }
  return(object)
}