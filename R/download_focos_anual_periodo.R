#' Download de Dados Anuais de Queimadas do BDQUEIMADAS
#'
#' Baixa dados consolidados de focos de queimadas do Banco de Dados de Queimadas
#' (BDQUEIMADAS) do Instituto Nacional de Pesquisas Espaciais (INPE). Permite
#' filtrar por período, estados e satélites, com opção de deduplicação automática.
#'
#' @param data_inicio_str Data de início do período em formato "DD/MM/AAAA"
#' @param data_fim_str Data de fim do período em formato "DD/MM/AAAA"
#' @param regiao Região de interesse (padrão: "Brasil")
#' @param estados_alvo Vetor com nomes dos estados a filtrar (ex: c("ACRE", "AMAZONAS")).
#'   Se NULL, não filtra por estado.
#' @param satelites_alvo Vetor com nomes dos satélites a filtrar (ex: c("GOES-16", "AQUA_T")).
#'   Se NULL ou "TODOS"/"ALL", usa todos os satélites disponíveis.
#' @param timeout Timeout em segundos para download (padrão: 300)
#' @param sleep_sec Tempo de espera em segundos entre downloads (padrão: 1)
#' @param mostrar_satelites_quando_vazio Se TRUE, mostra satélites disponíveis quando
#'   filtro resulta em zero registros
#' @param deduplicar_final Se TRUE, remove registros duplicados ao final
#' @param dedup_keys Vetor com nomes das colunas usadas para deduplicação
#'
#' @return Data frame com os dados de queimadas filtrados e processados
#'
#' @details
#' A função realiza os seguintes passos:
#' \enumerate{
#'   \item Valida as datas de entrada
#'   \item Identifica os anos do período
#'   \item Para cada ano, baixa o arquivo ZIP consolidado do BDQUEIMADAS
#'   \item Extrai e lê o CSV dentro do arquivo
#'   \item Detecta automaticamente a coluna de data/hora
#'   \item Filtra por período, estado e satélite
#'   \item Combina dados de todos os anos
#'   \item Remove duplicatas (opcional)
#' }
#'
#' Os nomes de satélites são normalizados automaticamente. Aliases suportados:
#' \itemize{
#'   \item AQUA_T: AQUA_T, AQUA_M-T, AQUA_M_T, AQUA_M-M, AQUA_M_M
#'   \item TERRA_T: TERRA_T, TERRA_M-T, TERRA_M_T, TERRA_M-M, TERRA_M_M
#'   \item GOES_16: GOES-16, GOES_16, GOES-16D, GOES_16D
#'   \item GOES_13: GOES-13, GOES_13, GOES-13D, GOES_13D
#'   \item NPP_375: NPP-375, NPP_375, NPP-375D, NPP_375D, SUOMI_NPP_375, SUOMI_NPP_375D
#' }
#'
#' @examples
#' \dontrun{
#' # Exemplo 1: Baixar todos os satélites para região Norte
#' estados_norte <- c("ACRE", "AMAPÁ", "AMAZONAS", "PARÁ", "RONDÔNIA", "RORAIMA", "TOCANTINS")
#' dados_norte <- download_focos_anual_periodo(
#'   data_inicio_str = "01/08/2023",
#'   data_fim_str = "30/09/2023",
#'   estados_alvo = estados_norte,
#'   deduplicar_final = TRUE
#' )
#'
#' # Exemplo 2: Baixar apenas GOES-16 e AQUA_T
#' dados_filtrados <- download_focos_anual_periodo(
#'   data_inicio_str = "15/08/2022",
#'   data_fim_str = "30/09/2022",
#'   estados_alvo = c("MATO GROSSO", "TOCANTINS"),
#'   satelites_alvo = c("GOES-16", "AQUA_T"),
#'   deduplicar_final = TRUE
#' )
#' }
#'
#' @export
download_focos_anual_periodo <- function(
  data_inicio_str, data_fim_str,
  regiao = "Brasil",
  estados_alvo = NULL,
  satelites_alvo = NULL,
  timeout = 300,
  sleep_sec = 1,
  mostrar_satelites_quando_vazio = TRUE,
  deduplicar_final = TRUE,
  dedup_keys = c("latitude", "longitude", "data_pas", "municipio")
) {
  options(timeout = timeout)

  # ---------------------------
  # Helpers
  # ---------------------------
  norm_txt <- function(x) {
    x <- toupper(trimws(x))
    x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
    x
  }

  norm_sat <- function(x) {
    x <- toupper(trimws(x))
    x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
    x <- gsub("[[:space:]]+", "", x)
    x <- gsub("-", "_", x)
    x <- gsub("__+", "_", x)
    x
  }

  parse_datetime_gmt <- function(x) {
    as.POSIXct(
      x, tz = "GMT",
      tryFormats = c(
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%d/%m/%Y %H:%M:%S",
        "%d/%m/%Y %H:%M",
        "%Y-%m-%d"
      )
    )
  }

  # Detecta qual coluna é a data/hora real (compatível com vários anos)
  encontrar_coluna_datetime <- function(df) {
    cand <- c(
      "data_pas",
      "data_hora_gmt", "datahora_gmt",
      "data_hora", "datahora",
      "data_passagem", "datahora_passagem"
    )

    # também tenta qualquer coluna que comece com "data"
    cand <- unique(c(cand, grep("^data", names(df), ignore.case = TRUE, value = TRUE)))
    cand <- intersect(cand, names(df))
    if (length(cand) == 0) return(NULL)

    best <- NULL
    best_ok <- -1L
    for (nm in cand) {
      x <- parse_datetime_gmt(df[[nm]])
      ok <- sum(!is.na(x))
      if (ok > best_ok) {
        best_ok <- ok
        best <- nm
      }
    }
    best
  }

  # Aliases de satélite (expandem rótulos modernos para rótulos antigos)
  sat_alias <- list(
    "AQUA_T"  = c("AQUA_T", "AQUA_M-T", "AQUA_M_T", "AQUA_M-M", "AQUA_M_M"),
    "TERRA_T" = c("TERRA_T","TERRA_M-T","TERRA_M_T","TERRA_M-M","TERRA_M_M"),
    "GOES_16" = c("GOES-16","GOES_16","GOES-16D","GOES_16D"),
    "GOES_13" = c("GOES-13","GOES_13","GOES-13D","GOES_13D"),
    "NPP_375" = c("NPP-375","NPP_375","NPP-375D","NPP_375D","SUOMI_NPP_375","SUOMI_NPP_375D")
  )
  sat_alias <- lapply(sat_alias, norm_sat)
  names(sat_alias) <- norm_sat(names(sat_alias))

  expand_sats <- function(sats) {
    if (is.null(sats)) return(NULL)
    s_norm <- norm_sat(sats)
    unique(unlist(lapply(s_norm, function(s) {
      if (s %in% names(sat_alias)) sat_alias[[s]] else s
    })))
  }

  dedup_focos <- function(df, keys) {
    faltando <- setdiff(keys, names(df))
    if (length(faltando) > 0) {
      stop("Não dá para deduplicar: faltam colunas: ", paste(faltando, collapse = ", "))
    }

    # Padronizar municipio para reduzir duplicação por variação de acento/caixa/espaço
    df$municipio <- norm_txt(df$municipio)

    # Garantir POSIXct em GMT para data_pas
    if (!inherits(df$data_pas, "POSIXct")) {
      df$data_pas <- parse_datetime_gmt(df$data_pas)
    }

    df[!duplicated(df[, keys, drop = FALSE]), , drop = FALSE]
  }

  # ---------------------------
  # Datas de entrada
  # ---------------------------
  data_inicio <- as.Date(data_inicio_str, format = "%d/%m/%Y")
  data_fim    <- as.Date(data_fim_str,    format = "%d/%m/%Y")
  if (is.na(data_inicio) || is.na(data_fim)) stop("Formato de data inválido. Use 'DD/MM/AAAA'.")
  if (data_fim < data_inicio) stop("data_fim deve ser >= data_inicio.")

  ano_inicio <- as.integer(format(data_inicio, "%Y"))
  ano_fim    <- as.integer(format(data_fim,    "%Y"))
  anos <- seq(ano_inicio, ano_fim)

  dt_ini <- as.POSIXct(paste0(format(data_inicio, "%Y-%m-%d"), " 00:00:00"), tz = "GMT")
  dt_fim <- as.POSIXct(paste0(format(data_fim,    "%Y-%m-%d"), " 23:59:59"), tz = "GMT")

  usar_todos_satelites <- is.null(satelites_alvo) ||
    (length(satelites_alvo) == 1 && toupper(satelites_alvo) %in% c("TODOS", "ALL"))

  cat("\n=== DOWNLOAD DE DADOS ANUAIS CONSOLIDADOS DO BDQUEIMADAS ===\n")
  cat("Período de Filtragem:", data_inicio_str, "a", data_fim_str, "\n")
  cat("Anos para Download:", paste(anos, collapse = ", "), "\n")
  cat("Região:", regiao, "\n")
  if (!is.null(estados_alvo)) cat("Filtrando por Estados:", paste(estados_alvo, collapse = ", "), "\n")
  if (usar_todos_satelites) {
    cat("Filtrando por Satélites: TODOS\n")
  } else {
    cat("Filtrando por Satélites (entrada):", paste(satelites_alvo, collapse = ", "), "\n")
  }
  cat("Timeout configurado:", timeout, "segundos\n\n")

  # ---------------------------
  # Loop por ano
  # ---------------------------
  lista_dados <- vector("list", length(anos))
  contador_sucesso <- 0L
  contador_erro <- 0L

  for (i in seq_along(anos)) {
    ano_atual <- anos[i]
    nome_arquivo <- paste0("focos_br_todos-sats_", ano_atual, ".zip")
    url <- paste0(
      "https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/",
      nome_arquivo
    )

    cat(sprintf("[%d/%d] %s ... ", i, length(anos), ano_atual))

    temp_dir <- tempdir()
    arquivo_local <- file.path(temp_dir, nome_arquivo)

    res <- tryCatch({
      # Download
      status <- download.file(url, arquivo_local, mode = "wb", quiet = TRUE, method = "auto")
      if (status != 0) stop("Falha no download (download.file retornou != 0).")

      # Descobrir CSV dentro do ZIP
      zlist <- unzip(arquivo_local, list = TRUE)
      csvs <- zlist$Name[grepl("\\.csv$", zlist$Name, ignore.case = TRUE)]
      if (length(csvs) == 0) stop("ZIP não contém CSV.")
      csv_in_zip <- csvs[1]

      # Ler CSV direto do ZIP
      dados_ano <- read.csv(unz(arquivo_local, csv_in_zip), stringsAsFactors = FALSE)

      # Detectar coluna de data/hora e padronizar em data_pas
      dt_col <- encontrar_coluna_datetime(dados_ano)
      if (is.null(dt_col)) {
        stop(paste0("Não encontrei coluna de data/hora. Colunas: ", paste(names(dados_ano), collapse = ", ")))
      }

      dt_parsed <- parse_datetime_gmt(dados_ano[[dt_col]])
      if (all(is.na(dt_parsed))) stop(paste0("Falha ao converter coluna de data/hora: ", dt_col))

      # Garantir coluna data_pas sempre presente e em POSIXct
      dados_ano$data_pas <- dt_parsed

      # Filtragem por período
      dados_filtrados <- dados_ano[dados_ano$data_pas >= dt_ini & dados_ano$data_pas <= dt_fim, , drop = FALSE]

      # Filtragem por estado
      if (!is.null(estados_alvo) && regiao == "Brasil") {
        cand_uf <- c("estado", "uf", "sigla_uf", "estado_sigla")
        uf_col <- intersect(cand_uf, names(dados_filtrados))
        if (length(uf_col) > 0) {
          uf_col <- uf_col[1]
          alvo <- norm_txt(estados_alvo)
          dados_filtrados <- dados_filtrados[norm_txt(dados_filtrados[[uf_col]]) %in% alvo, , drop = FALSE]
        } else {
          warning("Você pediu filtro por estado, mas não achei coluna tipo 'estado/uf'.")
        }
      }

      # Filtragem por satélite (com aliases), somente se NÃO for "todos"
      if (!usar_todos_satelites && regiao == "Brasil") {
        cand_sat <- c("satelite", "satellite", "sensor")
        sat_col <- intersect(cand_sat, names(dados_filtrados))
        if (length(sat_col) > 0) {
          sat_col <- sat_col[1]

          alvo_exp <- expand_sats(satelites_alvo) # normalizado
          sat_vals_norm <- norm_sat(dados_filtrados[[sat_col]])

          dados_filtrados2 <- dados_filtrados[sat_vals_norm %in% alvo_exp, , drop = FALSE]

          if (nrow(dados_filtrados2) == 0L && mostrar_satelites_quando_vazio) {
            top_sats <- sort(table(norm_sat(dados_filtrados[[sat_col]])), decreasing = TRUE)
            top_sats <- head(top_sats, 10)
            cat("\n    Aviso: filtro de satélite zerou este ano. Satélites disponíveis (top 10):\n")
            print(top_sats)
          }

          dados_filtrados <- dados_filtrados2
        } else {
          warning("Você pediu filtro por satélite, mas não achei coluna tipo 'satelite/satellite/sensor'.")
        }
      }

      # Marcar ano de referência
      dados_filtrados$ano_ref <- rep.int(ano_atual, nrow(dados_filtrados))

      # Limpar ZIP
      if (file.exists(arquivo_local)) file.remove(arquivo_local)

      list(ok = TRUE, data = dados_filtrados)

    }, error = function(e) {
      if (file.exists(arquivo_local)) file.remove(arquivo_local)
      list(ok = FALSE, err = conditionMessage(e))
    })

    if (isTRUE(res$ok)) {
      lista_dados[[i]] <- res$data
      contador_sucesso <- contador_sucesso + 1L
      cat("✓ (", format(nrow(res$data), big.mark = "."), "focos)\n")
      Sys.sleep(sleep_sec)
    } else {
      contador_erro <- contador_erro + 1L
      lista_dados[[i]] <- NULL
      cat("✗ Erro\n")
      cat("    Detalhes:", res$err, "\n")
    }
  }

  cat("\n=== RESUMO DO DOWNLOAD ===\n")
  cat("Sucessos:", contador_sucesso, "/", length(anos), "\n")
  cat("Erros:", contador_erro, "\n")

  if (contador_sucesso == 0L) {
    cat("\nNenhum dado foi baixado com sucesso.\n")
    return(NULL)
  }

  cat("\nCombinando dados...\n")
  dados_completos <- do.call(rbind.data.frame, lista_dados[!vapply(lista_dados, is.null, logical(1))])
  cat("Total (antes da deduplicação):", format(nrow(dados_completos), big.mark = "."), "\n")
  cat("Tamanho em memória:", format(object.size(dados_completos), units = "MB"), "\n")

  if (isTRUE(deduplicar_final)) {
    cat("\nDeduplicando por:", paste(dedup_keys, collapse = ", "), "...\n")
    antes <- nrow(dados_completos)
    dados_completos <- dedup_focos(dados_completos, dedup_keys)
    depois <- nrow(dados_completos)
    cat("Removidos:", format(antes - depois, big.mark = "."), "duplicados.\n")
    cat("Total (após deduplicação):", format(depois, big.mark = "."), "\n")
  }

  cat("\n=== DOWNLOAD CONCLUÍDO COM SUCESSO ===\n\n")
  dados_completos
}
