
### TODO
# -------------------------------------------------------------------------
# Filter table on PMID
# Text search for article titles




# Load packages, function and data ----------------------------------------

library(shiny)
library(shinyjs)
library(DT)
library(tidyverse)
library(plotly)

full_data <- read_tsv("data/fulldata_20201109.txt", col_types = cols()) %>%
  mutate(PMID = as.character(PMID))

import::from("functions/conditional_filter.R", conditional_filter)




# Define shiny UI -------------------------------------------------------

ui <- fluidPage(

  # Select the Bootswatch3 theme "Readable": https://bootswatch.com/3/readable
  theme = "css/readablebootstrap.css",

  # Link to custom CSS tweaks and some JS
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/user.css")
  ),

  # Enable shinyjs usage (tab reset buttons)
  useShinyjs(),

  # Using shinyjs to allow the reset buttons to also reset "plotly_click" by
  # setting it to NULL (initial value). Check the "www" directory for the
  # indicated file & function.
  extendShinyjs(
    script = "functions.js",
    functions = c("resetClick")
  ),


  ### Begin the navbarPage that serves as the basis for the app
  navbarPage(
    id = "navbar",

    # Determines the page title in the user's browser
    windowTitle = "SeptiSearch",

    # Custom nested divs for the title, so we can have the Github logo on the
    # right side of the navbar, linking to the Github page! See "user.css" for
    # the custom class being used for the image.
    title = div(

      # Actual title displayed on the left side of the navbar
      tags$b("SeptiSearch"),

      # Div containing the github logo for the right side of the navbar
      tags$div(
        id = "img-id",
        htmltools::HTML(paste0(
          "<a href='https://github.com/hancockinformatics/curation'> ",
          "<img src = 'github.svg'> </a>"
        ))
      )
    ),



    ##########
    ## Home ##
    ##########
    tabPanel(
      value = "home_tab",
      icon  = icon("home"),
      title = "Home",

      tags$div(
        class = "jumbotron",

        h1("Welcome"),

        tags$hr(),

        tags$div(tags$p(
          "Welcome text will go here!"
        )),

        tags$br(),

        # Provide a direct link to the "About" page
        actionButton(
          inputId = "learn_more",
          label   = "Learn more",
          class   = "btn btn-primary btn-lg"
        )
      ),

      # Separate div to include the lab logo in the bottom-left corner
      tags$div(
        style = "position:fixed; bottom:0px; padding-bottom: 10px",
        htmltools::HTML(paste0(
          "<a href='http://cmdr.ubc.ca/bobh/'> ",
          "<img src = 'hancock-lab-logo.svg'> </a>"
        ))
      )
    ),


    #############################
    ## Explore Data in a Table ##
    #############################
    tabPanel(
      value = "table_tab",
      icon  = icon("table"),
      title = "Explore Data in a Table",

      sidebarLayout(
        sidebarPanel = sidebarPanel(
          id = "tab1_sidebar",
          width = 3,

          checkboxGroupInput(
            inputId  = "tab1_molecule_type_input",
            label    = "Refine the data by molecule type:",
            choices  = unique(full_data$`Molecule Type`)
          ),

          tags$hr(),

          tags$p(
            "You can also provide a list of genes or other molecules to ",
            "filter the table (one per line):"
          ),

          # Area for the user to input their own genes to filter the data
          textAreaInput(
            inputId     = "pasted_molecules",
            label       = NULL,
            placeholder = "Your genes here...",
            height      = 200
          ),

          tags$hr(),

          # UI for the download button
          tags$p("Download the current table (tab-delimited):"),
          downloadButton(
            outputId = "table_download_handler",
            style    = "width: 170px",
            label    = "Download data",
            class    = "btn-primary"
          ),

          tags$hr(),

          # Reset button for the tab (from shinyjs)
          actionButton(
            class   = "btn-info",
            style   = "width: 170px",
            inputId = "tab1_reset",
            icon    = icon("undo"),
            label   = "Restore defaults"
          )
        ),

        mainPanel = mainPanel(
          width = 9,
          uiOutput("table_molecules_render")
        )
      )
    ),


    ###################################
    ## Visualize Molecule Occurrence ##
    ###################################
    tabPanel(
      value = "vis_tab",
      icon  = icon("chart-bar"),
      title = "Visualize Molecule Occurrence",

      sidebarLayout(
        sidebarPanel = sidebarPanel(
          id = "tab2_sidebar",
          width = 3,

          # Input molecule type
          checkboxGroupInput(
            inputId  = "tab2_molecule_type_input",
            label    = "Refine the data by molecule type:",
            choices  = unique(full_data$`Molecule Type`)
          ),

          tags$hr(),

          tags$p("You may further filter the data using the fields below:"),

          # Input platform
          selectInput(
            inputId  = "platform",
            label    = "Platform",
            choices  = unique(full_data$Platform),
            multiple = TRUE
          ),

          # Input tissue type
          selectInput(
            inputId  = "tissue",
            label    = "Tissue type",
            choices  = unique(full_data$Tissue),
            multiple = TRUE
          ),

          # Input infection source
          selectInput(
            inputId  = "infection",
            label    = "Infection source",
            choices  = unique(full_data$Infection),
            multiple = TRUE
          ),

          # Input case condition
          selectInput(
            inputId  = "case",
            label    = "Case condition",
            choices  = unique(full_data$`Case Condition`),
            multiple = TRUE
          ),

          # Input control condition
          selectInput(
            inputId  = "control",
            label    = "Control condition",
            choices  = unique(full_data$`Control Condition`),
            multiple = TRUE
          ),

          # Input age group
          selectInput(
            inputId  = "age",
            label    = "Age group",
            choices  = unique(full_data$`Age Group`),
            multiple = TRUE
          ),

          tags$hr(),

          # Reset button for the tab
          actionButton(
            class   = "btn-info",
            style   = "width: 170px",
            inputId = "tab2_reset",
            icon    = icon("undo"),
            label   = "Restore defaults"
          )
        ),

        mainPanel = mainPanel(
          width = 9,
          uiOutput("plot_and_click")
        )
      )
    ),


    ###########
    ## About ##
    ###########
    tabPanel(
      value = "about_tab",
      icon  = icon("info-circle"),
      title = "About",

      tags$div(
        class = "jumbotron",

        h1("About"),

        tags$hr(),

        tags$div(
          tags$p(
            "Place information about the app here!"
          )
        )
      ),

      tags$div(
        style = "position: fixed; bottom: 0px; padding-bottom: 10px",
        htmltools::HTML(paste0(
          "<a href='http://cmdr.ubc.ca/bobh/'> ",
          "<img src = 'hancock-lab-logo.svg'> </a>"
        ))
      )
    )
  )
)




