#' Download Fire Spot Data from INPE
#'
#' Downloads fire spot data from the Brazilian Wildfire Database (BDQUEIMADAS)
#' of the National Institute for Space Research (INPE). This function wraps
#' the download_fire_spots function with a simplified interface.
#'
#' @param start_date Start date (YYYY-MM-DD or DD/MM/YYYY format)
#' @param end_date End date (YYYY-MM-DD or DD/MM/YYYY format)
#' @param target_states Character vector of state abbreviations or names
#'   (e.g., c("AC", "AM") or c("ACRE", "AMAZONAS")). If NULL, all states are included.
#' @param target_satellites Character vector of satellite names to filter by
#'   (e.g., c("GOES-16", "AQUA_T")). If NULL, all satellites are included.
#' @param deduplicate_final If TRUE (default), removes duplicate records
#'
#' @return Data frame with fire spot data containing columns:
#'   latitude, longitude, data_pas, satelite, estado, municipio, and others
#'
#' @details
#' This function downloads consolidated annual fire spot data from BDQUEIMADAS.
#' It automatically handles date format conversion and calls the underlying
#' download_fire_spots function with appropriate parameters.
#'
#' @examples
#' \dontrun{
#' # Download all fire spots for a period
#' dados <- download_focos(
#'   start_date = "2023-08-01",
#'   end_date   = "2023-09-30"
#' )
#'
#' # Download for specific states
#' dados <- download_focos(
#'   start_date      = "2023-08-01",
#'   end_date        = "2023-09-30",
#'   target_states   = c("MT", "PA", "AM")
#' )
#'
#' # Download for specific satellites
#' dados <- download_focos(
#'   start_date        = "2023-08-01",
#'   end_date          = "2023-09-30",
#'   target_satellites = c("GOES-16", "AQUA_T")
#' )
#' }
#'
#' @export
download_focos <- function(
  start_date,
  end_date,
  target_states      = NULL,
  target_satellites  = NULL,
  deduplicate_final  = TRUE
) {
  # Convert date formats
  start_date_str <- convert_date_format(start_date)
  end_date_str   <- convert_date_format(end_date)

  # Convert state abbreviations to full names if needed
  target_states <- convert_state_abbreviations(target_states)

  message("Downloading fire spot data from INPE...")

  # Call the main download function
  dados <- download_fire_spots(
    start_date_str        = start_date_str,
    end_date_str          = end_date_str,
    region                = "Brasil",
    target_states         = target_states,
    target_satellites     = target_satellites,
    timeout               = 300,
    sleep_sec             = 1,
    show_satellites_when_empty = TRUE,
    deduplicate_final     = deduplicate_final,
    dedup_keys            = c("latitude", "longitude", "data_pas", "municipio")
  )

  return(dados)
}

#' Convert Date Format
#'
#' Converts dates from YYYY-MM-DD or DD/MM/YYYY format to DD/MM/YYYY format
#' required by download_fire_spots.
#'
#' @param date_str Date string in YYYY-MM-DD or DD/MM/YYYY format
#'
#' @return Date string in DD/MM/YYYY format
#'
#' @keywords internal
convert_date_format <- function(date_str) {
  # Try parsing as YYYY-MM-DD first
  parsed_date <- tryCatch({
    as.Date(date_str, format = "%Y-%m-%d")
  }, error = function(e) {
    # Try DD/MM/YYYY format
    as.Date(date_str, format = "%d/%m/%Y")
  })

  if (is.na(parsed_date)) {
    stop("Invalid date format. Use 'YYYY-MM-DD' or 'DD/MM/YYYY'.")
  }

  # Return in DD/MM/YYYY format
  format(parsed_date, "%d/%m/%Y")
}

#' Convert State Abbreviations to Full Names
#'
#' Converts Brazilian state abbreviations (e.g., "SP", "MG") to full names
#' (e.g., "SAO PAULO", "MINAS GERAIS").
#'
#' @param states Character vector of state abbreviations or names
#'
#' @return Character vector of full state names, or NULL if input is NULL
#'
#' @keywords internal
convert_state_abbreviations <- function(states) {
  if (is.null(states)) return(NULL)

  # Mapping of state abbreviations to full names
  state_mapping <- c(
    "AC" = "ACRE",
    "AL" = "ALAGOAS",
    "AP" = "AMAPA",
    "AM" = "AMAZONAS",
    "BA" = "BAHIA",
    "CE" = "CEARA",
    "DF" = "DISTRITO FEDERAL",
    "ES" = "ESPIRITO SANTO",
    "GO" = "GOIAS",
    "MA" = "MARANHAO",
    "MT" = "MATO GROSSO",
    "MS" = "MATO GROSSO DO SUL",
    "MG" = "MINAS GERAIS",
    "PA" = "PARA",
    "PB" = "PARAIBA",
    "PR" = "PARANA",
    "PE" = "PERNAMBUCO",
    "PI" = "PIAUI",
    "RJ" = "RIO DE JANEIRO",
    "RN" = "RIO GRANDE DO NORTE",
    "RS" = "RIO GRANDE DO SUL",
    "RO" = "RONDONIA",
    "RR" = "RORAIMA",
    "SC" = "SANTA CATARINA",
    "SP" = "SAO PAULO",
    "SE" = "SERGIPE",
    "TO" = "TOCANTINS"
  )

  # Convert to uppercase for comparison
  states_upper <- toupper(states)

  # Replace abbreviations with full names
  converted <- sapply(states_upper, function(s) {
    if (s %in% names(state_mapping)) {
      state_mapping[[s]]
    } else if (s %in% state_mapping) {
      s
    } else {
      # If not found in mapping, keep original (might be full name already)
      s
    }
  }, USE.NAMES = FALSE)

  as.character(converted)
}

