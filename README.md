# Mugreografía: residuos-geografía-ECA-Bogota
Mapa de puntos y de calor de las Estaciones de Clasificación y Aprovechamiento - ECA en Bogotá a corte de marzo 2025 hecho en lenguaje R 😎.
Los datos provienen de las siguientes fuentes:

-Barrios: https://datosabiertos.bogota.gov.co/dataset/sector-catastral 

-Localidades: https://datosabiertos.bogota.gov.co/dataset/localidad-bogota-d-c

-ECA: http://www.sui.gov.co/web/aseo

El propósito de esta publicación, es realizar un análisis de las dinámicas relacionadas con residuos sólidos ♻ y la geografía 🗺, en este caso la distribución y patrones encontrados de la ubicacion de las ECA de los prestadores de aprovechamiento en la capital de Colombia. 

Para poder usar el codigo y los archivos, se deben descargar todos y abrir el archivo denominado "

Por otro lado, se usó la librería "mapgl" de mapbox para los mapas base y sus funciones propias, no obstante, se pueden usar otras como "leaflet" que es ampliamente usada y no requiere de una API key. Y aunque "mapgl" sí requiere de API key para lo cual se debe crear usuario y contraseña y además ingresar datos de tarjeta bancaria en la página cuyo link se encuentra más abajo, y la mayor parte de los planes son pagos, se puede usar gratuitamente siempre y cuando no se sobrepase el número de "cargas" que son hasta 50 mil, pues estas librerías están pensadas en uso masivo en diferentes aplicaciones y plataformas web, por lo que si se usa de manera personal no habrá problemas con el mapa y menos con que se cobre por usarlo, y además se conseguirán mapas base muy bonitos. 

Link mapbox: https://console.mapbox.com/
