Sys.setlocale("LC_CTYPE", "German")

require(jsonlite)

setwd("d:/Projects/Carsharing/datasets/drivenow-muc")

files <- list.files(pattern = ".json")

all_vehicles_df <- data.frame(
  filename = character(0),
  id = character(0),
  name = character(0),
  licensePlate = character(0),
  group = character(0),
  modelName = character(0),
  transmission = character(0),
  #address = character(0),
  latitude = character(0),
  longitude = character(0),
  isCharging = character(0),
  isInParkingSpace = character(0),
  fuelLevel = character(0),
  estimatedRange = character(0),
  drivePriceAmount = character(0),
  drivePriceCurr = character(0),
  parkPriceAmount = character(0),
  parkPriceCurr = character(0),
  paidReservationPriceAmount = character(0),
  paidReservationPriceCurr = character(0)
)

write.table(all_vehicles_df, "all_vehicles_df.csv", col.names=TRUE, row.names = FALSE, sep=",")

for (fileCount in seq_along(files)) {
  
  filename <- files[fileCount]
  
  #print progress
  print(paste(fileCount," -- ",filename))
  
  json_data <- fromJSON(filename)
  
  available_vehicles_df <- json_data$cars$items
  parking_vehicles_df <- as.data.frame(json_data$parkingSpaces$items$cars$items)
  #paste(available_vehicles_df$address,collapse=' ')
  
  if (length(available_vehicles_df) > 0) {
    car_df <- data.frame(
      filename = substr(filename, 5, 23),
      id = available_vehicles_df$id,
      name = available_vehicles_df$name,
      licensePlate = available_vehicles_df$licensePlate,
      group = available_vehicles_df$group,
      modelName = available_vehicles_df$modelName,
      transmission = available_vehicles_df$transmission,
      #address = available_vehicles_df$address,
      latitude = available_vehicles_df$latitude,
      longitude = available_vehicles_df$longitude,
      isCharging = available_vehicles_df$isCharging,
      isInParkingSpace = available_vehicles_df$isInParkingSpace,
      fuelLevel = available_vehicles_df$fuelLevel,
      estimatedRange = available_vehicles_df$estimatedRange,
      drivePriceAmount = available_vehicles_df$rentalPrice$drivePrice$amount,
      drivePriceCurr = available_vehicles_df$rentalPrice$drivePrice$currencyUnit,
      parkPriceAmount = available_vehicles_df$rentalPrice$parkPrice$amount,
      parkPriceCurr = available_vehicles_df$rentalPrice$parkPrice$currencyUnit,
      paidReservationPriceAmount = available_vehicles_df$rentalPrice$paidReservationPrice$amount,
      paidReservationPriceCurr = available_vehicles_df$rentalPrice$paidReservationPrice$currencyUnit
    )
    
    if (length(parking_vehicles_df) > 0) {
      parking_df <- data.frame(
        filename = substr(filename, 5, 23),
        id = parking_vehicles_df$id,
        name = parking_vehicles_df$name,
        licensePlate = parking_vehicles_df$licensePlate,
        group = parking_vehicles_df$group,
        modelName = parking_vehicles_df$modelName,
        transmission = parking_vehicles_df$transmission,
        #address = parking_vehicles_df$address,
        latitude = parking_vehicles_df$latitude,
        longitude = parking_vehicles_df$longitude,
        isCharging = parking_vehicles_df$isCharging,
        isInParkingSpace = parking_vehicles_df$isInParkingSpace,
        fuelLevel = parking_vehicles_df$fuelLevel,
        estimatedRange = parking_vehicles_df$estimatedRange,
        drivePriceAmount = parking_vehicles_df$rentalPrice$drivePrice$amount,
        drivePriceCurr = parking_vehicles_df$rentalPrice$drivePrice$currencyUnit,
        parkPriceAmount = parking_vehicles_df$rentalPrice$parkPrice$amount,
        parkPriceCurr = parking_vehicles_df$rentalPrice$parkPrice$currencyUnit,
        paidReservationPriceAmount = parking_vehicles_df$rentalPrice$paidReservationPrice$amount,
        paidReservationPriceCurr = parking_vehicles_df$rentalPrice$paidReservationPrice$currencyUnit
      )
    }
    
    vehicles_df <- rbind(car_df, parking_df)
      
    write.table(vehicles_df, "all_vehicles_df.csv", col.names=FALSE, row.names = FALSE, sep=",",append = TRUE)

}
}

##calc rent interval

