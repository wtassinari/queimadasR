#' queimadasR: Download e Análise de Dados de Queimadas do INPE
#'
#' O pacote queimadasR fornece funções para download e processamento de dados
#' de queimadas do Banco de Dados de Queimadas (BDQUEIMADAS) do Instituto
#' Nacional de Pesquisas Espaciais (INPE).
#'
#' @docType package
#' @name queimadasR
#' @import utils
#'
#' @section Funções Principais:
#' \itemize{
#'   \item \code{\link{download_focos_anual_periodo}}: Baixa dados consolidados
#'     de focos de queimadas para um período especificado
#' }
#'
#' @section Recursos:
#' \itemize{
#'   \item Download automático de dados anuais do BDQUEIMADAS
#'   \item Filtros por período, estados e satélites
#'   \item Deduplicação automática de registros
#'   \item Tratamento robusto de erros e timeouts
#'   \item Compatibilidade com múltiplos formatos de data/hora
#'   \item Aliases de satélites para compatibilidade com dados históricos
#' }
#'
#' @section Fonte de Dados:
#' Os dados são obtidos do Banco de Dados de Queimadas (BDQUEIMADAS) do INPE,
#' disponível em: \url{https://terrabrasilis.dpi.inpe.br/queimadas/bdqueimadas/}
#'
#' @examples
#' \dontrun{
#' # Baixar dados de queimadas para a região Norte em agosto-setembro de 2023
#' estados_norte <- c("ACRE", "AMAPÁ", "AMAZONAS", "PARÁ", "RONDÔNIA", "RORAIMA", "TOCANTINS")
#' dados <- download_focos_anual_periodo(
#'   data_inicio_str = "01/08/2023",
#'   data_fim_str = "30/09/2023",
#'   estados_alvo = estados_norte
#' )
#' }
#'
NULL
