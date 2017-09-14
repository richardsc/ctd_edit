library(shiny)
library(oce)
shinyServer(function(input, output) {
    vals <- reactiveValues(keep=NULL, ctd=NULL, plot_type="TS", show_all=TRUE)
    output$plot <- renderPlot({
        if (!is.null(vals$ctd)) {
            if (vals$plot_style == 1) {
                if (vals$show_all) {
                    plotTS(vals$ctd, eos="gsw", pch=20, col=ifelse(vals$keep, "black", "red"))
                } else {
                    plotTS(subset(vals$ctd, vals$keep), eos="gsw")
                }
            } else if (vals$plot_style == 2) {
                if (vals$show_all) {
                    plotScan(vals$ctd, type="p", pch=20, col=ifelse(vals$keep, "black", "red"), cex=2/3)
                } else {
                    plotScan(subset(vals$ctd, vals$keep), type="p", pch=20, cex=2/3)
                }
            } else {
                stop("unknown plot_style=", vals$plot_style)
            }
        } else {
            plot(0:1, 0:1, xlab="", ylab="", axes=FALSE, type="n")
            text(0.5, 0.5, "Please choose a CTD file")
        }
    }, height=800)
    ##> output$excluded <- renderText({
    ##>     if (length(vals$keep))
    ##>         paste("Indices: ", paste(which(!vals$keep), collapse=" "))
    ##> })
    observeEvent(input$file, {
        vals$filename <- input$file$name
        vals$ctd <- read.oce(input$file$datapath)
        vals$keep <- rep(TRUE, length(vals$ctd[["pressure"]]))
    })
    observeEvent(input$selected_good, {
        df <- if (vals$plot_style == 1) {
                  data.frame(x=vals$ctd[["SA"]], y=vals$ctd[["CT"]])
              } else if (vals$plot_style == 2) {
                  data.frame(x=vals$ctd[["scan"]], y=vals$ctd[["pressure"]])
              } else {
                  stop("unknown plot_style=", vals$plot_style)
              }
        res <- brushedPoints(df, input$plot_brush, "x", "y", allRows=TRUE)
        vals$keep[res$selected_] <- TRUE
    })
    observeEvent(input$selected_bad, {
        df <- if (vals$plot_style == 1) {
                  data.frame(x=vals$ctd[["SA"]], y=vals$ctd[["CT"]])
              } else if (vals$plot_style == 2) {
                  data.frame(x=vals$ctd[["scan"]], y=vals$ctd[["pressure"]])
              } else {
                  stop("unknown plot_style=", vals$plot_style)
              }
        res <- brushedPoints(df, input$plot_brush, "x", "y", allRows=TRUE)
        vals$keep[res$selected_] <- FALSE
    })


    ##> observeEvent(input$exclude_reset, {
    ##>              vals$keep <- TRUE | vals$keep
    ##> })
    observeEvent(input$plot_style, {
        vals$plot_style <- input$plot_style
    })
    observeEvent(input$show_all, {
        vals$show_all <- input$show_all
    })
    observeEvent(input$save_file, {
        ctd <- vals$ctd
        ctd[["salinityFlag"]] <- ifelse(vals$keep, 2, 4)
        ctd[["temperatureFlag"]] <- ifelse(vals$keep, 2, 4)
        ctd[["pressureFlag"]] <- ifelse(vals$keep, 2, 4)
        oname <- gsub("^(.*)\\.(.*)$", "\\1_edited.rda", vals$filename)
        save(ctd, file=oname)
        print(paste0("Saved to local file '", oname, "'"))
    })
})
