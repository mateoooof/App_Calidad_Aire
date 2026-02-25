library(openair)

plot_time_variation <- function(data, pollutant){
  timeVariation(data,pollutant = pollutant)
}

plot_pollution_rose <- function(data, pollutant){
  pollutionRose(data, pollutant = pollutant)
}

plot_correlation <- function (data){
  corPlot(data)
}
