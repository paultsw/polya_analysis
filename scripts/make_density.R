### make_density.R: combine a bunch of datasets and plot their
### poly(A)-tail length estimates as densities, one dataset per
### row.
### Usage:
###   Rscript make_density.R dataset1.tsv[ dataset2.tsv ... ]

library("ggplot2")

## helper function: extract last item past the final '/':
strip.filename <- function(pathstr) {
    tail(strsplit(pathstr, "/")[[1]][-1], n=1)
}

## merge all dataframes together by PASS-ing poly(A) estimate:
## clamp to max value of 300nt for plotting
make.joint.dataframe <- function(fns) {
    ## load inputs as dataframes:
    dataframes <- list()
    i <- 1
    for (fn in fns) {
        tmp <- read.csv(fn, sep = '\t')
        dataframes[[i]] <- data.frame(dataset = factor(rep(strip.filename(fn), each=nrow(tmp[tmp$qc_tag == 'PASS',]))),
                                      lengths = pmin(tmp[tmp$qc_tag == 'PASS',]$polya_length, 300))
        i <- i + 1
    }
    ## merge dataframes together:
    do.call("rbind", dataframes)
}

## main loop: read filenames, construct a ggplot2 object,
## and save plot to file
main <- function() {
    ## load dataframes into a single DF:
    df <- make.joint.dataframe(commandArgs(trailingOnly=TRUE))
    
    ## make a violin plot of all filenames:
    max.ticks <- max(df$lengths)
    plot <- ggplot(df, aes(x=lengths, color=dataset)) +
        geom_density() +
        scale_x_continuous(name="est p(A) length", breaks=seq(0,max.ticks,10), limits=c(0,300)) +
        theme_bw()

    ## save plot to file:
    ## TODO: optionally set size/dpi/etc.
    ggsave("density.png", device="png", width=10, height=5)
}

### run main function:
main()
