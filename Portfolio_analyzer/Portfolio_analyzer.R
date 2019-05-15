library(shiny)
library(shinydashboard)
library(tidyr)
library(DT)
library(RMariaDB)
library(DBI)
library(shinythemes)
library(cluster)
library(ggplot2)
library(fpc)
library(glue)

con <- dbConnect(RMariaDB::MariaDB(), host = "localhost",
                 user = "root", password = "sql123", dbname = "project") 
industries <- c('Electronics','Automotive','Chemical','Financial','Energy',
  'Transportation','Leisure and Recreation Products','Retail','Medical',
  'Internet','Mining','Computer','Chemical - Specialty','Consulting Services',
  'Oil and Gas','Household Appliances','Technology Services','Hotels and Motels',
  'Textile','Fertilizers','Waste Removal Services','Leisure and Recreation Services',
  'Paper and Related Products','Real Estate','Business','Communication',
  'Manufacturing','Instruments - Control','Building Products','Utility - Water Supply')

#########################################################################
#########################################################################

ui <- dashboardPage(skin = "red",
  dashboardHeader(title = "Portfolio Management"),
  dashboardSidebar(
    sidebarMenu(
              # Setting id makes input$tabs give the tabName of currently-selected tab
              id = "tabs",
              menuItem("Create", tabName = "insert_tab", icon = icon("list")),
              menuItem("Read initial data", tabName = "read_tab1", icon = icon("bar-chart-o")),
              menuItem("Display user selected data", tabName = "read_tab2", icon = icon("bar-chart-o")),
              menuItem("Update", tabName = "update_tab", icon = icon("refresh")),
              menuItem("Delete", tabName = "delete_tab", icon = icon("anchor"))
              )
  ),
  dashboardBody(
    tabItems(
          tabItem(tabName = "insert_tab", 
                  fluidRow(theme =  shinytheme("united"),
                    h2("Customer Details"),
                    textInput('UID', "User ID",'1' ),
                    textInput("FirstName", "First Name", "James"),
                    textInput("Surname", " Surname", "Smith"),
                    textInput("age", "Age", "58"),
                    textInput("job","Job title", "management"),
                    textInput('marital','Marital Status','married'),
                    textInput('education', 'Education Level', 'tertiary'),
                    actionButton("Button_to_insert", "Insert data"),
                    h2("Report of data from Customer table after insertion"),
                    DT::dataTableOutput("mytable")
                    )),
          tabItem(tabName = "read_tab1", style = "background-color: #d4f8e2;",
                  fluidPage(theme =  shinytheme("united"),
                    h2("Display all industries"),
                    actionButton("Button_to_read1", "Display"),
                    DT::dataTableOutput("read_table"),
                    h2("Bar plot of P/E ratios of all industries"),
                    plotOutput("barplotall"),
                    h2("Scatterplot of all industries by Market Cap and P/E"),
                    plotOutput("plotselect",
                               # Equivalent to: click = clickOpts(id = "plot_click")
                               click = "plot_click",
                               dblclick = dblclickOpts(
                                 id = "plot_dblclick")
                  ),
                  fluidRow(theme =  shinytheme("united"),
                    column(width = 3,
                           verbatimTextOutput("click_info")
                    ),
                    column(width = 3,
                           verbatimTextOutput("dblclick_info")
                    ),
                    column(width = 3,
                           verbatimTextOutput("hover_info")
                    ),
                    column(width = 3,
                           verbatimTextOutput("brush_info")
                    )
                  )
                  
                  
                  
                  )),
          tabItem(tabName = "read_tab2", style = "background-color: #f8e5d4;",
                  fluidRow(theme =  shinytheme("united"),
                      h2("Select Industries"),
                      selectizeInput('IndustryName','IndustryName', choices = industries, multiple = TRUE),
                      actionButton("Button_to_read2", "Select"),
                      DT::dataTableOutput("read_table2"),
                    
                      # h2("Cluster plot of selection"),
                      # #actionButton("Button_to_display", "Display Clusters"),
                      # plotOutput("clusterplot"),
                      
                      h2("Scatterplot of all industries by Market Cap and P/E"),
                      plotOutput("clusterplot",
                                 # Equivalent to: click = clickOpts(id = "plot_click")
                                 click = "plot_click1",
                                 dblclick = dblclickOpts(
                                   id = "plot_dblclick1")
                      ),
                      fluidRow(theme =  shinytheme("united"),
                        column(width = 3,
                               verbatimTextOutput("click_info1")
                        ),
                        column(width = 3,
                               verbatimTextOutput("dblclick_info1")
                        ),
                        column(width = 3,
                               verbatimTextOutput("hover_info1")
                        ),
                        column(width = 3,
                               verbatimTextOutput("brush_info1")
                        )
                      ),
                   
                    
                      h2("Barplot of industry risk"),
                      #actionButton("Button_to_display", "Display Barplot"),
                      plotOutput("barplot")
                    )),
          tabItem(tabName = "update_tab", 
                   fluidPage(
                     h2("Page for Update"),
                     textInput("UID_update", "UID", "Default"),
                     textInput("Surname_update", "Surname", "Default"),
                     actionButton("Button_to_update", "Update"),
                     h2("Customer table after updation"),
                     DT::dataTableOutput("update_table")                    
                     )),
           tabItem(tabName = "delete_tab",
                   fluidPage(
                     h2("Page for Delete"),
                     textInput("UID_Delete", "UID", "Default Name"),
                     actionButton("Button_to_delete", "Delete"),
                     h2("Customer table after deletion"),
                     DT::dataTableOutput("read_table_deleted")
                     ))
          
    )
  )
)

