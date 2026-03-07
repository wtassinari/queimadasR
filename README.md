# queimadasR <img src="sticker_queimadasR.png" align="right" height="138" />

The package allows direct access to data from the BDQueimadas system, including:

- 🔥 Heat spots

- 🌡️ Fire risk index

- 🌧️ Associated meteorological variables

- 🌎 Spatial information (state, municipality, biome)

- ⚡ FRP (Fire Radiative Power)

The data are official and public, provided by the National Institute for Space Research through the Queimadas Program.

🔗 To learn more about INPE's Queimadas Program, [visit the portal](https://queimadas.dgi.inpe.br/queimadas/portal).


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
library(queimadasR)

# Specifying the states
estados <- c("MATO GROSSO", "TOCANTINS", "ACRE", "AMAPÁ")

# Specifying the satellites
# satelites <- c("GOES-16", "AQUA_T") 
satelites <- NULL # All satellites


tabela <- download_focos_anual_periodo(
  data_inicio_str = "15/08/2025",
  data_fim_str = "16/08/2025",
  estados_alvo = estados,
  satelites_alvo = satelites,  # All satellites
  deduplicar_final = TRUE
)

head(tabela)
summary(tabela)
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
