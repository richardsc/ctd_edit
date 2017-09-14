library(shiny)
fluidPage(titlePanel("CTD QC editor"),
          sidebarLayout(sidebarPanel(
              h4("Input"),
              fileInput('file', 'Choose a CTD file'),
              h4("Set flags of selected points"),
              ##> textOutput("excluded"),
              actionButton("selected_good", "Good"),
              actionButton("selected_bad", "Bad"),
              ##actionButton("all_good", "Set all to good"),
              radioButtons("plot_style", label = h4("Plot style"),
                           choices = list("TS" = 1, "Scan" = 2), selected = 2),
              checkboxInput("show_all", "Show all data", FALSE),
              h4("Output"),
              actionButton("save_file", "Save to .rda file")),
              mainPanel(plotOutput("plot", brush="plot_brush"))))