#############################Server######################################
#########################################################################

server <- function(input, output) {
  
  observeEvent(input$Button_to_insert, {
    query <- paste("insert into customer values('",  input$UID ,"' , '", input$FirstName,"' , '", input$Surname, "',
                   '",  input$age ,"','",  input$job ,"','",  input$marital ,"','",  input$education ,"');")
    print(query)
    dbExecute(con, query)
    
    output$mytable = DT::renderDataTable({
      query <- paste("SELECT * FROM customer")
      dbGetQuery(con, query)
    })

  })
#**********************General information-all in one******************
#**********************************************************************
  observeEvent(input$Button_to_read1, {
    query = paste("SELECT m.stockid, m.stockcode,S.Industry, `Dividend Yield`, `Price Movers: 1 Week`,`Price Movers: 4 Week`,
                  `Current Year change`, `Next Year change`, `Market Cap`, `P/E`,
                  `Projected Earnings Growth (1 Yr)`, `Projected Earnings Growth (3-5 Yrs)`
                  FROM metrics m inner join stock s on
                  m.StockID = S.StockID inner join industry i on i.IndustryID = S.IndustryID
                  group by S.Industry ")
    group_table = dbGetQuery(con, query)
    output$read_table = DT::renderDataTable({group_table})
    output$barplotall <- renderPlot(({ barplot(group_table[,'P/E'], data = group_table,names.arg = group_table[,'Industry'], main='P/E Ratio of different industries',xlab='Industry name', ylab='P/E Ratio', las=2)
      text(group_table[,'Industry'], labels=group_table[,'Industry'], pos=3)
      }))
   # output$plotselect <- renderPlot(({ ggplot(group_table)+geom_point(aes('Market Cap','P/E')) }))
    output$plotselect <- renderPlot(({dat1 <- group_table[,c('Market Cap', 'P/E')]
    k.dat1 <- kmeans(dat1,centers = 3)
    plotcluster(dat1, k.dat1$cluster,color=TRUE, shade=TRUE,lines=0, xlab='Market Cap', ylab='P/E')}))
    output$click_info <- renderPrint({
      cat("input$plot_click:\n")
      str(input$plot_click)
    })
    output$hover_info <- renderPrint({
      cat("input$plot_hover:\n")
      str(input$plot_hover)
    })
    output$dblclick_info <- renderPrint({
      cat("input$plot_dblclick:\n")
      str(input$plot_dblclick)
    })
    output$brush_info <- renderPrint({
      cat("input$plot_brush:\n")
      str(input$plot_brush)
    })
   
  })
  
#**********************User selected industires*****************************
#***************************************************************************
  observeEvent(input$Button_to_read2, {
    industry_selected <- stringr::str_c(stringr::str_c("'",input$IndustryName,"'"), collapse = ',')
    query = glue("SELECT m.stockid, m.stockcode, `Dividend Yield`, `Price Movers: 1 Week`,`Price Movers: 4 Week`,
                  `Current Year change`, `Next Year change`, `Market Cap`, `P/E`,
                  `Projected Earnings Growth (1 Yr)`, `Projected Earnings Growth (3-5 Yrs)`
                  FROM metrics m inner join stock s on
                  m.StockID = S.StockID inner join industry i on i.IndustryID = S.IndustryID
                  WHERE trim(IndustryName) IN ({industry_selected})")
    
    output$read_table2 = DT::renderDataTable({
      dbGetQuery(con, query)
    })
    #************Bar plot*************************************************************
    output$barplot <- renderPlot(({
      query2 = glue("SELECT s.Industry,m.`P/E` FROM metrics m inner join stock s on
                 m.StockID = S.StockID inner join industry i on i.IndustryID = S.IndustryID
                 WHERE IndustryName IN ({industry_selected}) group by IndustryName")
      
      group_table = dbGetQuery(con, query2)
      barplot(group_table[,'P/E'], data = group_table,names.arg = group_table[,'Industry'], main='P/E Ratio of different industries',xlab='Industry name', ylab='P/E Ratio', las=2)
      
    }))
    
    #************Cluster plot*********************************************************    
    output$clusterplot <- renderPlot(({
      #browser()
      industry_selected <- stringr::str_c(stringr::str_c("'",input$IndustryName,"'"), collapse = ',')
      query = glue("SELECT s.Industry,m.`P/E`,m.`Market Cap` FROM metrics m inner join stock s on
                 m.StockID = S.StockID inner join industry i on i.IndustryID = S.IndustryID
                 WHERE IndustryName IN ({industry_selected})")
      
      group_table = dbGetQuery(con, query)
      data_to_cluster = group_table[,2:3]
      k1 <- kmeans(data_to_cluster, centers = 3)
      plotcluster(data_to_cluster, k1$cluster,color=TRUE, shade=TRUE,lines=0,xlab='Market Cap', ylab='P/E')
      output$click_info1 <- renderPrint({
        cat("input$plot_click:\n")
        str(input$plot_click1)
      })
      output$hover_info1 <- renderPrint({
        cat("input$plot_hover:\n")
        str(input$plot_hover1)
      })
      output$dblclick_info1 <- renderPrint({
        cat("input$plot_dblclick:\n")
        str(input$plot_dblclick1)
      })
      output$brush_info1 <- renderPrint({
        cat("input$plot_brush:\n")
        str(input$plot_brush1)
      })
    }))
})
  
  
  observeEvent(input$Button_to_update, {
    query <- paste("update Customer set Surname = '", input$Surname_update,"' where UID ='", input$UID_update,"';", sep = "")
    dbExecute(con,query)
    
    output$update_table = DT::renderDataTable({
      query <- paste("SELECT * FROM Customer")  
      dbGetQuery(con, query)
    })
  })
  
  observeEvent(input$Button_to_delete, {

    query <- paste("Delete from Customer where UID = '",  input$UID_Delete ,"'")
    print(query)
    dbExecute(con, query)

    output$read_table_deleted = DT::renderDataTable({
      query <- paste("SELECT * FROM Customer")
      dbGetQuery(con, query)
    })

  })
}

shinyApp(ui, server)