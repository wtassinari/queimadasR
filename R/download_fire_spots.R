#' Download Annual Wildfire Data from BDQUEIMADAS
#'
#' Downloads consolidated fire spot data from the Brazilian Wildfire Database
#' (BDQUEIMADAS) of the National Institute for Space Research (INPE). Allows
#' filtering by period, states, and satellites, with optional automatic deduplication.
#'
#' @param start_date_str Start date of the period in "DD/MM/YYYY" format
#' @param end_date_str End date of the period in "DD/MM/YYYY" format
#' @param region Region of interest (default: "Brasil")
#' @param target_states Character vector of state names to filter by (e.g., c("ACRE", "AMAZONAS")).
#'   If NULL, no state filter is applied.
#' @param target_satellites Character vector of satellite names to filter by (e.g., c("GOES-16", "AQUA_T")).
#'   If NULL or "ALL", all available satellites are used.
#' @param timeout Timeout in seconds for download (default: 300)
#' @param sleep_sec Wait time in seconds between downloads (default: 1)
#' @param show_satellites_when_empty If TRUE, shows available satellites when the
#'   satellite filter returns zero records
#' @param deduplicate_final If TRUE, removes duplicate records at the end
#' @param dedup_keys Character vector of column names used for deduplication
#'
#' @return Data frame with filtered and processed wildfire data
#'
#' @details
#' The function performs the following steps:
#' \enumerate{
#'   \item Validates input dates
#'   \item Identifies the years in the period
#'   \item For each year, downloads the consolidated ZIP file from BDQUEIMADAS
#'   \item Extracts and reads the CSV inside the ZIP
#'   \item Automatically detects the date/time column
#'   \item Filters by period, state, and satellite
#'   \item Combines data from all years
#'   \item Removes duplicates (optional)
#' }
#'
#' Satellite names are automatically normalized. Supported aliases:
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
#' # Example 1: Download all satellites for the Northern region
#' north_states <- c("ACRE", "AMAPA", "AMAZONAS", "PARA", "RONDONIA", "RORAIMA", "TOCANTINS")
#' north_data <- download_fire_spots(
#'   start_date_str = "01/08/2023",
#'   end_date_str = "30/09/2023",
#'   target_states = north_states,
#'   deduplicate_final = TRUE
#' )
#'
#' # Example 2: Download only GOES-16 and AQUA_T
#' filtered_data <- download_fire_spots(
#'   start_date_str    = "15/08/2022",
#'   end_date_str      = "30/09/2022",
#'   target_states     = c("MATO GROSSO", "TOCANTINS"),
#'   target_satellites = c("GOES-16", "AQUA_T"),
#'   deduplicate_final = TRUE
#' )
#' }
#'
#' @export
download_fire_spots <- function(
  start_date_str, end_date_str,
  region = "Brasil",
  target_states = NULL,
  target_satellites = NULL,
  timeout = 300,
  sleep_sec = 1,
  show_satellites_when_empty = TRUE,
  deduplicate_final = TRUE,
  dedup_keys = c("latitude", "longitude", "data_pas", "municipio")
) {
  options(timeout = timeout)

  # ---------------------------
  # Helper functions
  # ---------------------------

  # Normalize plain text: uppercase, trim whitespace, remove accents
  norm_txt <- function(x) {
    x <- toupper(trimws(x))
    x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
    x
  }

  # Normalize satellite names: uppercase, trim, remove spaces and hyphens
  norm_sat <- function(x) {
    x <- toupper(trimws(x))
    x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
    x <- gsub("[[:space:]]+", "", x)
    x <- gsub("-", "_", x)
    x <- gsub("__+", "_", x)
    x
  }

  # Parse datetime strings to POSIXct in GMT, trying multiple formats
  parse_datetime_gmt <- function(x) {
    as.POSIXct(
      x,
      tz = "GMT",
      tryFormats = c(
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%d/%m/%Y %H:%M:%S",
        "%d/%m/%Y %H:%M",
        "%Y-%m-%d"
      )
    )
  }

  # Detect which column holds the actual datetime (compatible across multiple years)
  find_datetime_column <- function(df) {
    candidates <- c(
      "data_pas",
      "data_hora_gmt", "datahora_gmt",
      "data_hora", "datahora",
      "data_passagem", "datahora_passagem"
    )

    # Also try any column whose name starts with "data"
    candidates <- unique(c(candidates, grep("^data", names(df), ignore.case = TRUE, value = TRUE)))
    candidates <- intersect(candidates, names(df))
    if (length(candidates) == 0) {
      return(NULL)
    }

    best <- NULL
    best_ok <- -1L
    for (nm in candidates) {
      x <- parse_datetime_gmt(df[[nm]])
      ok <- sum(!is.na(x))
      if (ok > best_ok) {
        best_ok <- ok
        best <- nm
      }
    }
    best
  }

  # Satellite aliases (maps modern labels to legacy labels)
  sat_alias <- list(
    "AQUA_T"  = c("AQUA_T", "AQUA_M-T", "AQUA_M_T", "AQUA_M-M", "AQUA_M_M"),
    "TERRA_T" = c("TERRA_T", "TERRA_M-T", "TERRA_M_T", "TERRA_M-M", "TERRA_M_M"),
    "GOES_16" = c("GOES-16", "GOES_16", "GOES-16D", "GOES_16D"),
    "GOES_13" = c("GOES-13", "GOES_13", "GOES-13D", "GOES_13D"),
    "NPP_375" = c("NPP-375", "NPP_375", "NPP-375D", "NPP_375D", "SUOMI_NPP_375", "SUOMI_NPP_375D")
  )
  sat_alias <- lapply(sat_alias, norm_sat)
  names(sat_alias) <- norm_sat(names(sat_alias))

  # Expand satellite names to include all known aliases
  expand_sats <- function(sats) {
    if (is.null(sats)) {
      return(NULL)
    }
    s_norm <- norm_sat(sats)
    unique(unlist(lapply(s_norm, function(s) {
      if (s %in% names(sat_alias)) sat_alias[[s]] else s
    })))
  }

  # Remove duplicate fire spot records based on key columns
  dedup_fire_spots <- function(df, keys) {
    missing_cols <- setdiff(keys, names(df))
    if (length(missing_cols) > 0) {
      stop("Cannot deduplicate: missing columns: ", paste(missing_cols, collapse = ", "))
    }

    # Standardize municipality name to reduce duplicates from accent/case/spacing variations
    df$municipio <- norm_txt(df$municipio)

    # Ensure data_pas is POSIXct in GMT
    if (!inherits(df$data_pas, "POSIXct")) {
      df$data_pas <- parse_datetime_gmt(df$data_pas)
    }

    df[!duplicated(df[, keys, drop = FALSE]), , drop = FALSE]
  }

  # ---------------------------
  # Parse input dates
  # ---------------------------
  start_date <- as.Date(start_date_str, format = "%d/%m/%Y")
  end_date <- as.Date(end_date_str, format = "%d/%m/%Y")
  if (is.na(start_date) || is.na(end_date)) stop("Invalid date format. Use 'DD/MM/YYYY'.")
  if (end_date < start_date) stop("end_date must be >= start_date.")

  start_year <- as.integer(format(start_date, "%Y"))
  end_year <- as.integer(format(end_date, "%Y"))
  years <- seq(start_year, end_year)

  dt_start <- as.POSIXct(paste0(format(start_date, "%Y-%m-%d"), " 00:00:00"), tz = "GMT")
  dt_end <- as.POSIXct(paste0(format(end_date, "%Y-%m-%d"), " 23:59:59"), tz = "GMT")

  use_all_satellites <- is.null(target_satellites) ||
    (length(target_satellites) == 1 && toupper(target_satellites) %in% c("TODOS", "ALL"))

  cat("\n=== DOWNLOADING ANNUAL CONSOLIDATED DATA FROM BDQUEIMADAS ===\n")
  cat("Filter Period:", start_date_str, "to", end_date_str, "\n")
  cat("Years to Download:", paste(years, collapse = ", "), "\n")
  cat("Region:", region, "\n")
  if (!is.null(target_states)) cat("Filtering by States:", paste(target_states, collapse = ", "), "\n")
  if (use_all_satellites) {
    cat("Filtering by Satellites: ALL\n")
  } else {
    cat("Filtering by Satellites (input):", paste(target_satellites, collapse = ", "), "\n")
  }
  cat("Timeout configured:", timeout, "seconds\n\n")

  # ---------------------------
  # Loop over years
  # ---------------------------
  data_list <- vector("list", length(years))
  success_count <- 0L
  error_count <- 0L

  for (i in seq_along(years)) {
    current_year <- years[i]
    file_name <- paste0("focos_br_todos-sats_", current_year, ".zip")
    url <- paste0(
      "https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/",
      file_name
    )

    cat(sprintf("[%d/%d] %s ... ", i, length(years), current_year))

    temp_dir <- tempdir()
    local_file <- file.path(temp_dir, file_name)

    res <- tryCatch(
      {
        # Download file
        status <- utils::download.file(url, local_file,
          mode = "wb",
          quiet = TRUE, method = "auto"
        )
        if (status != 0) stop("Download failed (download.file returned != 0).")

        # Find CSV inside the ZIP
        zip_list <- utils::unzip(local_file, list = TRUE)
        csvs <-
          zip_list$Name[grepl("\\.csv$", zip_list$Name, ignore.case = TRUE)]
        if (length(csvs) == 0) stop("ZIP does not contain a CSV file.")
        csv_in_zip <- csvs[1]

        # Read CSV directly from the ZIP
        year_data <- utils::read.csv(unz(local_file, csv_in_zip),
          stringsAsFactors = FALSE
        )

        # Detect datetime column and standardize as data_pas
        dt_col <- find_datetime_column(year_data)
        if (is.null(dt_col)) {
          stop(paste0("Could not find a datetime column. Columns found: ", paste(names(year_data), collapse = ", ")))
        }

        dt_parsed <- parse_datetime_gmt(year_data[[dt_col]])
        if (all(is.na(dt_parsed))) stop(paste0("Failed to convert datetime column: ", dt_col))

        # Ensure data_pas column is always present as POSIXct
        year_data$data_pas <- dt_parsed

        # Filter by period
        filtered_data <- year_data[year_data$data_pas >= dt_start & year_data$data_pas <= dt_end, , drop = FALSE]

        # Filter by state
        if (!is.null(target_states) && region == "Brasil") {
          uf_candidates <- c("estado", "uf", "sigla_uf", "estado_sigla")
          uf_col <- intersect(uf_candidates, names(filtered_data))
          if (length(uf_col) > 0) {
            uf_col <- uf_col[1]
            target_norm <- norm_txt(target_states)
            filtered_data <- filtered_data[norm_txt(filtered_data[[uf_col]]) %in% target_norm, , drop = FALSE]
          } else {
            warning("State filter was requested, but no 'estado/uf' column was found.")
          }
        }

        # Filter by satellite (with aliases), only if NOT using all satellites
        if (!use_all_satellites && region == "Brasil") {
          sat_candidates <- c("satelite", "satellite", "sensor")
          sat_col <- intersect(sat_candidates, names(filtered_data))
          if (length(sat_col) > 0) {
            sat_col <- sat_col[1]

            expanded_targets <- expand_sats(target_satellites) # normalized
            sat_vals_norm <- norm_sat(filtered_data[[sat_col]])

            filtered_data2 <- filtered_data[sat_vals_norm %in% expanded_targets, , drop = FALSE]

            if (nrow(filtered_data2) == 0L && show_satellites_when_empty) {
              top_sats <- sort(table(norm_sat(filtered_data[[sat_col]])), decreasing = TRUE)
              top_sats <- utils::head(top_sats, 10)
              cat("\n    Warning: satellite filter returned zero records for this year. Available satellites (top 10):\n")
              print(top_sats)
            }

            filtered_data <- filtered_data2
          } else {
            warning("Satellite filter was requested, but no 'satelite/satellite/sensor' column was found.")
          }
        }

        # Tag reference year
        filtered_data$ref_year <- rep.int(current_year, nrow(filtered_data))

        # Clean up ZIP file
        if (file.exists(local_file)) file.remove(local_file)

        list(ok = TRUE, data = filtered_data)
      },
      error = function(e) {
        if (file.exists(local_file)) file.remove(local_file)
        list(ok = FALSE, err = conditionMessage(e))
      }
    )

    if (isTRUE(res$ok)) {
      data_list[[i]] <- res$data
      success_count <- success_count + 1L
      cat("\\u2713 (", format(nrow(res$data), big.mark = ","), "fire spots)\n")
      Sys.sleep(sleep_sec)
    } else {
      error_count <- error_count + 1L
      data_list[[i]] <- NULL
      cat("\\u2717 Error\n")
      cat("    Details:", res$err, "\n")
    }
  }

  cat("\n=== DOWNLOAD SUMMARY ===\n")
  cat("Successes:", success_count, "/", length(years), "\n")
  cat("Errors:", error_count, "\n")

  if (success_count == 0L) {
    cat("\nNo data was successfully downloaded.\n")
    return(NULL)
  }

  cat("\nCombining data...\n")
  complete_data <- do.call(rbind.data.frame, data_list[!vapply(data_list, is.null, logical(1))])
  cat("Total (before deduplication):", format(nrow(complete_data), big.mark = ","), "\n")
  cat(
    "Memory size:",
    format(utils::object.size(complete_data), units = "MB"),
    "\n"
  )

  if (isTRUE(deduplicate_final)) {
    cat("\nDeduplicating by:", paste(dedup_keys, collapse = ", "), "...\n")
    before <- nrow(complete_data)
    complete_data <- dedup_fire_spots(complete_data, dedup_keys)
    after <- nrow(complete_data)
    cat("Removed:", format(before - after, big.mark = ","), "duplicates.\n")
    cat("Total (after deduplication):", format(after, big.mark = ","), "\n")
  }

  cat("\n=== DOWNLOAD COMPLETED SUCCESSFULLY ===\n\n")
  complete_data
}
