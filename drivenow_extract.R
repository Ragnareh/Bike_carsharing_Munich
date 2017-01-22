Sys.setlocale("LC_CTYPE", "German")

require(jsonlite)

setwd("d:/Projects/Carsharing/datasets/drivenow-muc")

  filename <- "muc-2016-09-26T08_55_00+0200.json"
  
  json_data <- fromJSON(filename)
  
  available_vehicles_df <- json_data$cars$items
  parking_vehicles_df <- as.data.frame(json_data$parkingSpaces$items$cars$items)
  full_df <- rbind(available_vehicles_df, parking_vehicles_df)

  if (length(available_vehicles_df) > 0) {
    vehicles_df <- data.frame(
      filename = substr(filename, 14, 32),
      name = available_vehicles_df$name,
      fuelLevel = available_vehicles_df$fuel, 
      address = available_vehicles_df$address,
      engineType = available_vehicles_df$engineType,
      exterior = available_vehicles_df$exterior,
      interior = available_vehicles_df$interior,
      vin = available_vehicles_df$vin,
      smartphoneRequired = available_vehicles_df$smartPhoneRequired   
    )
    
    coordinates <- as.data.frame(available_vehicles_df$coordinates)
    coordinates <- t(coordinates)
    colnames(coordinates)<-c("lng", "lat", "Column3")
    coordinates <- as.data.frame(coordinates)
    
    vehicles_df$lat <- coordinates$lat
    vehicles_df$lng <- coordinates$lng
    
    write.table(vehicles_df, "all_vehicles_df.csv", col.names=FALSE, row.names = FALSE, sep=",",append = TRUE)

}

