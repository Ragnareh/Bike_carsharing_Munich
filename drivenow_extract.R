Sys.setlocale("LC_CTYPE", "German")

require(jsonlite)

setwd("d:/Projects/Carsharing/datasets/drivenow-muc")

  filename <- "muc-2016-09-26T08_55_00+0200.json"
  
  json_data <- fromJSON(filename)
  
  available_vehicles_df <- json_data$cars$items
  parking_vehicles_df <- as.data.frame(json_data$parkingSpaces$items$cars$items)

  str(available_vehicles_df)
  available_vehicles_df$address
  #paste(available_vehicles_df$address,collapse=', ')
  available_vehicles_df$estimatedRange
  available_vehicles_df$fuelLevel
  available_vehicles_df$group
  available_vehicles_df$id
  available_vehicles_df$name
  available_vehicles_df$licensePlate
  available_vehicles_df$isCharging
  available_vehicles_df$isInParkingSpace
  available_vehicles_df$latitude
  available_vehicles_df$longitude
  available_vehicles_df$modelName
  available_vehicles_df$rentalPrice$drivePrice$amount
  available_vehicles_df$rentalPrice$drivePrice$currencyUnit
  available_vehicles_df$rentalPrice$parkPrice$amount
  available_vehicles_df$rentalPrice$parkPrice$currencyUnit
  available_vehicles_df$rentalPrice$paidReservationPrice$amount
  available_vehicles_df$rentalPrice$paidReservationPrice$currencyUnit
  available_vehicles_df$transmission
  
  
  str(parking_vehicles_df)
  parking_vehicles_df$address
  #paste(available_vehicles_df$address,collapse=', ')
  parking_vehicles_df$estimatedRange
  parking_vehicles_df$fuelLevel
  parking_vehicles_df$group
  parking_vehicles_df$id
  parking_vehicles_df$name
  parking_vehicles_df$licensePlate
  parking_vehicles_df$isCharging
  parking_vehicles_df$isInParkingSpace
  parking_vehicles_df$latitude
  parking_vehicles_df$longitude
  parking_vehicles_df$modelName
  parking_vehicles_df$rentalPrice$drivePrice$amount
  parking_vehicles_df$rentalPrice$drivePrice$currencyUnit
  parking_vehicles_df$rentalPrice$parkPrice$amount
  parking_vehicles_df$rentalPrice$parkPrice$currencyUnit
  parking_vehicles_df$rentalPrice$paidReservationPrice$amount
  parking_vehicles_df$rentalPrice$paidReservationPrice$currencyUnit
  parking_vehicles_df$transmission
  
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

