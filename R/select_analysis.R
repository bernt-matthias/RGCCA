#' Define the analysis parameters
#'
#' Define the correct parameters according to the type of the analysis
#' @param type A character giving the type of analysis: c('rgcca', 'cpca-w', 'gcca', 'hpca', 'maxbet-b', 'maxbet', 'maxdiff-b','maxdiff', 'maxvar-a', 'maxvar-b', 'maxvar', 'niles', 'r-maxvar', 'rcon-pca',
#' 'ridge-gca', 'sabscor', 'ssqcor', 'ssqcor', 'ssqcov-1', 'ssqcov-2', 'ssqcov',
#' 'sum-pca', 'sumcor', 'sumcov-1', 'sumcov-2', 'sumcov.', 'sabscov', 'plspm','cca', 'ra', 'ifa', 'pls','pca')
#' @inheritParams plot_var_2D
#' @inheritParams set_connection
#' @param response Integer representing the number of the response block. Indeed, when a supervised analysis is chosen (plspm, pls), the response block has to be specified.  
#' @param connection  A design matrix (J*J) that describes the relationships between blocks (default: complete design).
#' @param penalty A vector of float (or character for 'optimal' setting) giving the
#' shrinkage parameter for covariance maximization
#' @param ncomp A vector of integer giving the number of component for each
#' blocks
#' @param scheme A character giving the link function for covariance maximization
#' @param verbose A boolean displaying the warnings
#' @param quiet A boolean hidding the warnings
#' @return \item{blocks}{A list of matrix}
#' @return \item{scheme}{A character giving the link function for covariance
#' maximization}
#' @return \item{penalty}{A vector of float (or character for 'optimal' setting) giving
#' the shrinkage parameter for covariance maximization}
#' @return \item{ncomp}{A vector of integer giving the number of component for each
#' blocks}
#' @return \item{connection}{matrix giving the connection between the blocks}
#' @return \item{superblock}{A boolean giving the presence (TRUE) / absence (FALSE)
#' of a superblock}

