Sys.setlocale("LC_CTYPE", "German")

setwd("c:/Projects/Carsharing/datasets/car2go-muc")

all_rent_interval <- read.csv("all_rent_interval.csv",header=TRUE,row.names=NULL)
all_rent_interval$start_datetime <- as.POSIXct(all_rent_interval$start_datetime)
all_rent_interval$end_datetime <- as.POSIXct(all_rent_interval$end_datetime)

unique(substr(all_rent_interval$vin,1,3))

library(ggmap)

all_rent_interval_2 <- all_rent_interval[all_rent_interval$rent_time_min > 10 & all_rent_interval$rent_fuel_loss != 0, ]

location_df <- unique(all_rent_interval_2[, c(2, 8,9)])

location_df <- data.frame(
  address = all_rent_interval_2[, 2],
  lat = round(all_rent_interval_2[, 8], 3),
  lng = round(all_rent_interval_2[, 9], 3)
  )

location_df <- unique(location_df)


# getting the map
mapgilbert <- get_map(location = c(lon = mean(location_df$lng), lat = mean(location_df$lat)), zoom = 10,
                      maptype = "roadmap", scale = "auto")

# plotting the map with some points on it
ggmap(mapgilbert) +
  geom_point(data = location_df, aes(x = location_df$lng, y = location_df$lat, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)


hist(all_rent_interval$rent_fuel_loss)
