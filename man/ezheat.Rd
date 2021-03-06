% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ezheat.R
\name{ezheat}
\alias{ezheat}
\title{Plot heatmap}
\usage{
ezheat(object, labrows = NULL, pheno.df = NULL, main = "Log2 Expression",
  name = "topgenes_heat", sc = "ctr", clip = NA, color.v = NULL,
  unique.rows = FALSE, only.labrows = FALSE, ntop = NULL,
  stat.tab = NULL, cutoff = 0.05, labcols = NULL, reorder_rows = FALSE,
  reorder_cols = FALSE, fontsize_row = 10, fontsize_col = 10,
  na.lab = c("---", ""), plot = TRUE)
}
\arguments{
\item{object}{Matrix-like object with samples as columns and features as rows. Cannot have \code{NA}s.}

\item{labrows}{Labels corresponding to rows, e.g. gene symbols.}

\item{pheno.df}{Phenotype dataframe.}

\item{main}{Title of plot appended to the name of scaling, if any.}

\item{name}{Name of PDF to plot. Set to \code{NA} to plot to screen instead of to PDF.}

\item{sc}{Row scaling. Should rows be centered ('ctr'), z-scored ('z'), or neither ('none').}

\item{clip}{Values with magnitude > \code{clip} are reset to value \code{clip}. If given, must be > 0.}

\item{color.v}{Color palette for heatmap. If \code{NULL}, it's set to
\code{colorRampPalette(rev(brewer.pal(n=9, name='RdYlBu')))(50)}.}

\item{unique.rows}{Logical, indicating if to remove duplicated row labels to make rows unique.}

\item{only.labrows}{Logical, if \code{TRUE} only include rows where \code{labrows} aren't missing
(missing is defined by \code{na.lab}).}

\item{ntop}{Scalar number of rows to include.}

\item{stat.tab}{Matrix-like object with statistics, such as p-values, per column. If given, its dimensions should
match \code{object} and it cannot have \code{NA}s.}

\item{cutoff}{Cutoff such that elements with \code{stats.tab < cutoff} show asterisk if \code{stats.tab} and
\code{cutoff} are not \code{NULL}.}

\item{labcols}{Labels for columns. This can be \code{NULL}, of length 1 (in which case it is recycled), or of length
\code{ncol(object)}.}

\item{reorder_rows}{Logical indicating if rows should be reordered with hierarchical clustering.}

\item{reorder_cols}{Logical indicating if columns should be reordered with hierarchical clustering.}

\item{fontsize_row}{Font size for row labels.}

\item{fontsize_col}{Font size for column labels.}

\item{na.lab}{Character vector of labels in \code{lab.col} to treat as missing, in addition to \code{NA}.}

\item{plot}{Logical indicating if the heatmap should be plotted.}
}
\value{
A list with element \code{mat} of the matrix of values plotted, and if \code{plot=TRUE} element \code{gtable},
containing the \code{gtable} object returned by \code{\link[pheatmap]{pheatmap}}.
}
\description{
Draw heatmap using \code{pheatmap} package.
}
\details{
If the data after scaling and clipping (if they are used) has positive and negative values, the key is made
symmetric about zero.
}
