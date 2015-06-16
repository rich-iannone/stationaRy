#' Get time zone offset from GMT
#' @description Obtain the time zone difference in hours between GMT and a
#' provided location.
#' @param x coordinate in the x direction.
#' @param y coordinate in the y direction.
#' @param proj4str an optional PROJ.4 string for the provided coordinates;
#' not providing a value assumes lat/lon coordinates.
#' @import proj4
#' @import sp
#' @export get_tz_offset

get_tz_offset <- function(x, y, proj4str = ""){
  
  if (inherits(x, "SpatialPoints")){
    coords <- as.data.frame(x)
  } else {
    x <- as.matrix(x)
    if (!missing(y)){
      coords <- cbind(x, y)
    } else {
      coords <- x
    }
  }
  
  if (proj4str != ""){
    coords <- project(coords, proj4str, inverse = TRUE)
  }
  
  world_tz_shapes <- "world_tz_shapes"
  
  load(system.file("time_zones.rda", package = "stationaRy"))
  
  zone_ids <- as.character(world_tz_shapes@data[,1])
  
  coords <- SpatialPoints(coords, proj4string = CRS(proj4str))
  
  tz_olson_name <- coords %over% world_tz_shapes
  
  tz_offset <- 
    as.numeric(ymd_hm("197001010000", tz = "GMT") - 
                 ymd_hm("197001010000", tz = as.character(tz_olson_name$TZID[1])))
  
  return(tz_offset)
}
