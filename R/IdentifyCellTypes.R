#' Calculate pathway enrichment profile
#'
#' Calculate cluster average gene expression profile and determine the pathway enrichment profile of each cluster
#' @param exprMatrix A gene expression matrix, with genes in rows and cells in columns.
#' @param cell_markers A list of possible cell types found in the dataset and their marker genes.
#' @param cluster_labels A named vector of cluster identifier for each cell in the gene expression matrix
#' @param threshold Threshold of GSVA score quantile. Cell types with GSVA scores in this quantile or higher compared to all other cell type scores for the same cluster would be included in cluster label. Numeric between 0-1, default to 0.9.
#' @export
#' @importFrom GSVA gsva
#' @importFrom reshape2 melt
#' @importFrom tibble rownames_to_column
#' @return A vector of cell types inferred from the expression of marker genes provided
IdentifyCellTypes <- function(exprMatrix, cluster_labels, cell_markers, threshold=0.9){
  exprMatrix_bycluster <- list()
  for (i in sort(as.numeric(unique(cluster_labels)))){
    exprMatrix_bycluster[[i]] <- rowMeans(exprMatrix[, which(colnames(exprMatrix) %in% names(cluster_labels)[which(cluster_labels == i)])])
  }
  exprMatrix_bycluster <- do.call(cbind, exprMatrix_bycluster)
  colnames(exprMatrix_bycluster) <- sort(as.numeric(unique(cluster_labels)))
  rownames(exprMatrix_bycluster) <- rownames(exprMatrix)

  cell_type_classifier <- GSVA::gsva(exprMatrix_bycluster, cell_markers, parallel.sz=1)

  cell_types <- apply(cell_type_classifier, 2, function(x) paste0(rownames(cell_type_classifier)[which(x > quantile(x, threshold))], collapse="/"))

  if (any(cell_types == "")){
    cell_types[cell_types==""] <- "Unclassified"
  }
#   if (any(apply(cell_type_classifier, 2, max) < 0.5)){
#   message(paste("Cluster(s)", names(which(apply(cell_type_classifier, 2, max) < 0.5)), "cannot be classified with confidence using the provided markers and received the label 'Other'. Please revise marker sets and re-run if possible, or
#                 manually alter cluster labels by setting object@clusterlabel"))
#   cell_types[which(apply(cell_type_classifier, 2, max) < 0.5)] <- "Other"
# }
  return(cell_types)
}








