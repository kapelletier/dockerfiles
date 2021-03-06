#!/usr/bin/env Rscript
#-------------------
# @author: Mahesh Vangala
# @email: vangalamaheshh@gmail.com
# @date: May, 23, 2016
#--------------------

if( is.element("ggbiplot", installed.packages())){
      suppressMessages(library(ggbiplot))
} else {
      suppressMessages(require("devtools"))
      install_github("vangalamaheshh/ggbiplot")
      suppressMessages(require(ggbiplot))
}

options(error = function() traceback(2))

pca_plot <- function(rpkmTable, annot, pca_out_pdf, pca_out_dir) {
  rpkm.pca <- prcomp(t(rpkmTable), center = TRUE, scale. = TRUE)
  plot.var <- ggscreeplot(rpkm.pca)
  suppressMessages(ggsave(paste(pca_out_dir,"/pca_plot_scree.png", sep="")))
  all_plots <- list()
  for (ann in colnames(annot)){
    g <- ggbiplot(rpkm.pca, groups = as.character(annot[,ann]), scale = 1, var.scale = 1, obs.scale = 1,
                labels=colnames(rpkmTable), choices = 1:2,
                ellipse=FALSE, circle = TRUE, var.axes = FALSE)
    g <- g + scale_color_discrete(name = ann)
    g <- g + theme(legend.direction = 'horizontal',
                   legend.position = 'top',
                   legend.title = element_text(face="bold"))
    all_plots <- c(all_plots, list(g))
    suppressMessages(ggsave(paste(pca_out_dir, "/pca_plot_", ann, ".png", sep="")))
  }

  pdf(pca_out_pdf)
  capture.output(print(c(all_plots,list(plot.var))))
  junk <- dev.off()
}


args <- commandArgs( trailingOnly = TRUE )
rpkmFile <- args[1]
metaFile <- args[2]
pca_out_pdf <- args[3]
pca_out_dir <- args[4]

rpkmTable <- read.csv(rpkmFile, header=T, check.names=F,
                        row.names=1, stringsAsFactors=FALSE, dec='.')
annot <- read.csv(metaFile, sep=",", header=T, row.names=1,
                      stringsAsFactors=FALSE, check.names=F, comment.char='#')
if(any(grepl("comp_*", colnames(annot)))) {
  annot <- annot[, !grepl('comp_*', colnames(annot)), drop = F]
}
pca_plot(rpkmTable, annot, pca_out_pdf, pca_out_dir)
