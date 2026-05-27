#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Dashboard la Vague"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Accueil", tabName = "home")
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "home",
        fluidRow(infoBox("Fix", 42, icon = icon("info")))
      ),
      
      tabItem(
        tabName = "otherPage"
      )
    )
  )
)
