library(yulab.utils)

svg2png <- function(path, options) {
  if (!grepl('[.]svg$', path)) {
    return(path)
  }

  if (file.size(path) / 1000000 < 1.2) {
    ## less than 1.2M
    return(path)
  }
  output <- sub(".svg$", ".png", path)
  system2("convert", paste("-density 150", path, output))
  file.remove(path)
  return(output)
}


library(knitr)
opts_chunk$set(
  message = FALSE,
  warning = FALSE,
  eval = TRUE,
  echo = TRUE,
  cache = TRUE,
  dev = "svg",
  out.width = "98%" #,
  #fig.process = svg2png
)