all_vehicles_df <- read.csv("all_vehicles_df.csv",header=TRUE,row.names=NULL)
all_vehicles_df <- cbind(all_vehicles_df, datetime = NA)
all_vehicles_df$datetime <- strptime(all_vehicles_df$filename, "%Y-%m-%dT%H_%M_%S")

all_vehicles_df <- unique(all_vehicles_df)
all_vehicles_df <- na.omit(all_vehicles_df)

vehicles_group_df <- unique(data.frame(id = all_vehicles_df$id))
all_rent_interval <- data.frame()

carGroupCount <- nrow(vehicles_group_df)

all_car_interval <- data.frame(
  id = character(0),
  name = character(0),
  licensePlate = character(0),
  group = character(0),
  modelName = character(0),
  transmission = character(0),
  #address = character(0),
  latitude = character(0),
  longitude = character(0),
  isCharging = character(0),
  isInParkingSpace = character(0),
  fuelLevel = character(0),
  estimatedRange = character(0),
  drivePriceAmount = character(0),
  drivePriceCurr = character(0),
  parkPriceAmount = character(0),
  parkPriceCurr = character(0),
  paidReservationPriceAmount = character(0),
  paidReservationPriceCurr = character(0),
  start_datetime = character(0), 
  end_datetime = character(0),
  start_fuel = numeric(0),
  end_fuel = numeric(0)
)

write.table(all_car_interval, "all_car_interval.csv", col.names=TRUE, row.names = FALSE, sep=",")

for (ii in 1:carGroupCount) {
  
  print(paste("Car #", ii, " of ", carGroupCount))
  
  car_data <- data.frame()
  car_data <- all_vehicles_df[all_vehicles_df$id == vehicles_group_df$id[ii],]
  car_data <- car_data[order(car_data$datetime),]
  
  car_interval <- data.frame(
    name = car_data$name,
    address = car_data$address,
    engineType = car_data$engineType,
    exterior = car_data$exterior,
    interior = car_data$interior,
    vin = car_data$vin,
    smartphoneRequired = car_data$smartphoneRequired,
    lat <- car_data$lat,
    lat <- car_data$lng,
    start_datetime = car_data$datetime,
    end_datetime = c(car_data$datetime[-1], NA),
    start_fuel = car_data$fuelLevel,
    end_fuel = c(car_data$fuelLevel[-1], NA)
  )
  
  #all_car_interval <- rbind(all_car_interval, car_interval)  
  write.table(car_interval, "all_car_interval.csv", col.names=FALSE, row.names = FALSE, sep=",",append = TRUE)
  
}

#write.table(all_rent_interval, "all_rent_interval.csv", col.names=TRUE, row.names = FALSE, sep=",")

all_car_interval <- read.csv("all_car_interval.csv",header=TRUE,row.names=NULL)
all_car_interval$end_datetime <- as.POSIXct(all_car_interval$end_datetime)
all_car_interval$start_datetime <- as.POSIXct(all_car_interval$start_datetime)
all_car_interval$rent_time_min <- as.numeric(difftime(all_car_interval$end_datetime, all_car_interval$start_datetime,units="mins"))
all_car_interval$rent_fuel_loss <- round(all_car_interval$start_fuel - all_car_interval$end_fuel, digits = 2)
write.table(all_car_interval, "all_car_interval.csv", col.names=TRUE, row.names = FALSE, sep=",")

all_rent_interval <- na.omit(
  all_car_interval[all_car_interval$rent_time_min > 5, ])

all_rent_interval$rent_amount <- all_rent_interval$rent_time_min * 0.3
write.table(all_rent_interval, "all_rent_interval.csv", col.names=TRUE, row.names = FALSE, sep=",")

all_rent_interval <- read.csv("all_rent_interval.csv",header=TRUE,row.names=NULL)
all_rent_interval$end_datetime <- as.POSIXct(all_rent_interval$end_datetime)
all_rent_interval$start_datetime <- as.POSIXct(all_rent_interval$start_datetime)

all_rent_interval2 <- na.omit(
  all_rent_interval[all_rent_interval$rent_time_min > 10 & 
                      all_rent_interval$rent_time_min < 7200 &
                      all_rent_interval$rent_fuel_loss != 0 , ])

all_rent_interval2$rent_amount <- all_rent_interval2$rent_time_min * 0.3

hist(all_car_interval2$rent_time_min)



sum(all_rent_interval2$rent_amount)

carGroupCount <- length(unique(all_rent_interval2$name))
sum(all_rent_interval2$rent_amount) / carGroupCount #averange sum per car

summary(all_rent_interval2)

