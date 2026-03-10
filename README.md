# queimadasR <img src="sticker_queimadasR.png" align="right" height="138" />

The package allows direct access to data from the BDQueimadas system, including:

- 🔥 Heat spots

- 🌡️ Fire risk index

- 🌧️ Associated meteorological variables

- 🌎 Spatial information (state, municipality, biome)

- ⚡ FRP (Fire Radiative Power)

The data are official and public, provided by the National Institute for Space Research through the Queimadas Program.

🔗 To learn more about INPE's Queimadas Program, [visit the portal](https://terrabrasilis.dpi.inpe.br/queimadas/bdqueimadas/).


## 📦 Installation

#### Via GitHub

```r
# Install remotes (if necessary)
install.packages("remotes")

# Install the package
remotes::install_github("wtassinari/queimadasR", force = TRUE)
```

#### Local installation (.tar.gz file)

```r
install.packages("queimadasR_0.1.0.tar.gz", repos = NULL, type = "source")
```

## 🚀 Basic usage flow

The general workflow of the package involves:

1. Define the period and filters (state, satellite, etc.)

2. Download the data

3. Perform exploratory analyses or modelling

Simple example:

```r
# -----------------------------------------------------------------------------
# First, source this file to load the function into your R session:
#   source("download_fire_spots.R")
# -----------------------------------------------------------------------------


# --- Example 1: All satellites, single month, entire Brazil ------------------
# Downloads every fire spot detected across Brazil during September 2023,
# using all available satellites, with deduplication enabled.

df_brazil <- download_fire_spots(
  start_date_str    = "01/09/2023",
  end_date_str      = "30/09/2023",
  deduplicate_final = TRUE
)

head(df_brazil)
nrow(df_brazil)


# --- Example 2: Northern region, peak fire season, all satellites ------------
# Covers the 7 states of Brazil's Legal Amazon during the Aug–Sep 2023
# fire season. Deduplication removes records shared across satellite passes.

north_states <- c("ACRE", "AMAPA", "AMAZONAS", "PARA",
                  "RONDONIA", "RORAIMA", "TOCANTINS")

df_north <- download_fire_spots(
  start_date_str    = "01/08/2023",
  end_date_str      = "2/08/2023",
  target_states     = north_states,
  deduplicate_final = TRUE
)

head(df_north)
table(df_north$estado)  # fire spots per state


# --- Example 3: Specific satellites, two states, single year -----------------
# Useful when you only want data from GOES-16 (geostationary) and
# AQUA_T (polar orbit) for a targeted area.

df_goes_aqua <- download_fire_spots(
  start_date_str    = "15/08/2022",
  end_date_str      = "30/09/2022",
  target_states     = c("MATO GROSSO", "TOCANTINS"),
  target_satellites = c("GOES-16", "AQUA_T"),
  deduplicate_final = TRUE
)

table(df_goes_aqua$satelite)  # confirm which satellites are present


# --- Example 4: Multi-year download (2020–2022), single state ----------------
# The function automatically loops over each year and combines the results.
# Increase timeout if your connection is slow.

df_multiyear <- download_fire_spots(
  start_date_str    = "01/07/2020",
  end_date_str      = "31/10/2022",
  target_states     = c("MATO GROSSO"),
  deduplicate_final = TRUE,
  timeout           = 600   # 10 minutes per year
)

# Count fire spots per year
table(df_multiyear$ref_year)


# --- Example 5: No deduplication, custom dedup keys, inspect satellites ------
# Download without deduplication so you can inspect the raw data first,
# then manually deduplicate using only lat/lon/datetime.

df_raw <- download_fire_spots(
  start_date_str             = "01/09/2024",
  end_date_str               = "30/09/2024",
  target_states              = c("PARA", "MARANHAO"),
  deduplicate_final          = FALSE,
  show_satellites_when_empty = TRUE
)

# Check which satellites are present before deciding how to deduplicate
sort(table(df_raw$satelite), decreasing = TRUE)

# Manually deduplicate using only coordinates + datetime
df_deduped <- df_raw[!duplicated(df_raw[, c("latitude", "longitude", "data_pas")]), ]
nrow(df_raw) - nrow(df_deduped)  # how many duplicates were removed


# --- Example 6: Save results to CSV ------------------------------------------

df_to_save <- download_fire_spots(
  start_date_str    = "01/08/2023",
  end_date_str      = "31/08/2023",
  target_states     = c("AMAZONAS", "PARA"),
  deduplicate_final = TRUE
)

write.csv(df_to_save, "fire_spots_AM_PA_aug2023.csv", row.names = FALSE)
cat("File saved:", nrow(df_to_save), "records\n")

```

## 📊 Data structure:

The `download_focos()` function returns a dataframe with the following variables:

