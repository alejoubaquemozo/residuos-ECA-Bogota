library(tidyverse)
library(sf)
library(readr)
library(mapgl)
library(readxl)
library(RColorBrewer)
library(colorspace)
library(htmltools)

# 1. Importación de archivos ----------------------------------------------

eca <- read_excel("ECA_11032025.xlsx")
localidades_Bogota <- st_read(dsn = "Loca.shp", as_tibble = TRUE)
barrios_Bogota <- st_read(dsn = "SECTOR.shp", as_tibble = TRUE)


# 2. Depuración de datos a manejar --------------------------

glimpse(eca)
names(eca) <- make.names(names(eca))  # Corrige nombres con caracteres especiales

sum(is.na(eca$LONGITUD))  # Cuenta valores NA en LONGITUD
sum(is.na(eca$LATITUD))   # Cuenta valores NA en LATITUD

eca <- eca |> filter(!is.na(LONGITUD) & !is.na(LATITUD))

str(eca)  # Muestra la estructura de los datos


# 3. Selección de datos a manejar: ECA Bogotá -----------------------------

eca_Bogota <- eca |> 
  filter(ESTADO == "En Operación" & Municipio.ubicación.ECA == "BOGOTA, D.C.") |> 
  mutate(LONGITUD = as.numeric(LONGITUD),
         LATITUD = as.numeric(LATITUD)) |> 
  drop_na(LONGITUD, LATITUD) |>  # Elimina filas con coordenadas faltantes
  st_as_sf(coords = c("LONGITUD", "LATITUD"), crs = 4326, remove = FALSE)

eca_Bogota_proy <- eca_Bogota |> 
  st_transform(crs = 9377)

st_crs(barrios_Bogota)
st_crs(localidades_Bogota)

barrios_Bogota_proy <- barrios_Bogota |> 
  st_transform(crs = 9377)

localidades_Bogota_proy <- localidades_Bogota |> 
  st_transform(crs = 9377)

barrios_Bogota_proy <- barrios_Bogota |> 
  st_transform(crs = 9377)

# 4. Visualización --------------------------------------------------------

token <- 'aquí debe haber el token de mapbox: https://console.mapbox.com/'

colores2 <- qualitative_hcl(20, palette = "Set2")[1:length(localidades_Bogota_proy$LocNombre)]

eca_Bogota_proy$popup_info <- paste0("ECA: ", eca_Bogota_proy$ECA, "- Estación: ", eca_Bogota_proy$NOMBRE_ESTACION)

m1 <- mapboxgl(access_token = token) |>
   fly_to(center = c(-74.091351, 4.651016),
          zoom = 10) |> 
  add_circle_layer(id = "ecas",
                   source = eca_Bogota_proy,
                   circle_color = "red",
                   circle_stroke_color = "white",
                   circle_stroke_width = 1,
                   popup = "popup_info") |> 
  # add_circle_layer(id = "eca_3936111001",
  #                  source = eca_3936111001,
  #                  circle_color = "purple",
  #                  circle_stroke_color = "white",
  #                  circle_stroke_width = 1,
  #                  circle_radius = 9,
  #                  popup = "popup_info") |>
  add_fill_layer(id = "localidades",
                 source = localidades_Bogota_proy,
                 fill_color = match_expr(column = "LocNombre",
                                         values = localidades_Bogota_proy$LocNombre,
                                         stops = colores2),
                 fill_opacity = 0.7,
                 fill_outline_color = "#070100",
                 tooltip = "LocNombre")

m1

# Definir radio de análisis en metros (ejemplo: 500m)
radio_metros <- 100

# Calcular la densidad de puntos dentro del radio definido
eca_Bogota_proy <- eca_Bogota_proy |>
  mutate(heatmap_weight = lengths(st_is_within_distance(eca_Bogota_proy, dist = radio_metros)))

eca_Bogota_proy$heatmap_weight <- as.numeric(eca_Bogota_proy$heatmap_weight)

eca_3936111001 <- eca_Bogota_proy |> 
  filter(ECA == "3936111001")
  
m3 <- mapboxgl(access_token = token) |>
  fly_to(center = c(-74.091351, 4.651016),
         zoom = 10) |>
  


