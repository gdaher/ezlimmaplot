#' PCA plot of top two components
#'
#' PCA plot of top two principal components using \code{ggplot2}.
#'
#' @param object Matrix-like object with samples as columns.
#' @param pheno.df Dataframe with rows as samples and columns as phenotypes.
#' @param name Name of PNG to write out. Set to \code{NA} to suppress writing to file.
#' @param alpha Transparency, passed to \code{\link[ggplot2]{geom_point}}.
#' @param all.size Passed to \code{\link[ggplot2]{geom_point}} \code{size} parameter to give size for all points without
#' appearing in legend. \code{ggplot2} default is size=2.
#' @param facet A formula with columns in \code{pheno.df} to facet by.
#' @param rm.leg.title Logical indicating if legend title should be removed.
#' @param labels Logical indicating if sample labels should be added next to points.
#' @param manual.color Vector passed to \code{\link[ggplot2]{scale_colour_manual}}.
#' @param manual.shape Vector passed to \code{\link[ggplot2]{scale_shape_manual}}.
#' @param ... Passed to \code{\link[ggplot2]{ggplot}} \code{aes_string} parameter.
#' @details PCA is calculated with \code{\link[stats]{prcomp}}.
#' @return Invisibly, first two principal components appended to \code{pheno.df}.
#' @export

ezpca <- function(object, pheno.df, name='pca', alpha=1, all.size=NULL, facet=NULL, rm.leg.title=FALSE,
                  labels=FALSE, manual.color = NULL, manual.shape = NULL, ...){
  if (!requireNamespace("ggplot2", quietly = TRUE)){
    stop("Package 'ggplot2' needed for this function to work. Please install it.", call. = FALSE)
  }
  stopifnot(ncol(object)==nrow(pheno.df), colnames(object)==rownames(pheno.df))

  pca <- stats::prcomp(t(object[rowSums(is.na(object))==0,]), scale. = FALSE)
  pve <- signif(summary(pca)$importance['Proportion of Variance', 1:2]*100, 2)

  dat <- data.frame(pca$x[rownames(pheno.df), 2:1], pheno.df)

  #need to set alpha/all.size in geom_point, else it appears in legend
  qp <- ggplot2::ggplot(dat, mapping=ggplot2::aes_string(y='PC1', x='PC2', ...)) + ggplot2::theme_bw() +
    ggplot2::theme(panel.grid=ggplot2::element_line(color='black'))
  if (!is.null(all.size)){
    qp <- qp + ggplot2::geom_point(size=all.size, alpha=alpha)
  } else {
    qp <- qp + ggplot2::geom_point(alpha=alpha)
  }
  if (!is.null(facet)){ qp <- qp + ggplot2::facet_grid(facet) }
  qp <- qp + ggplot2::ylab(paste0('PC1 (', pve[1], '%)')) + ggplot2::xlab(paste0('PC2 (', pve[2], '%)', sep=''))
  if (rm.leg.title){ qp <- qp + ggplot2::theme(legend.title=ggplot2::element_blank()) }
  if (labels){
    dat2 <- dat
    dat2$row_names <- rownames(pheno.df)
    qp <- qp + ggplot2::geom_text(data=dat2, mapping=ggplot2::aes_string(y='PC1', x='PC2', label='row_names'),
                                  size=2, vjust=-.7)
  }

  if(!is.null(manual.color)) qp <- qp + ggplot2::scale_colour_manual(values = manual.color)
  if(!is.null(manual.shape)) qp <- qp + ggplot2::scale_shape_manual(values = manual.shape)

  if (!is.na(name)){ ggplot2::ggsave(filename=paste0(name, '.png'), plot=qp) } else { graphics::plot(qp) }

  return(invisible(dat))
}
