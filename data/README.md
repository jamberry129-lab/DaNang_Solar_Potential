# Data Folder

Place the following file here after running the Colab pipeline:

| File | Size | Description |
|---|---|---|
| `danang_solar.geojson` | ~22 MB | Building polygons with solar potential |

## How to generate

```python
# Run on Google Colab then download:
from google.colab import files
files.download("/content/drive/MyDrive/WebGIS_Vietnam/danang_solar.geojson")
```

## Columns

| Column | Unit | Description |
|---|---|---|
| `osm_id` | — | OpenStreetMap building ID |
| `name` | — | Building name |
| `type` | — | Building type |
| `area_m2` | m² | Footprint area |
| `ghi_mean` | kWh/m²/yr | Mean annual GHI |
| `usable_sr` | kWh | Usable solar radiation |
| `elec_prod` | kWh/yr | Electricity production potential |
| `elec_mwh` | MWh/yr | Same in MWh |
| `landuse` | — | built_up / non_built_up |
