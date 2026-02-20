# queimadasR <img src="sticker_queimadasR.png" align="right" height="138" />

O pacote permite acessar diretamente dados do sistema BDQueimadas, incluindo:

- 🔥 Focos de calor

- 🌡️ Índice de risco de fogo

- 🌧️ Variáveis meteorológicas associadas

- 🌎 Informações espaciais (UF, município, bioma)

- ⚡ FRP (Fire Radiative Power)

Os dados são oficiais e públicos, fornecidos pelo Instituto Nacional de Pesquisas Espaciais por meio do Programa Queimadas.

🔗 Para saber mais sobre o Programa de Queimadas do INPE, [acesse o portal](https://queimadas.dgi.inpe.br/queimadas/portal).


## 📦 Instalação

#### Via GitHub

```r
# Instalar remotes (se necessário)
install.packages("remotes")

# Reinstalar o pacote (agora com a documentação)
remotes::install_github("wtassinari/queimadasR", force = TRUE)
```

#### Instalação local (arquivo .tar.gz)

```r
install.packages("queimadasR_0.1.0.tar.gz", repos = NULL, type = "source")
```

## 🚀 Fluxo básico de uso

O fluxo geral do pacote envolve:

1. Definir período e filtros (estado, satélite, etc.)

2. Baixar os dados

3. Realizar análises exploratórias ou modelagens

Exemplo simples:

```r
library(queimadasR)

estados_norte <- c("ACRE", "AMAPÁ", "AMAZONAS")

dados_norte <- download_focos_anual_periodo(
  data_inicio_str = "15/08/2023",
  data_fim_str    = "30/09/2023",
  estados_alvo    = estados_norte,
  satelites_alvo  = NULL,   # Todos os satélites
  timeout         = 300,
  deduplicar_final = TRUE
)

head(dados_norte)
summary(dados_norte)
nrow(dados_norte)

```

## 📊 Estrutura dos dados:

A função `download_focos()` retorna um dataframe com as seguintes variáveis:

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `latitude` | num | Coordenada geográfica latitude do foco de calor (em graus decimais) |
| `longitude` | num | Coordenada geográfica longitude do foco de calor (em graus decimais) |
| `data_pas` | POSIXct | Data e hora da passagem do satélite (formato: AAAA-MM-DD HH:MM:SS) |
| `satelite` | chr | Satélite que realizou a detecção (ex: AQUA_M-T, NOAA-20, NOAA-21, TERRA, etc.) |
| `pais` | chr | País onde o foco foi detectado |
| `estado` | chr | Unidade federativa (UF) onde o foco foi detectado |
| `municipio` | chr | Nome do município onde o foco foi detectado |
| `bioma` | chr | Bioma brasileiro onde o foco ocorreu (Amazônia, Cerrado, Mata Atlântica, Caatinga, Pampa, Pantanal) |
| `numero_dias_sem_chuva` | num | Número de dias consecutivos sem precipitação na região |
| `precipitacao` | num | Precipitação acumulada no período (em mm) |
| `risco_fogo` | num | Índice de risco de fogo calculado pelo INPE (escala 0-1) |
| `id_area_industrial` | int | Identificador de área industrial (0 = não industrial, 1 = industrial) |
| `frp` | num | Fire Radiative Power - Potência Radiativa do Fogo (em MW) |
| `ano_ref` | int | Ano de referência da detecção |

### Detalhamento das principais variáveis

**Coordenadas geográficas (`latitude`, `longitude`)**
- Precisão: aproximadamente 1km (resolução dos satélites de referência)
- Formato: graus decimais (ex: -9.30, -68.30)

**Satélites (`satelite`)**
- **AQUA_M-T**: Satélite Aqua (Missão Manhã-Tarde) - referência principal
- **TERRA_M-T**: Satélite Terra (Missão Manhã-Tarde)
- **NOAA-20/21**: Satélites da série NOAA (National Oceanic and Atmospheric Administration)
- **NPP-375**: Satélite Suomi NPP

**Biomas brasileiros (`bioma`)**
- Amazônia
- Cerrado
- Mata Atlântica
- Caatinga
- Pampa
- Pantanal

**FRP (Fire Radiative Power)**
- Mede a intensidade da queimada
- Valores mais altos indicam focos mais intensos
- Unidade: Megawatts (MW)
- Útil para estimar emissões de gases e material particulado

**Risco de fogo (`risco_fogo`)**
- Índice calculado pelo INPE baseado em:
  - Condições meteorológicas
  - Umidade do solo
  - Tipo de vegetação
  - Histórico de queimadas
- Escala: 0 (baixo risco) a 1 (alto risco)

**Satélites**
Exemplos incluídos na base:

- AQUA_M-T
- TERRA_M-T
- NOAA-20 / NOAA-21
- NPP-375

### 📈 Exemplo de uso para visualização dos dados

```r
library(queimadasR)

dados <- download_focos(
  data_inicio = "2025-01-01",
  data_fim    = "2025-01-31",
  estado      = "AC"
)

str(dados)

summary(dados[, c("frp", "risco_fogo", "numero_dias_sem_chuva")])

table(dados$satelite)

aggregate(frp ~ bioma, data = dados, FUN = mean)
```

## 🎯 Aplicações

O pacote pode ser utilizado para:

- Estudos ambientais e ecológicos
- Monitoramento sazonal de queimadas
- Modelagem espaço-temporal
- Estudos sobre impactos das queimadas na saúde
- Integração com bases epidemiológicas

## 🙏 Reconhecimento

O desenvolvimento deste pacote não seria possível sem os dados abertos disponibilizados gratuitamente pelo Programa de Queimadas do INPE e o trabalho de toda equipe envolvida no monitoramento ambiental do Brasil.

Agradecimento especial ao Instituto Nacional de Pesquisas Espaciais (INPE) pela disponibilização dos dados e pelo trabalho essencial no monitoramento de queimadas e incêndios florestais em território brasileiro.

Recomendamos que os usuários também citem a fonte oficial dos dados em seus trabalhos científicos.

## 📚 Como citar o pacote:

Pedimos aos usuários que citem o pacote sempre que ele for utilizado em pesquisas ou publicações, reconhecendo o trabalho de todos os autores envolvidos.

### Formato ABNT

TASSINARI, Wagner S.; PACIFICO, Roni dos Santos Jorge; FERREIRA, Manuela dos Santos. **queimadasR**: Pacote para download e análise de dados de queimadas do INPE. Versão 0.1.0. 2024. Disponível em: https://github.com/wtassinari/queimadasR

### Formato BibTeX

```bibtex
@manual{queimadasR2024,
  title = {queimadasR: Pacote para download e análise de dados de queimadas do INPE},
  author = {Tassinari, Wagner S. and Pacifico, Roni dos Santos Jorge and Ferreira, Manuela dos Santos},
  year = {2024},
  note = {Versão 0.1.0},
  organization = {Universidade Federal Rural do Rio de Janeiro e Instituto Nacional de Infectologia/FIOCRUZ},
  url = {https://github.com/wtassinari/queimadasR}
}
```


## 👨‍🔬 Um pouco mais sobre os autores: 

<div align="justify">

**Wagner S. Tassinari** Professor e pesquisador com atuação interdisciplinar entre estatística, ciência de dados, ciências ambientais, epidemiologia e saúde pública, com ênfase em modelagem espaço-temporal aplicada a queimadas e seus impactos. Lotado no Instituto de Ciências Exatas da Universidade Federal Rural do Rio de Janeiro (ICE/UFRRJ) e no Instituto Nacional de Infectologia da Fundação Oswaldo Cruz (INI/FIOCRUZ). Sua pesquisa integra métodos computacionais e estatísticos para análise de dados ambientais e de saúde pública, com ênfase em modelos espaciais e temporais aplicados ao monitoramento de queimadas e seus impactos na saúde.

**Roni dos Santos Jorge Pacifico** é discente do curso de Engenharia Florestal, vinculado ao Instituto de Florestas da Universidade Federal Rural do Rio de Janeiro (IF/UFRRJ), onde desenvolve estudos sobre dinâmica do fogo, ecologia de ecossistemas florestais e impactos ambientais das queimadas. Sua expertise contribui para a compreensão dos padrões ecológicos e ambientais relacionados aos focos de calor.

**Manuela dos Santos Ferreira** é discente do curso de Sistemas de Informação no Instituto de Ciências Exatas da Universidade Federal Rural do Rio de Janeiro (ICE/UFRRJ), atuando no desenvolvimento de ferramentas computacionais e análise de dados para o monitoramento ambiental. Sua contribuição foi fundamental para a implementação e documentação do pacote.

</div>
