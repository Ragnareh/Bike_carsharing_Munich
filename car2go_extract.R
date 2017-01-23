Sys.setlocale("LC_CTYPE", "German")

require(jsonlite)

setwd("d:/Projects/Carsharing/datasets/car2go-muc")

files <- list.files(pattern = ".json")

all_vehicles_df <- data.frame(
  filename = character(0),
  name = character(0),
  fuelLevel = numeric(0), 
  address = character(0),
  engineType = character(0),
  exterior = character(0),
  interior = character(0),
  vin = character(0),
  smartphoneRequired = character(0),
  lat = numeric(0),
  lng = numeric(0)
)

write.table(all_vehicles_df, "all_vehicles_df.csv", col.names=TRUE, row.names = FALSE, sep=",")

for (fileCount in seq_along(files)) {
#for (filecount in 18217:31035) {
  filename <- files[fileCount]
  
  #print progress
  print(paste(fileCount," -- ",filename))
  
  json_data <- fromJSON(filename)
  
  available_vehicles_df <- json_data$placemarks
  
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
}

##calc rent interval

all_vehicles_df <- read.csv("all_vehicles_df.csv",header=TRUE,row.names=NULL)
all_vehicles_df <- cbind(all_vehicles_df, datetime = NA)
all_vehicles_df$datetime <- strptime(all_vehicles_df$filename, "%Y-%m-%dT%H_%M_%S")

all_vehicles_df <- unique(all_vehicles_df)
all_vehicles_df <- na.omit(all_vehicles_df)

vehicles_group_df <- unique(data.frame(car_name = all_vehicles_df$name))

all_rent_interval <- data.frame()

carGroupCount <- nrow(vehicles_group_df)

all_car_interval <- data.frame(
  name = character(0),
  address = character(0),
  engineType = character(0),
  exterior = character(0),
  interior = character(0),
  vin = character(0),
  smartphoneRequired = character(0),
  lat = numeric(0),
  lng = numeric(0),
  start_datetime = character(0), 
  end_datetime = character(0),
  start_fuel = numeric(0),
  end_fuel = numeric(0)
)

write.table(all_car_interval, "all_car_interval.csv", col.names=TRUE, row.names = FALSE, sep=",")

for (ii in 1:carGroupCount) {
  
  print(paste("Car #", ii, " of ", carGroupCount))
  
  car_data <- data.frame()
  car_data <- all_vehicles_df[all_vehicles_df$name == vehicles_group_df$car_name[ii],]
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

