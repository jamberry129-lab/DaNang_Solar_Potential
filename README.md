# Da Nang, Vietnam — Building Rooftop Solar Potential

This repository contains a rooftop solar PV potential analysis for **Da Nang, Vietnam**.  
The analysis is adapted from [Grinberg (2022)](https://github.com/Einavg7/Rosario_Solar_Potential) — *Estimating building rooftop solar potential in a city from a developing country*.

## Repository structure

1. The `index.html` creates a **web map** displaying solar potential for building rooftops in Da Nang.  
   Building footprints from [OpenStreetMap](https://www.openstreetmap.org) via [Geofabrik](https://www.geofabrik.de).  
   Solar data from [Global Solar Atlas](https://globalsolaratlas.info) (World Bank).  
   Land cover strata from [Copernicus LULC 2015](https://land.copernicus.eu).  
   Built with [jQuery](https://jquery.com) + [Leaflet](https://leafletjs.com). Hosted on [GitHub Pages](https://pages.github.com).  
   🌐 **Web map: [Click here](https://[username].github.io/DaNang_Solar_Potential)**

2. The `data/` folder contains the building polygon layer for the web map (`danang_solar.geojson`).

3. The `QGIS/` folder contains the processing workflow notes (see `QGIS/README.md`).

4. The `sampling/` folder contains the R code for sampling analysis (see `sampling/README.md`).

---

## Results

| Metric | Value |
|---|---|
| Total buildings | 47,472 |
| Total roof area | 6.26 km² |
| Mean GHI | 1,684 kWh/m²/yr |
| **Electricity potential (Census)** | **1,377 GWh/yr** |
| Built-up stratum | 22,175 buildings (46.7%) |
| Non built-up stratum | 25,297 buildings (53.3%) |

---

## Methodology

```
Data sources:
  OSM buildings (Geofabrik) + GHI raster (Global Solar Atlas) + LULC (Copernicus)
        ↓
Python processing (Google Colab):
  area_m2   = building footprint area (UTM 48N)
  ghi_mean  = zonal statistics from GHI raster
  usable_sr = area_m2 × ghi_mean
  elec_prod = usable_sr × 0.18 × 0.75
  landuse   = built_up / non_built_up (from LULC pixels 50–60)
        ↓
R sampling analysis:
  Census (N=47,472) → ground truth
  Random sampling (n=384, Cochran formula)
  Stratified equal (60+60=120)
  Stratified optimal (95+5=100)
        ↓
Leaflet web map (index.html) → GitHub Pages
```

## Practical Applications

- 🏙️ Xác định khu vực có tiềm năng điện mặt trời áp mái cao chưa được khai thác
- 📊 So sánh tiềm năng lý thuyết với số liệu lắp đặt thực tế (EVN)
- 🏛️ Hỗ trợ quy hoạch năng lượng tái tạo cấp tỉnh/thành
- 🎓 Nghiên cứu học thuật về năng lượng tái tạo đô thị tại Việt Nam
- 💼 Hỗ trợ nhà đầu tư điện mặt trời áp mái
- 🌏 Framework có thể nhân rộng cho các đô thị ASEAN khác

## Data Sources

| Dataset | Source | Resolution |
|---|---|---|
| Building footprints | OpenStreetMap via Geofabrik | Building-level |
| GHI | Global Solar Atlas v2 (World Bank) | ~1 km |
| LULC | Copernicus Global Land Cover 2015 | 100 m |
| Admin boundary | Vietnam Province Shapefile | Province |

## Parameters

| Parameter | Symbol | Value |
|---|---|---|
| Panel efficiency | η | 18% |
| Performance ratio | PR | 0.75 |
| Min building area | — | 30 m² |
| GHI (Da Nang) | — | 1,684 kWh/m²/yr |

## References

- Grinberg, E. (2022). *Estimating building rooftop solar potential in a city from a developing country*. MSc Thesis.
- Thompson, S. K. (2012). *Sampling* (3rd ed.). Wiley.
- Global Solar Atlas 2.0, Solargis / World Bank Group.
- OpenStreetMap contributors.
- Copernicus Land Monitoring Service.
- IRENA (2022). *Renewable Power Generation Costs in 2021*.
- EVN (2021). Báo cáo thường niên về điện mặt trời áp mái năm 2020.

## License
MIT