select_analysis <- function(
    blocks = blocks,
    connection = 1 - diag(length(blocks)),
    penalty = rep(1, length(blocks)),
    ncomp = rep(1, length(blocks)),
    scheme = "centroid",
    superblock = TRUE,
    type  = "rgcca",
    verbose = TRUE,
    quiet = FALSE,
    response = NULL) {

    J <- length(blocks)
    msg_superblock <- "a superbloc is used"
    msg_type <- paste0("By using a ", toupper(type), ", ")
    warn.type.value <- warn.type.par <- warn.msg.super <- character(0)

    if (quiet)
        verbose <- FALSE

    ### SETTINGS ###

    warnParam <- function(param, x) {
        warn.type.par <<- c(warn.type.par, paste(deparse(substitute(param))))
        warn.type.value <<- c(warn.type.value, toString(x))
    }

    setPenalty <- function(x) {
        warnParam(penalty, x)
        return(x)
    }

    setScheme <- function(x) {
        warnParam(scheme, x)
        return(x)
    }

    set_connection <- function(x) {
        warnParam(connection, paste(deparse(substitute(x))))
        return(x)
    }

    warnSuper <- function(x) {
        if (class(x) %in% c("matrix", "data.frame") && NCOL(x) < (length(blocks)) && is.null(response)){
            warn.msg.super <<- c(warn.msg.super, deparse(substitute(x)))
            return(cbind(x, 1))
        }else if (length(x) < (length(blocks)) && is.null(response)) {
            warn.msg.super <<- c(warn.msg.super, deparse(substitute(x)))
            if(deparse(substitute(x)) == "ncomp")
                return(c(x, max(x)))
            else
                return(c(x, 1))
        } else{
            return(x)
        }
    }

    setSuperbloc <- function(verbose = TRUE) {
        blocks <<- c(blocks, superblock = list(Reduce(cbind, blocks)))
        superblock <<- TRUE
        connection <<- NULL
        ncomp <<- warnSuper(ncomp)
    }

    set2Block <- function(type) {
        if (length(blocks) != 2)
            check_nblocks(blocks, type)

        scheme <<- setScheme("horst")
        connection <<- set_connection(1 - diag(2))
    }

    ### CHECK TYPES ###

    if (length(grep("[sr]gcca", tolower(type))) == 1) {
        if (superblock) {
            setSuperbloc(FALSE)
            penalty <- warnSuper(penalty)
        } else
            superblock <- FALSE
    } else
        superblock <- FALSE

    if (length(grep("s?pca", tolower(type))) == 1) {
        if (length(blocks) != 1)
            check_nblocks(blocks, type)

        scheme <- setScheme("horst")
        setSuperbloc()
        if (tolower(type) == "pca")
            penalty <- setPenalty(c(1, 1))
    }

    # 2 Blocks cases
    else if (tolower(type) %in% c("cca", "ra", "ifa", "pls", "spls")) {
        set2Block(type)

        if (tolower(type) == "cca")
            penalty <- setPenalty(c(0, 0))

        else if (tolower(type) %in% c("ifa", "pls"))
            penalty <- setPenalty(c(1, 1))

        else if (tolower(type) == "ra")
            penalty <- setPenalty(c(1, 0))

    }

    # Design with 1 values everywhere
    else if (tolower(type) %in% c("sumcor",
                                "ssqcor",
                                "sabscor",
                                "sumcov",
                                "sumcov-1",
                                "maxbet",
                                "sabscov")) {
        connection <- set_connection(matrix(1, J, J))

        # COR models
        if (tolower(type) %in% c("sumcor", "ssqcor", "sabscor")) {
            penalty <- setPenalty(rep(0, J))

            switch(
                tolower(type),
                "sumcor" = {
                    scheme <- setScheme("horst")
                },
                "ssqcor" = {
                    scheme <- setScheme("factorial")
                },
                "sabscor" = {
                    scheme <- setScheme("centroid")
                }
            )
        }

        # COV models
        else if (tolower(type) %in% c(
            "sumcov",
            "sumcov-1",
            "maxbet",
            "ssqcov",
            "ssqcov-1",
            "maxbet-b",
            "sabscov",
            "sabscov-1"
        )) {
            penalty <- setPenalty(rep(1, J))

            if (tolower(type) %in% c("sumcov", "sumcov-1", "maxbet"))
                scheme <- setScheme("horst")

            else if (tolower(type) %in% c("ssqcov", "ssqcov-1", "maxbet-b"))
                scheme <- setScheme("factorial")

            else if (tolower(type) %in% c("sabscov", "sabscov-1"))
                scheme <- setScheme("centroid")

        }

        # Design with 1 values everywhere and 0 on the diagonal
    }

    else if (tolower(type) %in% c("sumcov-2",
                                "maxdiff",
                                "ssqcov",
                                "ssqcov-1",
                                "maxbet-b",
                                "ssqcov-2",
                                "maxdiff-b")) {
        connection <- set_connection(1 - diag(J))

        if (tolower(type) %in% c("sumcov-2", "maxdiff")) {
            scheme <- setScheme("horst")
            penalty <- setPenalty(rep(0, J))
        }

        else if (tolower(type) %in% c("ssqcov-2", "maxdiff-b")) {
            scheme <- setScheme("factorial")
            penalty <- setPenalty(rep(1, J))
        }

    }

    # Models with a superblock
    else if (tolower(type) %in% c(
        "maxvar-b",
        "gcca",
        "niles",
        "maxvar",
        "hpca",
        "maxvar-a",
        "cpca",
        "cpca-w",
        "mfa",
        "sum-pca",
        "mcoa",
        "rcon-pca",
        "ridge-gca",
        "r-maxvar"
    )) {
        setSuperbloc()

        if (tolower(type) %in% c("maxvar-b", "gcca", "niles", "maxvar")) {
            scheme <- setScheme("factorial")
            penalty <- setPenalty(rep(0, J + 1))
        }

        else if (tolower(type) == "hpca") {
            scheme <- function(x)
                x ^ 4
            penalty <- setPenalty(c(rep(1, J), 0))
        }

        else if (tolower(type) %in% c(
            "maxvar-a",
            "cpca",
            "cpca-w",
            "mfa",
            "sum-pca",
            "mcoa"
        )) {
            scheme <- setScheme("factorial")
            penalty <- setPenalty(c(rep(1, J), 0))
        }

        #TODO: verify these three last algo parameters

        else if (tolower(type) == "rcon-pca")
            penalty <- warnSuper(penalty)

        else if (tolower(type) == "ridge-gca") {
            scheme <- setScheme("factorial")
            penalty <- setPenalty(c(penalty[seq(J)], 0))
        }

        else if (tolower(type) == "r-maxvar") {
            scheme <- setScheme("factorial")
            penalty <- warnSuper(penalty)
        }

    }

    ### WARNINGS ###

    n = length(warn.type.par)
    if (verbose & n > 0) {
        setPlural = function(x = warn.type.par,
                            y = warn.type.value,
                            sep = " and ") {
            warn.type.par <<- paste0(x, collapse = sep)
            warn.type.value <<- paste0(y, collapse = sep)
        }

        if (n > 1) {
            grammar = "s were respectively"
            if (n == 2)
                setPlural()
            else{
                warn.type = c(warn.type.par[n], warn.type.value[n])
                setPlural(warn.type.par[-n], warn.type.value[-n], ", ")
                setPlural(c(warn.type.par, warn.type[1]),
                        c(warn.type.value, warn.type[2]))
            }
        } else
            grammar <- " was"

        msg <- paste0(warn.type.par,
                    " parameter",
                    grammar,
                    " set to ",
                    warn.type.value)

        if (superblock & tolower(type) != "pca")
            msg <- paste0(msg, " and ", msg_superblock)

        warning(paste0(msg_type, msg , "."))
    }

    if (verbose & superblock) {
        if (n < 0)
            paste0(msg_superblock, msg_superblock)
    }

    if (!quiet & length(warn.msg.super) > 0) {
        if (length(warn.msg.super) > 1) {
            warn.msg.super <- paste(warn.msg.super, collapse = " and ")
            grammar <- "were those"
        } else
            grammar <- "was the one"

        # warning(paste0("By using a superblock, ", warn.msg.super,
        #    " of the superblock ", grammar," of the first block."))
    }

    return(list(
        scheme = scheme,
        penalty = penalty,
        ncomp = ncomp,
        connection = connection,
        superblock = superblock
    ))
}
