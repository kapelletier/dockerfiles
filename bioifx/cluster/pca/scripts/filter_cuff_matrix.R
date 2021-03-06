#!/usr/bin/env Rscript
# vim : syntax=r tabstop=4 expandtab 

#---------------------------------
# @author: Mahesh Vangala
# @email: vangalamaheshh@gmail.com
# @date: May, 23, 2016
#---------------------------------

preprocess <- function(rpkm_file, filter_miRNA,
                       min_genes, min_samples, rpkm_cutoff) {
    
	rpkmTable <- read.csv(rpkm_file, header=T, check.names=F,
                        row.names=1, stringsAsFactors=FALSE, dec='.')

	for (n in names(rpkmTable)) {
    	rpkmTable[n] <- apply(rpkmTable[n], 1, as.numeric)
  	}

  	rpkmTable <- na.omit(rpkmTable)
  	sub_df <- rpkmTable[apply(rpkmTable, 1, function(x) length(x[x>=rpkm_cutoff])>min_samples),]
  	sub_df <- log2(sub_df + 1)

  	if (filter_miRNA == TRUE) {
    	sub_df <- sub_df[ !grepl("MIR|SNO",rownames(sub_df)), ]
  	}
  	min_genes = min(min_genes, nrow(sub_df))
  	## Calculate CVs for all genes (rows)
  	mean_rpkm <- apply(sub_df,1,mean)
  	var_rpkm <- apply(sub_df,1,var)
  	cv_rpkm <- abs(var_rpkm/mean_rpkm)
  	## Select out the most highly variable genes into the dataframe 'Exp_data'
  	exp_data <- sub_df[order(cv_rpkm,decreasing=T)[1:min_genes],]
	exp_data = exp_data[apply(exp_data, 1, var, na.rm=TRUE) != 0, ]
  	return (exp_data)
}

args <- commandArgs( trailingOnly = TRUE )
rpkm_file <- args[1]
filter_miRNA <- args[2]
numgenes <- args[3]
min_samples <- args[4]
RPKM_cutoff <- args[5]
out_file <- args[6]

filtered_cuff <- preprocess(rpkm_file, filter_miRNA,
				numgenes, min_samples, RPKM_cutoff)
write.csv(filtered_cuff, file=out_file, quote=FALSE)
