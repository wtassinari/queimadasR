# queimadasR: Download e Análise de Dados de Queimadas do INPE

Um pacote R para download e processamento de dados de queimadas do Banco de Dados de Queimadas (BDQUEIMADAS) do Instituto Nacional de Pesquisas Espaciais (INPE).

## Instalação

Você pode instalar o pacote diretamente do GitHub:

```r
# Instalar remotes se necessário
install.packages("remotes")

# Instalar o pacote queimadasR
remotes::install_github("seu-usuario/queimadasR")
```

Ou, para desenvolvimento local:

```r
# No diretório do pacote
devtools::load_all()
```

## Uso Rápido

```r
library(queimadasR)

# Exemplo 1: Baixar dados para a região Norte em agosto-setembro de 2023
estados_norte <- c("ACRE", "AMAPÁ", "AMAZONAS", "PARÁ", "RONDÔNIA", "RORAIMA", "TOCANTINS")
dados_norte <- download_focos_anual_periodo(
  data_inicio_str = "01/08/2023",
  data_fim_str = "30/09/2023",
  estados_alvo = estados_norte,
  deduplicar_final = TRUE
)

# Exemplo 2: Baixar apenas dados de GOES-16 e AQUA_T
dados_filtrados <- download_focos_anual_periodo(
  data_inicio_str = "15/08/2022",
  data_fim_str = "30/09/2022",
  estados_alvo = c("MATO GROSSO", "TOCANTINS"),
  satelites_alvo = c("GOES-16", "AQUA_T"),
  deduplicar_final = TRUE
)

# Exemplo 3: Baixar todos os dados para um período (sem filtro de estado)
dados_brasil <- download_focos_anual_periodo(
  data_inicio_str = "01/01/2023",
  data_fim_str = "31/12/2023"
)
```

## Funcionalidades Principais

### `download_focos_anual_periodo()`

A função principal do pacote realiza o download de dados consolidados de queimadas com as seguintes capacidades:

- **Filtro por Período**: Especifique datas de início e fim em formato "DD/MM/AAAA"
- **Filtro por Estados**: Selecione um ou mais estados brasileiros
- **Filtro por Satélites**: Escolha entre satélites específicos ou use todos os disponíveis
- **Deduplicação**: Remove automaticamente registros duplicados
- **Tratamento de Erros**: Gerencia timeouts e falhas de download com recuperação automática
- **Compatibilidade Histórica**: Suporta múltiplos formatos de data/hora de diferentes períodos

### Satélites Suportados

O pacote reconhece automaticamente os seguintes satélites e seus aliases históricos:

- **AQUA_T**: AQUA_T, AQUA_M-T, AQUA_M_T, AQUA_M-M, AQUA_M_M
- **TERRA_T**: TERRA_T, TERRA_M-T, TERRA_M_T, TERRA_M-M, TERRA_M_M
- **GOES-16**: GOES-16, GOES_16, GOES-16D, GOES_16D
- **GOES-13**: GOES-13, GOES_13, GOES-13D, GOES_13D
- **NPP-375**: NPP-375, NPP_375, NPP-375D, NPP_375D, SUOMI_NPP_375, SUOMI_NPP_375D

## Parâmetros da Função

```r
download_focos_anual_periodo(
  data_inicio_str,              # Data de início (obrigatório, formato "DD/MM/AAAA")
  data_fim_str,                 # Data de fim (obrigatório, formato "DD/MM/AAAA")
  regiao = "Brasil",            # Região de interesse
  estados_alvo = NULL,          # Vetor com nomes dos estados a filtrar
  satelites_alvo = NULL,        # Vetor com nomes dos satélites (NULL = todos)
  timeout = 300,                # Timeout em segundos
  sleep_sec = 1,                # Espera entre downloads (segundos)
  mostrar_satelites_quando_vazio = TRUE,  # Mostrar satélites disponíveis se filtro resultar em zero
  deduplicar_final = TRUE,      # Remover duplicatas ao final
  dedup_keys = c("latitude", "longitude", "data_pas", "municipio")  # Chaves para deduplicação
)
```

## Estrutura dos Dados Retornados

A função retorna um data frame com as seguintes colunas (pode variar conforme o período):

- `latitude`: Latitude do foco de queimada
- `longitude`: Longitude do foco de queimada
- `data_pas`: Data e hora (GMT) da passagem do satélite
- `municipio`: Município onde o foco foi detectado
- `estado`: Estado onde o foco foi detectado
- `satelite`: Satélite que detectou o foco
- `bioma`: Bioma onde o foco foi detectado
- `ano_ref`: Ano de referência do download
- Outras colunas conforme disponibilidade nos dados

## Fonte de Dados

Os dados são obtidos do Banco de Dados de Queimadas (BDQUEIMADAS) do Instituto Nacional de Pesquisas Espaciais (INPE):

- **URL**: https://terrabrasilis.dpi.inpe.br/queimadas/bdqueimadas/
- **Descrição**: Base de dados consolidada de focos de calor detectados por satélites

## Tratamento de Erros

O pacote implementa tratamento robusto de erros:

- Valida automaticamente os formatos de data
- Gerencia timeouts de download
- Remove arquivos temporários em caso de falha
- Fornece mensagens de erro detalhadas
- Continua o processamento mesmo se alguns anos falharem

## Exemplos Avançados

### Análise de Queimadas por Bioma

```r
# Baixar dados para o Cerrado
dados_cerrado <- download_focos_anual_periodo(
  data_inicio_str = "01/01/2023",
  data_fim_str = "31/12/2023",
  estados_alvo = c("GOIÁS", "MATO GROSSO DO SUL", "MATO GROSSO", "TOCANTINS", "BAHIA", "SÃO PAULO", "MINAS GERAIS", "DISTRITO FEDERAL")
)

# Análise básica
summary(dados_cerrado)
table(dados_cerrado$satelite)
```

### Comparação Entre Satélites

```r
# Baixar dados de dois satélites específicos
dados_comparacao <- download_focos_anual_periodo(
  data_inicio_str = "01/08/2023",
  data_fim_str = "31/08/2023",
  satelites_alvo = c("GOES-16", "AQUA_T"),
  deduplicar_final = FALSE  # Manter duplicatas para análise
)

# Contar focos por satélite
table(dados_comparacao$satelite)
```

## Requisitos

- R >= 3.5.0
- Conexão com a internet para download dos dados

## Licença

MIT + file LICENSE

## Contribuições

Contribuições são bem-vindas! Por favor, abra uma issue ou envie um pull request.

## Contato

Para dúvidas ou sugestões, entre em contato através do repositório GitHub.

## Referências

- INPE - Instituto Nacional de Pesquisas Espaciais: https://www.inpe.br/
- TerraBrasilis: https://terrabrasilis.dpi.inpe.br/
- BDQUEIMADAS: https://terrabrasilis.dpi.inpe.br/queimadas/bdqueimadas/
