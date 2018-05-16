#' Volcano plot in ggplot2
#'
#' Volcano plot in ggplot2 using output from \code{ezlimma} package.
#'
#' @param tab Table of output from \code{ezlimma}.
#' @param lfc.col logFC column. Some features should be > 0 and others < 0.
#' @param sig.col Column with p-values or FDRs.
#' @param lab.col Column with labels, such as gene symbol, annotating features.
#' @param ntop.sig Number of top significant features to annotate.
#' @param ntop.lfc Number of top logFC features to annotate.
#' @param comparison Name of contrast to plot. If given, it's assumed that \code{lfc.col=paste0(comparison, '.logFC')}
#' and \code{sig.col=paste0(comparison, '.p') or paste0(comparison, '.FDR')}, and these are over-ridden.
#' @param name Name of PNG file to write to. Set to \code{NA} to suppress writing to file.
#' @param add.rnames Additional rownames of features to annotate. These must be in \code{rownames(tab)}.
#' @param up.color Color for points that are upregulated (\code{logFC>0}).
#' @param down.color Color for points that are downregulated (\code{logFC<0}).
#' @param x.bound x-axis limits are set to \code{c(-x.bound, x.bound)}. If \code{NULL, x.bound=max(abs(tab[,lfc.col]))}.
#' @param y.bound y-axis limits are set to \code{c(0, y.bound)}. If \code{NULL, y.bound=max(tab[,'nlg10sig'])}.
#' @param type.sig Type of significance y-axis should use, either "p" or "FDR".
#' @param cut.color Color of points that meet both \code{cut.lfc} and \code{cut.sig}. If \code{NULL}, cutoffs are ignored.
#' @param cut.lfc Points need to have \code{|logFC| >= cut.lfc} to have \code{cut.color}.
#' @param cut.sig Points need to have significance \code{<= cut.sig} to have \code{cut.color}. Significance type is of
#' \code{type.sig}.
#' @param sep Separator string between contrast names and suffix such as \code{logFC}.
#' @param na.lab Character vector of labels in \code{lab.col} to treat as missing, in addition to \code{NA}.
#' @details If \code{ntop.sig>0} or \code{ntop.lfc>0}, then \code{lab.col} must be in \code{colnames(tab)}.
#' @return A ggplot object, invisibly.
#' @export
#' @import ggplot2

ezvolcano <- function(tab, lfc.col=NULL, sig.col=NULL, lab.col='Gene.Symbol', ntop.sig=10, ntop.lfc=0, comparison=NULL,
                      name='volcano', add.rnames=NULL, up.color='black', down.color='black', x.bound=NULL, y.bound=NULL,
                      type.sig=c('p', 'FDR'), cut.color=NULL, cut.lfc=1, cut.sig=0.05, sep='.', na.lab=c('---', '')){
  if (!requireNamespace("ggplot2", quietly = TRUE)){
    stop("Package 'ggplot2' needed for this function to work. Please install it.", call. = FALSE)
  }

  type.sig <- match.arg(type.sig)
  if (type.sig=="p"){
    y.lab <- "-log10 p-value"
  } else {
    y.lab <- "-log10 FDR"
  }

  #infer columns
  if (!is.null(comparison)){
    lfc.col <- paste0(comparison, sep, 'logFC')
    if (type.sig=="p"){
      sig.col <- paste0(comparison, sep, 'p')
    } else {
      sig.col <- paste0(comparison, sep, 'FDR')
    }
    if (!is.na(name)) name <- paste(comparison, name, sep='_')
  }

  stopifnot((ntop.sig==0 & ntop.lfc==0) | lab.col %in% colnames(tab), ntop.sig==as.integer(ntop.sig),
            ntop.lfc==as.integer(ntop.lfc), is.null(add.rnames)|add.rnames %in% rownames(tab),
            lfc.col %in% colnames(tab), sig.col %in% colnames(tab), any(tab[,lfc.col]<0), any(tab[,lfc.col]>=0))

  tab <- data.frame(tab, nlg10sig=-log10(tab[,sig.col]))
  #want symmetric x-axis
  if(is.null(x.bound)) x.bound <- max(abs(tab[,lfc.col]))
  if(is.null(y.bound)) y.bound <- max(tab[,'nlg10sig'])

  #plot up & down
  ind2p.up <- which(tab[,lfc.col] >= 0)
  ind2p.down <- which(tab[,lfc.col] < 0)
  vol <- ggplot(data=tab, aes_string(x=lfc.col, y='nlg10sig')) + xlim(c(-x.bound, x.bound)) + ylim(c(0, y.bound)) +
    geom_point(data=tab[ind2p.up,], size=2, color = up.color) + theme(axis.text=element_text(size=12, face="bold")) +
    geom_point(data=tab[ind2p.down,], size=2, color = down.color) + xlab("log2 fold change") + ylab(y.lab)
  if (!is.null(comparison)) vol <- vol + ggtitle(comparison)

  #plot points meeting cut
  if (!is.null(cut.color)){
    cut.pts <- which(abs(tab[,lfc.col]) > cut.lfc & tab[,sig.col] <= cut.sig)
    vol <- vol + geom_point(data=tab[cut.pts,], size=2, color = cut.color)
  }

  #ntop indices to plot with symbol
  if (ntop.sig > 0 | ntop.lfc > 0){
    na.lab.ind <- which(is.na(tab[,lab.col])|tab[,lab.col] %in% na.lab)
    if (ntop.lfc > 0) top.lfc.ind <- order(-abs(tab[,lfc.col]))[1:ntop.lfc] else top.lfc.ind <- NULL
    if (ntop.sig > 0) top.sig.ind <- order(tab[,sig.col])[1:ntop.sig] else top.sig.ind <- NULL
    ind.annot <- setdiff(union(top.sig.ind, top.lfc.ind), na.lab.ind)
  }
  #add.rnames to plot with symbol
  if (!is.null(add.rnames)){
    ind.add.rnames <- which(rownames(tab) %in% add.rnames)
    ind.annot <- union(ind.add.rnames, ind.annot)
  }
  if (!is.null(ind.annot)){
    vol <- vol + geom_text(data=tab[ind.annot,], mapping=aes_string(x=lfc.col, y='nlg10sig', label=lab.col), size=3, vjust=2)
  }

  if (!is.na(name)) ggsave(filename=paste0(name, ".png"), plot=vol) else graphics::plot(vol)
  return(invisible(vol))
}