# Define the server -----------------------------------------------------

server <- function(input, output, session) {


  ##########
  ## Home ##
  ##########

  # Button that takes you to the "About" page
  observeEvent(input$learn_more, {
    updateNavbarPage(
      session  = session,
      inputId  = "navbar",
      selected = "about_tab"
    )
  }, ignoreInit = TRUE)


  #############################
  ## Explore Data in a Table ##
  #############################

  # Set up reactive value to store molecules from the user
  users_molecules <- reactiveVal()

  observeEvent(input$pasted_molecules, {
    input$pasted_molecules %>%
      str_split(., pattern = " |\n") %>%
      unlist() %>%
      users_molecules()
  }, ignoreNULL = TRUE, ignoreInit = TRUE)


  table_molecules <- reactive({

    # Start with no specification of Molecule Type
    if (length(input$tab1_molecule_type_input) == 0) {

      # Sub-condition for no specified molecules from the user
      if (all(is.null(users_molecules()) | users_molecules() == "")) {
        return(full_data)
        message("Default display.")

        # Sub-condition for user-specified molecules
      } else if (!is.null(users_molecules())) {
        return(full_data %>% filter(Molecule %in% users_molecules()))
        message("All types, user input molecules.")
      }

      # Now we've specified to filter on Molecule Type
    } else if (length(input$tab1_molecule_type_input) != 0) {

      # Sub-condition in which the user hasn't specified any molecules
      if (all(is.null(users_molecules()) | users_molecules() == "")) {
        return(
          full_data %>%
            filter(`Molecule Type` %in% input$tab1_molecule_type_input)
        )

        # Sub-condition for which the user is filtering on Molecule Type and
        # asking for specific molecules
      } else if (!is.null(users_molecules())) {
        return(
          full_data %>% filter(
            Molecule %in% users_molecules(),
            `Molecule Type` %in% input$tab1_molecule_type_input
          )
        )
        message("Specific types, user input molecules.")
      }
    } else {
      return(full_data)
    }
  })

  # Modify the above filtered table, prior to display, to make PMIDs into links
  table_molecules_hyper <- reactive({
    table_molecules() %>%
      mutate(PMID = case_when(
        !is.na(PMID) ~ paste0(
          "<a target='_blank' href='",
          "https://pubmed.ncbi.nlm.nih.gov/",
          PMID, "'>", PMID, "</a>"
        ),
        TRUE ~ PMID
      ))
  })


  # Render the above table to the user, with a <br> at the end to give some
  # space. Also reduce the font size of the table slightly so we can see more
  # of the data at once. "scrollY" is set to 75% of the current view, so we
  # scroll only the table, and not the page.
  output$table_molecules_render <- renderUI({
    tagList(
      tags$div(
        DT::renderDataTable(
          table_molecules_hyper(),
          rownames  = FALSE,
          escape    = FALSE,
          selection = "none",
          options   = list(scrollX = TRUE,
                           scrollY = "75vh",
                           paging  = TRUE)
        ),
        style = "font-size: 12px;"
      ),
      tags$br()
    )
  })


  # Allow the user to download the currently displayed table
  output$table_download_handler <- downloadHandler(
    filename = "septisearch_download.txt",
    content = function(file) {
      write_delim(table_molecules(), file, delim = "\t")
    }
  )


  # Allow the user to "reset" the page to its original/default state
  observeEvent(input$tab1_reset, {
    shinyjs::reset("tab1_sidebar", asis = FALSE)
  })




  ###################################
  ## Visualize Molecule Occurrence ##
  ###################################

  # All the filtering steps make use of the custom `conditional_filter()`
  # function, so we don't need step-wise filtering, while keeping it reactive.
  # We're using `str_detect(col, paste0(input, collapse = "|"))` for
  # string-based filters, so we can easily search for one or more specified
  # inputs.
  filtered_table <- reactive({
    full_data %>% filter(

      # Molecule type
      conditional_filter(
        length(input$tab2_molecule_type_input) != 0,
        `Molecule Type` %in% input$tab2_molecule_type_input
      ),

      # Platform
      conditional_filter(
        length(input$platform) != 0,
        str_detect(Platform, paste(input$platform, collapse = "|"))
      ),

      # Tissue
      conditional_filter(
        length(input$tissue) != 0,
        str_detect(Tissue, paste(input$tissue, collapse = "|"))
      ),

      # Infection
      conditional_filter(
        length(input$infection) != 0,
        str_detect(Infection, paste(input$infection, collapse = "|"))
      ),

      # Case Condition
      conditional_filter(
        length(input$case) != 0,
        str_detect(`Case Condition`, paste(input$case, collapse = "|"))
      ),

      # Control Condition
      conditional_filter(
        length(input$control) != 0,
        str_detect(`Control Condition`, paste(input$control, collapse = "|"))
      ),

      # Age Group
      conditional_filter(
        length(input$age) != 0,
        str_detect(`Age Group`, paste(input$age, collapse = "|"))
      )
    )
  })


  plot_molecules_hyper <- reactive({
    filtered_table() %>%
      mutate(PMID = case_when(
        !is.na(PMID) ~ paste0(
          "<a target='_blank' href='",
          "https://pubmed.ncbi.nlm.nih.gov/",
          PMID, "'>", PMID, "</a>"
        ),
        TRUE ~ PMID
      ))
  })


  # Creating a table to plot the top 100 molecules based on the number of
  # citations
  tab2_plot_table <- reactive({
    filtered_table() %>%
      group_by(Timepoint, Molecule) %>%
      summarize(count = n(), .groups = "drop") %>%
      arrange(desc(count)) %>%
      mutate(Molecule = fct_inorder(Molecule)) %>%
      drop_na(Molecule, Timepoint) %>%
      head(100)
  })

  # Make the plot via plotly, primarily to make use of the "hover text" feature
  output$plot_object <- renderPlotly({
    plot_ly(
      data = tab2_plot_table(),
      x = ~Molecule,
      y = ~count,
      color = ~Timepoint,
      type = "bar",
      hoverinfo = "text",
      text = ~paste0(
        "<b>", Molecule, ":</b> ", count, "<br>"
      )
    ) %>%
      plotly::style(
        hoverlabel = list(bgcolor = "white", bordercolor = "black")
      ) %>%
      plotly::layout(
        title = "<b>Top 100 molecules based on citations</b>",
        margin = list(t = 50),
        showlegend = TRUE,
        legend = list(
          title = list(text = "<b>Timepoint</b>")
        ),
        xaxis = list(
          title = "",
          tickfont = list(size = 12),
          tickangle = "45",
          zeroline = TRUE,
          showline = TRUE,
          mirror = TRUE
        ),
        yaxis = list(
          title = "<b>Number of Citations</b>",
          tick = "outside",
          ticklen = 3,
          zeroline = TRUE,
          showline = TRUE,
          mirror = TRUE
        ),
        font = list(size = 16, color = "black")
      )
  })


  output$click <- DT::renderDataTable({
    d <- event_data("plotly_click", priority = "event")

    if (is.null(d)) {
      return(NULL)
    } else {
      plot_molecules_hyper() %>%
        filter(Molecule == d$x)
    }
  },
  rownames  = FALSE,
  escape    = FALSE,
  selection = "none",
  options   = list(scrollX = TRUE,
                   scrollY = "40vh",
                   paging  = TRUE)
  )



  output$plot_and_click <- renderUI({
    tagList(
      plotlyOutput("plot_object", inline = TRUE, height = "300px"),
      tags$h4("Click a bar to see all entries for that molecule:"),
      tags$div(
        DT::dataTableOutput("click"),
        style = "font-size: 12px"
      )
    )
  })



  # Allow the user to "reset" the page to its original/default state
  observeEvent(input$tab2_reset, {
    js$resetClick()
    shinyjs::reset(id = "tab2_sidebar", asis = FALSE)
  })
}




shinyApp(ui, server, options = list(launch.browser = TRUE))
