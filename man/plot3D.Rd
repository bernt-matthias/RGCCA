% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot3D.R
\name{plot3D}
\alias{plot3D}
\title{Plot in 3 dimensions}
\usage{
plot3D(df, rgcca, compx = 1, compy = 2, compz = 3, i_block = 1,
  i_block_y = i_block, i_block_z = i_block, text = TRUE,
  title = "Sample plot", type = "ind", cex = 1, cex_point = 3 *
  cex, cex_lab = 19 * cex)
}
\arguments{
\item{df}{A dataframe}

\item{rgcca}{A list giving the results of a R/SGCCA}

\item{compx}{An integer giving the index of the analysis component used
for the x-axis}

\item{compy}{An integer giving the index of the analysis component used
for the y-axis}

\item{compz}{An integer giving the index of the analysis component used
for the z-axis}

\item{i_block}{An integer giving the index of a list of blocks}

\item{i_block_y}{An integer giving the index of a list of blocks (another
one, different from the one used in i_block)}

\item{i_block_z}{An integer giving the index of a list of blocks (another
one, different from the one used in i_block)}

\item{text}{A bolean to represent the points with their row names (TRUE)
or with circles (FALSE)}

\item{title}{A character with the name of the space (either "Variables" or
"Samples")}

\item{type}{A character for the type of plot : either "ind" for individual plot or "var" for corcircle}

\item{cex}{An integer for the size of the plot parameters}

\item{cex_point}{An integer for the size of the points or the text in the plot}

\item{cex_lab}{An integer for the size of the axis titles}
}
\description{
Plot in 3 dimensions either to visualize the components of an analyse or the variables
}
\examples{
library(RGCCA)
data("Russett")
blocks = list(agriculture = Russett[, seq(3)],
    politic = Russett[, 6:11] )
rgcca_out = rgcca.analyze(blocks, ncomp = rep(3, 2))
df = get_comp(rgcca_out, compz = 3)
plot3D(df, rgcca_out, i_block = 2)
plot3D(df, rgcca_out, i_block = 2, text = FALSE)
response = factor( apply(Russett[, 9:11], 1, which.max),
                  labels = colnames(Russett)[9:11] )
response = blocks[[2]][, 1]
names(response) = row.names(blocks[[2]])
df = get_comp(rgcca_out, response, compz = 3)
plot3D(df, rgcca_out, i_block = 2, text = FALSE)
plot3D(df, rgcca_out, i_block = 2)
df = get_ctr2(rgcca_out, compz = 3, i_block = 1, collapse = TRUE)
plot3D(df, rgcca_out, i_block = 2, type = "var")
}