| Variable | Type | Description |
|----------|------|-------------|
| `latitude` | num | Geographic latitude coordinate of the heat spot (in decimal degrees) |
| `longitude` | num | Geographic longitude coordinate of the heat spot (in decimal degrees) |
| `data_pas` | POSIXct | Date and time of the satellite pass (format: YYYY-MM-DD HH:MM:SS) |
| `satelite` | chr | Satellite that performed the detection (e.g.: AQUA_M-T, NOAA-20, NOAA-21, TERRA, etc.) |
| `pais` | chr | Country where the spot was detected |
| `estado` | chr | Federative unit (state) where the spot was detected |
| `municipio` | chr | Name of the municipality where the spot was detected |
| `bioma` | chr | Brazilian biome where the spot occurred (Amazon, Cerrado, Atlantic Forest, Caatinga, Pampa, Pantanal) |
| `numero_dias_sem_chuva` | num | Number of consecutive days without precipitation in the region |
| `precipitacao` | num | Accumulated precipitation in the period (in mm) |
| `risco_fogo` | num | Fire risk index calculated by INPE (scale 0–1) |
| `id_area_industrial` | int | Industrial area identifier (0 = non-industrial, 1 = industrial) |
| `frp` | num | Fire Radiative Power (in MW) |
| `ano_ref` | int | Reference year of the detection |

### Detailed description of the main variables

**Geographic coordinates (`latitude`, `longitude`)**
- Precision: approximately 1 km (resolution of the reference satellites)
- Format: decimal degrees (e.g.: -9.30, -68.30)

**Satellites (`satelite`)**
- **AQUA_M-T**: Aqua satellite (Morning-Afternoon Mission) — primary reference
- **TERRA_M-T**: Terra satellite (Morning-Afternoon Mission)
- **NOAA-20/21**: NOAA series satellites (National Oceanic and Atmospheric Administration)
- **NPP-375**: Suomi NPP satellite

**Brazilian biomes (`bioma`)**
- Amazon
- Cerrado
- Atlantic Forest
- Caatinga
- Pampa
- Pantanal

**FRP (Fire Radiative Power)**
- Measures the intensity of the fire
- Higher values indicate more intense spots
- Unit: Megawatts (MW)
- Useful for estimating gas and particulate matter emissions

**Fire risk (`risco_fogo`)**
- Index calculated by INPE based on:
  - Meteorological conditions
  - Soil moisture
  - Vegetation type
  - Fire history
- Scale: 0 (low risk) to 1 (high risk)

**Satellites**
Examples included in the dataset:

- AQUA_M-T
- TERRA_M-T
- NOAA-20 / NOAA-21
- NPP-375

## 🎯 Applications

The package can be used for:

- Environmental and ecological studies
- Seasonal fire monitoring
- Spatio-temporal modelling
- Studies on the health impacts of wildfires
- Integration with epidemiological databases

## 🙏 Acknowledgements

The development of this package would not have been possible without the open data freely provided by INPE's Queimadas Program and the work of the entire team involved in environmental monitoring in Brazil.

Special thanks to the National Institute for Space Research (INPE) for making the data available and for their essential work in monitoring wildfires and forest fires across Brazilian territory.

We recommend that users also cite the official data source in their scientific publications.

## 📚 How to cite the package:

We ask users to cite the package whenever it is used in research or publications, acknowledging the work of all authors involved.

### ABNT Format

TASSINARI, Wagner S.; PACIFICO, Roni dos Santos Jorge; FERREIRA, Manuela dos Santos. **queimadasR**: Pacote para download e análise de dados de queimadas do INPE. Versão 0.1.0. 2024. Disponível em: https://github.com/wtassinari/queimadasR

### BibTeX Format

```bibtex
@software{queimadasR2026,
  title = {queimadasR: Pacote para download e análise de dados de queimadas do INPE},
  author = {Tassinari, Wagner S. and Pacifico, Roni dos Santos Jorge and Ferreira, Manuela dos Santos},
  organization = {Universidade Federal Rural do Rio de Janeiro e Instituto Nacional de Infectologia/FIOCRUZ},
  year = {2026},
  version   = {0.1.0},
  doi       = {10.5281/zenodo.18879882},
  url       = {https://doi.org/10.5281/zenodo.18879882}
}
```


## 👨‍🔬 A little more about the authors:

<div align="justify">

**Wagner S. Tassinari** is a professor and researcher with an interdisciplinary background spanning statistics, data science, environmental sciences, epidemiology, and public health, with an emphasis on spatio-temporal modelling applied to wildfires and their impacts. He is affiliated with the Institute of Exact Sciences at the Federal Rural University of Rio de Janeiro (ICE/UFRRJ) and the National Institute of Infectology at the Oswaldo Cruz Foundation (INI/FIOCRUZ). His research integrates computational and statistical methods for the analysis of environmental and public health data, with a focus on spatial and temporal models applied to wildfire monitoring and their health impacts.

**Roni dos Santos Jorge Pacifico** is a student in the Forest Engineering programme, affiliated with the Institute of Forests at the Federal Rural University of Rio de Janeiro (IF/UFRRJ), where he conducts studies on fire dynamics, forest ecosystem ecology, and the environmental impacts of wildfires. His expertise contributes to the understanding of ecological and environmental patterns related to heat spots.

**Manuela dos Santos Ferreira** is a student in the Information Systems programme at the Institute of Exact Sciences of the Federal Rural University of Rio de Janeiro (ICE/UFRRJ), working on the development of computational tools and data analysis for environmental monitoring. Her contribution was fundamental to the implementation and documentation of the package.

</div>
