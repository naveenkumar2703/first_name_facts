
# This is the server logic for a Shiny web application.
# This server logic file populates facts and plots about a queried name.
# Stats are pre computed and stored in rds file for better performance. 
# There is no need for real time computing as the data is published on annual basis.
# Author: Naveenkumar Ramaraju
#


library(shiny)
library(tidyr)
# loading precomputed data
name_stat <- readRDS("data/name_stat.rds") 
name_stat$Trend <- as.character(name_stat$Trend) # rectifying a data type issue
name_stat_by_year <- readRDS("data/name_stat_by_year.rds")
given_names <- name_stat$Name # getting unique list of names

# This function capitalizes the first letter. "JO","joe" and "jOeY" will be converted to Jo, Joe and Joey respectively
capitalize_first <- function(word) {
  if (is.na(word)) NA
  else{
  substr(word, 1, 1) <- toupper(substr(word, 1, 1))
  word
  }
}

# This function validates whether typed name is valid by checking with unique names list
validate_name <- function(typed_name_lower) {
  if (typed_name_lower %in% given_names) typed_name_lower
  else NA
}

# This function generates a welcome text, if the name is present in data source.
get_name_text <- function(person_name){
  
  if (is.na(person_name)){
    'Your name is not available in the data source. Maybe your name is very unique or check for typo in your name.'
  }
  else{
    paste('Hello, Here is some information about the name: ',person_name)
  }
}

# This function creates a fact table for a validated name from pre computed data.
get_name_facts <- function(person_name){
  if (is.na(person_name)){
    df <- data.frame(c('No information available to display.'))
    colnames(df) <- c('Warning')
    df
  }
  else {
    curr_name_stat <- name_stat[name_stat$Name == person_name,]
    capitalized_name <- capitalize_first(person_name)
    df <- data.frame(c('Name','Feminine Index','Masculine Index', 'Uniqueness','Other people who share(d) your name','Most number of names given in the year','Gaining Popularity', 'Number of years name was given since 1910', 'Continuous number of years for which the name was active',
                       'Most popular in the year', 'Notable trend', paste0('Percentage of population named ', capitalized_name, ' when named last')),
                     c(capitalized_name,curr_name_stat$female_gender_ratio, curr_name_stat$male_gender_ratio, curr_name_stat$uniqueness, curr_name_stat$Names_sharred_by,curr_name_stat$Most_Popular_Year, curr_name_stat$Gaining_Popularity, curr_name_stat$active_years, curr_name_stat$max_active_year_streak,
                       curr_name_stat$Most_Popular_Year, curr_name_stat$Trend,  paste0(as.character(100 * curr_name_stat$current_popularity_rank),' %') ))
    colnames(df) <- c('Attribute','Value')
    df
  }
}

# This function creates a trend plot for a validated name from pre computed data.
plot_name_trend <- function(validated_name, typed_text){
  if (is.na(validated_name)){
    plot(1, type="n", axes=T, xlab="Year", xlim = c(1910,2016),ylab=paste0("Numer of people named ", typed_text), sub = paste0('Trend of name ',typed_text,' over years.'))
  }
  else {
    data_to_plot <- name_stat_by_year[name_stat_by_year$Name == validated_name,c('Gender','Year', 'Occurrences')] %>% spread(key='Gender', value='Occurrences')
    plot(data_to_plot$Year,data_to_plot$F,type="l",col="hotpink", xlab="Year", xlim = c(1910,2016),ylim = c(0,max(max(data_to_plot$F, na.rm = TRUE),max(data_to_plot$M, na.rm = TRUE))),ylab=paste0("Numer of people named ", typed_text), sub = paste0('Trend of name ',typed_text,' over years.'))
    lines(data_to_plot$Year,data_to_plot$M,type="l",col="blue")
    legend('topright', c('Female', 'Male') , lty=1, col=c('hotpink', 'blue'), bty='n', cex=.75)
  }
}

# This is actual server function which is invoked on user interaction and wraps other methods.
# Duplicate validation is difficult to avoid due to reactivity nature in R. There could be a better way.
shinyServer(function(input, output) {
   given_names <- name_stat$Name
   output$welcome_address <- renderText(get_name_text(capitalize_first(validate_name(tolower(input$name)))))
   output$name_facts <- renderTable({get_name_facts(validate_name(tolower(input$name)))})
   output$trend_plot <- renderPlot({plot_name_trend(validate_name(tolower(input$name)),input$name)})
})
