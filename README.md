# Portfolio_analyzer-Shiny

## Description
A shiny app that analyzes the porfolio of a hypothetical user. This is a simple app showcasing how a user can use publicly available data to analyze a portfolio of investments.

Financial data for 500 companies can be overwhelming to make an investment decision. To make the process more intuitive and user friendly I built an app that can be used by an end user through the already popular actions of click, select and slide to give them a visual representation of their decisions. The goal is to bring the power of decision-making ability closer to the user by simplifying the obscurity that a plethora of data represents.

Goals of project :
1. Historical trend view to review the past performance of stocks
2. Clustering analysis for portfolio diversification
3. Scatter plot of P/E ratio and market capitalization
4. Bar chart of P/E ratio of based on chosen industries
5. Allow the user to select a bunch of stocks based on the key metrics to see what the average return was in last 3 months, 6 months, 9 months and 2 years. Allow
customers to see how risky their portfolio is through various metrics.

## Data 
Financial data was collected from Yahoo finance. The companies listed in the S&P 500 represent a wide exposure to different industry sectors such as Technology, Finance, Healthcare, Energy etc. For the purpose of display a sample database for 10 companies which are a part of the S&P 500 for two years. A centralized database was built using the data. This database served as the basis of the application.


## Getting Started
![Dashboard setup of the app](relative/path/to/img.jpg?raw=true "Dashboard")


### Dependencies

* Checked it runs on Windows 10. 
* Requires R studio.

R libraries:
* library(RMySQL)
* library(shiny)
* library(shinydashboard)
* library(tidyr)
* library(DT)
* library(RMariaDB)
* library(DBI)
* library(shinythemes)
* library(cluster)
* library(ggplot2)
* library(fpc)
* library(glue)

### Installing

* Clone the repo, launch the Portfolio_analyzer.R file. 
* All the data and the source file need to be in the same directory

### Executing program

* ![Alt text](relative/path/to/img.jpg?raw=true "How to launch the app")
Click on the 'Run App' button on R studio to run the program
```
code blocks for commands
```
