

dir_create2 <- function(path, ...){
  if (dir.exists(path)) {
    return(FALSE)
  } else {
    dir.create(path, ...)
    return(TRUE)
  }
}