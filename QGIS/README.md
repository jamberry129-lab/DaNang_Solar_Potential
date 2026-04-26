# QGIS Folder

This folder contains notes on the QGIS workflow used in the Rosario methodology.
For Da Nang, the processing was performed in Python (Google Colab) instead of QGIS,
producing equivalent results.

## Equivalent Python workflow (Google Colab)

```
Step 1  Load OSM buildings from Geofabrik shapefile
Step 2  Clip to Da Nang administrative boundary (mainland polygon)
Step 3  Reproject to UTM Zone 48N (EPSG:32648) for metric area
Step 4  Calculate area_m2 = geometry.area
Step 5  Extract GHI from raster (zonal statistics, nodata filtered)
Step 6  Calculate usable_sr = area_m2 × ghi_mean
Step 7  Calculate elec_prod = usable_sr × 0.18 × 0.75
Step 8  Apply density factor: elec_prod = 0 for area_m2 ≤ 30
Step 9  Assign strata from Copernicus LULC 2015 (pixels 50–60 = built-up)
Step 10 Export danang_solar.shp (for R) and danang_solar.geojson (for web map)
```

## Parameters
- Panel efficiency (η): 0.18
- Performance ratio (PR): 0.75
- Density factor threshold: 30 m²
- GHI source: Global Solar Atlas v2 (World Bank)
- LULC source: Copernicus Land Cover 2015 (100m)
