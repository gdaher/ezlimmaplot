context("ezvenn")

test_that("ezvenn", {
  expect_error(ezvenn(res.df, plot=FALSE))

  ezv <- ezvenn(res.df, p.cutoff = 0.05, plot=FALSE)
  expect_equal(as.numeric(ezv["gene1",]), c(1,0,-1))
  expect_lte(max(res.df["gene74", c("Last3.p", "Last3vsFirst3.p")]), 0.05)
  expect_gt(res.df["gene74", "First3.p"], 0.05)

  ezv <- ezvenn(res.df, p.cutoff = 0.05, logfc.cutoff = 1, plot=FALSE)
  expect_equal(sum(abs(ezv)), 2)
  expect_equal(as.numeric(ezv["gene1",]), c(1,0,-1))

  ezv <- ezvenn(res.df, fdr.cutoff = 0.01, plot=FALSE)
  expect_equal(sum(abs(ezv)), 2)
  expect_equal(as.numeric(ezv["gene1",]), c(1,0,-1))

  ezv.fn <- function() ret <- ezvenn(res.df, p.cutoff = 0.05, name=NA)
  vdiffr::expect_doppelganger("venn", ezv.fn)

  ezv.fn2 <- function() ret <- ezvenn(res.df, p.cutoff = 0.05, logfc.cutoff = 1, name=NA)
  vdiffr::expect_doppelganger("venn2", ezv.fn2)

  res2 <- res.df[,-grep("logFC$", colnames(res.df))]
  ezv.fn3 <- function() ret <- ezvenn(res2, p.cutoff = 0.05, name=NA)
  vdiffr::expect_doppelganger("venn_noLFC", ezv.fn3)

  ezv.fn4 <- function() ret <- ezvenn(res2, fdr.cutoff = 0.01, name=NA)
  vdiffr::expect_doppelganger("venn_noLFC2", ezv.fn4)
})
