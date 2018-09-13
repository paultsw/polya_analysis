### make_violin.R: combine a bunch of datasets and plot side-by-side
### violin plots of their passing poly(A) length estimates on the
### same grid.
### Usage:
###   Rscript make_violin.R dataset1.tsv[ dataset2.tsv ... ]

library("ggplot2")

## helper function: extract last item past the final '/':
strip.filename <- function(pathstr) {
    strsplit(pathstr, "/")[[1]][-1]
}

## merge all dataframes together by PASS-ing poly(A) estimate:
make.joint.dataframe <- function(fns) {
    ## load inputs as dataframes:
    dataframes <- list()
    i <- 1
    for (fn in fns) {
        tmp <- read.csv(fn, sep = '\t')
        dataframes[[i]] <- data.frame(dataset = factor(rep(strip.filename(fn), each=nrow(tmp[tmp$qc_tag == 'PASS',]))),
                                      lengths = tmp[tmp$qc_tag == 'PASS',]$polya_length)
        i <- i + 1
    }
    # merge dataframes together and (automatically) return:
    do.call("rbind", dataframes)
}

## main loop: read filenames, construct a ggplot2 object,
## and save plot to file
main <- function() {
    ## load dataframes into a single DF:
    df <- make.joint.dataframe(commandArgs(trailingOnly=TRUE))
    
    ## make a violin plot of all filenames:
    max.ticks <- max(df$lengths)
    plot <- ggplot(df, aes(x=dataset, y=lengths)) +
        geom_violin() +
        scale_y_continuous(name="est p(A) length", breaks=seq(0,max.ticks,10), limits=c(0,250)) +
        theme_bw()

    ## save plot to file:
    ## TODO: optionally set size/dpi/etc.
    ggsave("violin.png", device="png")
}

### run main function:
main()
