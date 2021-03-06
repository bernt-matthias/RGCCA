#' Plots for RGCCA
#' 
#' Plots different outputs of the results obtained by a rgcca function 
#' @param x Result of rgcca function  (see\code{\link[RGCCA]{rgcca}} )
#' @param type Type among c("ind","var","both","ave","cor","weight","network").  See details.
#' @param text_ind A bolean to represent the individuals with their row names (TRUE)
#' or with circles (FALSE)
#' @param text_var A bolean to represent the variables with their row names (TRUE)
#' or with circles (FALSE)
#' @param title_ind Character for the title of the individual space 
#' @param title_var Character for the title of the variable space 
#' @param colors representing a vector of the colors used in the graph. Either a vector of integers (each integer corresponding to a color) or of characters corresponding to names of colors (as "blue",see colors()) or RGB code ("#FFFFFF").
#' @param ... Further graphical parameters applied to both (individual and variable) spaces
#' @inheritParams plot_ind
#' @inheritParams plot2D
#' @inheritParams plot_var_2D
#' @details 
#' \itemize{
#'  \item "ind" for individual graph: Y of rgcca are plotted. In abscissa Y[[i_block]][,compx], in ordinate, Y[[i_block_y]][,compy]. Each point correspond to one individual. It can be colored with the resp. options. The colors by default can be modified in colors options.
#' \item  "var" for variable graph: in abscissa, the correlations with the first axis, in ordinate, the correlation with the second axis. 
#' \item "both": displays both ind and var graph (this requires only one block (i_block=i_block_y) and at least two components in the rgcca calculation (ncomp>1 for this block)
#' \item "ave": displays the variance average in each block
#' \item "net": displays the graphical network corresponding to the connection matrix used in the rgcca
#' \item "cor": barplot corresponding to the correlation of each variable with a chosen axis (specified by i_block and compx). Variables are sorted from the highest to the lowest and only the highest are displayed (to modify the number, use the parameter n_marks)
#' \item "weight":barplot corresponding to the correlation of each variable with a chosen axis (specified by i_block and compx). Variables are sorted from the highest to the lowest and only the highest are displayed (to modify the number, use the parameter n_marks)
#' }
#' @examples
#' data(Russett)
#' X_agric =as.matrix(Russett[,c("gini","farm","rent")]);
#' X_ind = as.matrix(Russett[,c("gnpr","labo")]);
#' X_polit = as.matrix(Russett[ , c("demostab", "dictator")]);
#' A = list(X_agric, X_ind, X_polit);
#' C = matrix(c(0, 0, 1, 0, 0, 1, 1, 1, 0), 3, 3);
#' resRgcca=rgcca(blocks=A,connection=C,
#' tau=rep(1,3),ncomp=rep(2,3),superblock=FALSE)
#' plot(resRgcca,type="cor")
#' plot(resRgcca,type="weight")
#' plot(resRgcca,type="ind")
#' plot(resRgcca,type="var")
#' plot(resRgcca,type="both")
#' @importFrom gridExtra grid.arrange
#' @export
plot.rgcca=function(x,type="weight",i_block=length(x$A),i_block_y=i_block,compx=1,compy=2,resp=rep(1, NROW(x$Y[[1]])),remove_var=FALSE,text_var=TRUE,text_ind=TRUE,response_name= "Response",no_overlap=FALSE,title=NULL,title_var="Variable correlations with",title_ind= "Sample space",n_mark=100,collapse=FALSE,cex=1,cex_sub=10,cex_main=14,cex_lab=12,colors=NULL,...)
{
    match.arg(type,c("ind","var","both","ave","cor","weight","network"))
    if(i_block!=i_block_y & is.null(type)){ type="weight"}
    if(i_block==i_block_y & is.null(type)){ type="both"}
    
    if(type=="both")
    {
        if(is.null(i_block)){i_block=length(x$call$blocks)}
        p1<-plot_ind(x,i_block=i_block,i_block_y=i_block_y,compx=compx,compy=compy,cex_sub=cex_sub,cex_main=cex_main,cex_lab=cex_lab,resp=resp,response_name=response_name,text=text_ind,title=title_ind,colors=colors,no_overlap=no_overlap,...)
        p2<-plot_var_2D(x,i_block=i_block,compx=compx,compy=compy,cex_sub=cex_sub,cex_main=cex_main,cex_lab=cex_lab,remove_var=remove_var,text=text_var,no_overlap=no_overlap,title=title_var,n_mark = n_mark,collapse=collapse,colors=colors,...)
        titlePlot=toupper(names(x$call$blocks)[i_block])
        p5<-grid.arrange(p1,p2,nrow=1,ncol=2,top = titlePlot)
        plot(p5)
    }
    if(type=="var")
    {
       p5 <- plot_var_2D(x,i_block=i_block,compx=compx,compy=compy,cex_sub=cex_sub,cex_main=cex_main,cex_lab=cex_lab,remove_var=remove_var,text=text_var,no_overlap=no_overlap,title=title_var,n_mark = n_mark,collapse=collapse,colors=colors)
        plot(p5)
     }
    if(type=="ind")
    {
        p5<-plot_ind(x,i_block=i_block,i_block_y=i_block_y,compx=compx,compy=compy,cex_sub=cex_sub,cex_main=cex_main,cex_lab=cex_lab,resp=resp,response_name=response_name,text=text_ind,title=title_ind,colors=colors,...)
        plot(p5)
     }
    if(type=="ave")
    {
        if(is.null(title)){title="Average Variance Explained"}
        p5 <- plot_ave (x,
            cex = cex,
            title = title,
            colors = colors,
            ...)
        plot(p5)
    }
    if(type=="network")
    {
        if(is.null(title)){title=paste0("Common rows between blocks : ",
                                        NROW(x$call$blocks[[1]]))}
        plot_network (
            x, 
            title = title)
        p5<-NULL
    }
    if(type=="cor")
    {
        p5=plot_var_1D(x,
            comp = compx,
            n_mark = n_mark,
            type = "cor",
            collapse = collapse,
            title = title,
            colors = colors,
            i_block = i_block,
            ...)
        plot(p5)
    }
    if(type=="weight")
    {
        p5=plot_var_1D(x,
                    comp = compx,
                    n_mark = n_mark,
                    i_block = i_block,
                    type = "weight",
                    collapse = collapse,
                    title = title,
                    colors = colors,
                    ...)
        plot(p5)
    }
      

   # p3<-plot_ave(x)
   # p4<-plot_network(x)
   #p5<-grid.arrange(p1,p2,p3,p4,nrow=2,ncol=2)
   
   
    invisible(p5)
}