m2 <- mapboxgl(mapbox_style("satellite-streets"),
               access_token = token) |>
  fly_to(center = c(-74.091351, 4.651016),
         zoom = 10) |> 
  add_fill_layer(id = "localidades",
                 source = localidades_Bogota_proy,
                 fill_color = "white",
                 fill_opacity = 0.9,
                 fill_outline_color = "#070100",
                 tooltip = "LocNombre") |>
  add_fill_layer(id = "barrios",
                 source = barrios_Bogota_proy,
                 fill_color = "grey",
                 fill_opacity = 0.2,
                 fill_outline_color = "#070100",
                 popup = "SCANOMBRE") |> 
  add_heatmap_layer(id = "mapacalor",
                    source = eca_Bogota_proy,
                    heatmap_radius = 25,
                    heatmap_weight = interpolate(column ="heatmap_weight",
                                                 values = c(1,12),
                                                 stops = c(0,1))) |>
  add_circle_layer(id = "ecas",
                   source = eca_Bogota_proy,
                   circle_color = "red",
                   circle_stroke_color = "white",
                   circle_stroke_width = 1,
                   min_zoom = 12.5,
                   popup = "popup_info")

m2

#Uso de la libreria htmltools para comparar pues con la función compare no fue posible
browsable(
  tagList(list(
    tags$div(
      style = 'width:50%;display:block;float:left;',
      m1
    ),
    tags$div(
      style = 'width:50%;display:block;float:left;',
      m2
    )
  ))
)


# 5. Análisis de datos ----------------------------------------------------

eca_Bogota_proy |> 
  count(EMPRESA)

length(unique(eca_Bogota_proy$EMPRESA))


##A corte de marzo 2025, en Bogotá existen 521 prestadores de la actividad de aprovechamiento que operan 1110 ECA, que se distribuyen en todas las localidades de Bogotá, excepto Sumapaz. 

#ECA por fuera de Bogotá
eca_dentro_Bogota <- st_intersection(x = eca_Bogota_proy,
                                    y = localidades_Bogota_proy)

#de las 1110 ECA, 53 se encuentran por fuera de Bogotá conforme a las coordenadas ingresadas por los prestadores de la actividad de aprovechamiento

eca_dentro_Bogota_clip <- st_join(x = eca_dentro_Bogota,
                              y = localidades_Bogota_proy |> select(1), #el 1 corresponde a la posición de la columna LocNombre
                              left = TRUE)

eca_x_localidad <- eca_dentro_Bogota_clip |> 
  st_drop_geometry() |> 
  group_by(LocNombre.x) |> 
  summarise(numero_eca = n()) |> 
  ungroup()
#Existe una mayor concentración de ECA en la zona occidental de la ciudad, especialmente en el sur occidente. 
#las 3 localidades con mayor número de ECA son: Kennedy (245), Bosa (162) y Suba (103)
#Mientras que las localidades con menor número de ECA son: La Candelaria (2), Chapinero (5) y Teusaquillo (6)

eca_dentro_Bogota_clip_barrios <- st_join(x = eca_dentro_Bogota,
                                  y = barrios_Bogota_proy |> select(3), 
                                  left = TRUE)

eca_x_barrio <- eca_dentro_Bogota_clip_barrios |> 
  st_drop_geometry() |> 
  group_by(SCANOMBRE) |> 
  summarise(numero_eca_barrio = n()) |> 
  ungroup()
#Respecto a barrios - localidad, aquellos con mayor número son: San Bernardino XVIII - Bosa (28), Maria Paz - Kennedy (27), Chucua de la Vaca II - Kennedy (26), Chucua de la Vaca III - Kennedy (19), Pensilvania - Puente Aranda (15) y Class - Kennedy (15)

#Por último, vale preguntarse, ¿a qué se debe la concentración de ECA en algunas zonas de la ciudad?¿qué condiciona la ubicación de ECA en Bogotá?¿podrá ser que el suelo para ciertas zonas lo permite y otras no?
#¿es cuestión de aceptación o rechazo por parte de la comunidad?¿o responde a dinámicas económicas por costos que exige la ECA como su compra o arrendamiento?
#¿su ubicación depende a cuestiones de mercado?¿las ECA deberían estar distribuidas de tal forma que siga una lógica de planificación urbana, cobertura del servicio y cercanía a la ciudadanía conforme a la generación de residuos?
#¿debería existir una distribución de ECA (y prestadores) por localidad o UPL?


# 6. Fuentes de datos -----------------------------------------------------

#barrios: https://datosabiertos.bogota.gov.co/dataset/sector-catastral
#localidades: https://datosabiertos.bogota.gov.co/dataset/localidad-bogota-d-c
#ECA: http://www.sui.gov.co/web/aseo
