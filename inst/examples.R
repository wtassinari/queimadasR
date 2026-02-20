# ============================================================================
# EXEMPLOS DE USO DO PACOTE QUEIMADASR
# ============================================================================

# Carregar o pacote
library(queimadasR)

# ============================================================================
# EXEMPLO 1: Baixar dados para a região Norte (todos os satélites)
# ============================================================================
estados_norte <- c("ACRE", "AMAPÁ", "AMAZONAS", "PARÁ", "RONDÔNIA", "RORAIMA", "TOCANTINS")

dados_norte <- download_focos_anual_periodo(
  data_inicio_str = "15/08/2023",
  data_fim_str = "30/09/2023",
  estados_alvo = estados_norte,
  satelites_alvo = NULL,      # Usar TODOS os satélites
  timeout = 300,
  deduplicar_final = TRUE
)

# Visualizar resumo dos dados
head(dados_norte)
summary(dados_norte)
nrow(dados_norte)

# ============================================================================
# EXEMPLO 2: Baixar dados com filtro de satélite (com aliases)
# ============================================================================
satelites_interesse <- c("GOES-16", "AQUA_T")

dados_filtrados <- download_focos_anual_periodo(
  data_inicio_str = "15/08/2022",
  data_fim_str = "30/09/2022",
  estados_alvo = estados_norte,
  satelites_alvo = satelites_interesse,  # Filtrar por satélites específicos
  timeout = 300,
  deduplicar_final = TRUE
)

# Verificar satélites presentes nos dados
table(dados_filtrados$satelite)

# ============================================================================
# EXEMPLO 3: Análise de queimadas por estado
# ============================================================================
dados_brasil <- download_focos_anual_periodo(
  data_inicio_str = "01/01/2023",
  data_fim_str = "31/12/2023",
  deduplicar_final = TRUE
)

# Contar focos por estado
focos_por_estado <- table(dados_brasil$estado)
focos_por_estado <- sort(focos_por_estado, decreasing = TRUE)
print(focos_por_estado)

# Visualizar os 10 estados com mais focos
barplot(head(focos_por_estado, 10), 
        main = "Top 10 Estados com Mais Focos de Queimada (2023)",
        xlab = "Estado",
        ylab = "Número de Focos",
        las = 2)

# ============================================================================
# EXEMPLO 4: Análise temporal de queimadas
# ============================================================================
# Extrair mês dos dados
dados_brasil$mes <- as.numeric(format(dados_brasil$data_pas, "%m"))

# Contar focos por mês
focos_por_mes <- table(dados_brasil$mes)
plot(focos_por_mes, 
     main = "Distribuição de Focos por Mês (2023)",
     xlab = "Mês",
     ylab = "Número de Focos",
     type = "b")

# ============================================================================
# EXEMPLO 5: Análise por bioma
# ============================================================================
# Contar focos por bioma (se coluna disponível)
if ("bioma" %in% names(dados_brasil)) {
  focos_por_bioma <- table(dados_brasil$bioma)
  focos_por_bioma <- sort(focos_por_bioma, decreasing = TRUE)
  print(focos_por_bioma)
  
  barplot(focos_por_bioma,
          main = "Focos de Queimada por Bioma (2023)",
          xlab = "Bioma",
          ylab = "Número de Focos",
          las = 2)
}

# ============================================================================
# EXEMPLO 6: Comparação entre satélites
# ============================================================================
dados_comparacao <- download_focos_anual_periodo(
  data_inicio_str = "01/08/2023",
  data_fim_str = "31/08/2023",
  satelites_alvo = c("GOES-16", "AQUA_T", "TERRA_T"),
  deduplicar_final = FALSE  # Manter duplicatas para análise
)

# Contar focos por satélite
focos_por_satelite <- table(dados_comparacao$satelite)
print(focos_por_satelite)

# Visualizar
barplot(focos_por_satelite,
        main = "Comparação de Detecções por Satélite (Agosto 2023)",
        xlab = "Satélite",
        ylab = "Número de Detecções",
        las = 2)

# ============================================================================
# EXEMPLO 7: Análise de série temporal (múltiplos anos)
# ============================================================================
dados_serie <- download_focos_anual_periodo(
  data_inicio_str = "01/01/2020",
  data_fim_str = "31/12/2023",
  deduplicar_final = TRUE
)

# Extrair ano dos dados
dados_serie$ano <- as.numeric(format(dados_serie$data_pas, "%Y"))

# Contar focos por ano
focos_por_ano <- table(dados_serie$ano)
print(focos_por_ano)

# Visualizar tendência
plot(focos_por_ano,
     main = "Série Temporal de Focos de Queimada (2020-2023)",
     xlab = "Ano",
     ylab = "Número de Focos",
     type = "b",
     lwd = 2,
     pch = 16)

# ============================================================================
# EXEMPLO 8: Exportar dados para arquivo
# ============================================================================
# Salvar em CSV
write.csv(dados_norte, "focos_norte_2023.csv", row.names = FALSE)

# Salvar em Excel (requer pacote openxlsx)
# install.packages("openxlsx")
# openxlsx::write.xlsx(dados_norte, "focos_norte_2023.xlsx")

# ============================================================================
# EXEMPLO 9: Análise geoespacial (com pacote sf)
# ============================================================================
# install.packages("sf")
# library(sf)
# 
# # Converter para objeto sf (pontos)
# dados_sf <- st_as_sf(dados_brasil,
#                       coords = c("longitude", "latitude"),
#                       crs = 4326)
# 
# # Visualizar mapa
# plot(dados_sf, main = "Distribuição Espacial de Focos de Queimada")

# ============================================================================
# EXEMPLO 10: Análise de densidade de focos
# ============================================================================
# install.packages("MASS")
# library(MASS)
# 
# # Criar mapa de densidade
# kde <- kde2d(dados_brasil$longitude, dados_brasil$latitude, n = 50)
# image(kde, main = "Densidade de Focos de Queimada")
# contour(kde, add = TRUE)

# ============================================================================
# EXEMPLO 11: Filtro customizado - Focos recentes em estado específico
# ============================================================================
dados_mato_grosso <- download_focos_anual_periodo(
  data_inicio_str = "01/09/2023",
  data_fim_str = "30/09/2023",
  estados_alvo = "MATO GROSSO",
  deduplicar_final = TRUE
)

# Análise
cat("Total de focos em Mato Grosso (setembro 2023):", nrow(dados_mato_grosso), "\n")
cat("Satélites detectores:\n")
print(table(dados_mato_grosso$satelite))

# ============================================================================
# EXEMPLO 12: Tratamento de erros e validação
# ============================================================================
# Teste com período inválido (será capturado com mensagem de erro)
tryCatch({
  dados_invalido <- download_focos_anual_periodo(
    data_inicio_str = "31/12/2023",
    data_fim_str = "01/01/2023"  # Data final anterior à inicial
  )
}, error = function(e) {
  cat("Erro capturado:", conditionMessage(e), "\n")
})