#' Process Fire Spot Data
#'
#' Processes raw fire spot data by applying filters, calculations, and
#' data quality checks.
#'
#' @param dados Data frame with raw fire spot data from download_focos
#' @param remove_duplicates If TRUE (default), removes duplicate records
#' @param filter_by_confidence If TRUE, filters records by confidence level
#'
#' @return Data frame with processed fire spot data
#'
#' @details
#' This function performs basic data quality checks and standardization:
#' \enumerate{
#'   \item Ensures required columns are present
#'   \item Standardizes data types
#'   \item Removes or flags suspicious records
#'   \item Adds derived columns if needed
#' }
#'
#' @examples
#' \dontrun{
#' dados_brutos <- download_focos(
#'   start_date = "2023-08-01",
#'   end_date   = "2023-09-30"
#' )
#'
#' dados_processados <- processar_focos(dados_brutos)
#' }
#'
#' @export
processar_focos <- function(
  dados,
  remove_duplicates    = TRUE,
  filter_by_confidence = FALSE
) {
  message("Processing fire spot data...")

  if (is.null(dados) || nrow(dados) == 0) {
    message("No data to process.")
    return(dados)
  }

  # Ensure required columns exist
  required_cols <- c("latitude", "longitude", "data_pas")
  missing_cols  <- setdiff(required_cols, names(dados))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # Standardize data types
  dados$latitude  <- as.numeric(dados$latitude)
  dados$longitude <- as.numeric(dados$longitude)

  if (!inherits(dados$data_pas, "POSIXct")) {
    dados$data_pas <- as.POSIXct(dados$data_pas, tz = "GMT")
  }

  # Remove records with missing coordinates
  dados <- dados[!is.na(dados$latitude) & !is.na(dados$longitude), ]

  # Remove duplicates if requested
  if (remove_duplicates && nrow(dados) > 0) {
    dedup_cols <- c("latitude", "longitude", "data_pas", "municipio")
    dedup_cols <- intersect(dedup_cols, names(dados))
    if (length(dedup_cols) > 0) {
      dados <- dados[!duplicated(dados[, dedup_cols, drop = FALSE]), ]
    }
  }

  message(sprintf("Processing complete. %d records retained.", nrow(dados)))
  return(dados)
}

#' Generate Map with Fire Spots
#'
#' Creates a map visualization of fire spot locations with optional
#' color coding by intensity or other variables.
#'
#' @param dados Data frame with processed fire spot data
#' @param color_by Column name to use for color coding (default: "frp")
#' @param title Map title (optional)
#' @param show_grid If TRUE, displays grid lines
#'
#' @return ggplot object with the map
#'
#' @details
#' This function creates a scatter plot map of fire spots. The color
#' intensity can represent different variables such as:
#' \itemize{
#'   \item frp: Radiative Power (MW)
#'   \item risco_fogo: Fire Risk
#'   \item numero_dias_sem_chuva: Days Without Rain
#' }
#'
#' @examples
#' \dontrun{
#' dados <- download_focos(
#'   start_date = "2023-08-01",
#'   end_date   = "2023-09-30"
#' )
#'
#' dados_processados <- processar_focos(dados)
#'
#' # Create map colored by radiative power
#' mapa <- mapa_focos(dados_processados, color_by = "frp")
#' print(mapa)
#'
#' # Create map colored by fire risk
#' mapa <- mapa_focos(dados_processados, color_by = "risco_fogo")
#' print(mapa)
#' }
#'
#' @export
mapa_focos <- function(
  dados,
  color_by  = "frp",
  title     = NULL,
  show_grid = TRUE
) {
  message("Generating map...")

  # Verify ggplot2 is available
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package ggplot2 is required for this function. Install it with: install.packages('ggplot2')")
  }

  if (is.null(dados) || nrow(dados) == 0) {
    stop("No data available to create map.")
  }

  # Verify required columns exist
  if (!all(c("latitude", "longitude") %in% names(dados))) {
    stop("Data must contain 'latitude' and 'longitude' columns.")
  }

  # Check if color_by column exists
  if (!color_by %in% names(dados)) {
    warning(sprintf("Column '%s' not found. Using default coloring.", color_by))
    color_by <- NULL
  }

  # Create base plot
  if (is.null(color_by)) {
    p <- ggplot2::ggplot(dados, ggplot2::aes(x = longitude, y = latitude)) +
      ggplot2::geom_point(color = "red", alpha = 0.6, size = 2)
  } else {
    p <- ggplot2::ggplot(dados, ggplot2::aes(x = longitude, y = latitude)) +
      ggplot2::geom_point(ggplot2::aes(color = .data[[color_by]]), alpha = 0.6, size = 2) +
      ggplot2::scale_color_gradient(low = "yellow", high = "red", name = color_by)
  }

  # Add theme and labels
  p <- p +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = title %||% "Fire Spot Distribution",
      x = "Longitude",
      y = "Latitude"
    ) +
    ggplot2::coord_fixed()

  # Add grid if requested
  if (show_grid) {
    p <- p + ggplot2::theme(panel.grid.major = ggplot2::element_line(color = "gray90"))
  }

  return(p)
}

# Helper function for NULL coalescing operator
`%||%` <- function(x, y) if (is.null(x)) y else x
