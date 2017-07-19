
# This is the user-interface definition of a Shiny web application.
# The logic to build and display ui components for First name facts is coded in this file.
# Author: Naveenkumar Ramaraju


library(shiny)

shinyUI(fluidPage(

  # Application title - with word cloud image
  # Word cloud image on page title is precomputed and stored as png with app name. Computing word cloud every time is an overkill.
  titlePanel(title=div(img(src="wc.png",height = 175, width = 175), "Learn facts about your first name")),

  # Sidebar to capture name of the person
  sidebarPanel(
    textInput("name", "Name:", "Enter your first name"), # text input to get user input
    helpText("Funfact: 6% of males are either James or John in US."), # some fun facts pre computed using analysis.
    helpText("Name-Inequality: Roughly 95% of people were named with just 5% of names in US?"),
    helpText("Facts shown in this webpage is consolidated based on data from SSA database from 1910 to 2016"),
    helpText(a("Source",href="http://www.ssa.gov/oact/babynames/state/namesbystate.zip"))
  ),

    # Show a plot of the generated distribution
    mainPanel(
      textOutput("welcome_address"), # displays welcome address
      h5("Name Facts"),
      tableOutput("name_facts"), # displays table
      h5("Name Trend"),
      plotOutput("trend_plot", height = "600px") # displays graph
    )
))
