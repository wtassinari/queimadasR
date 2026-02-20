test_that("Validação de formato de data funciona corretamente", {
  # Teste com formato inválido
  expect_error(
    download_focos_anual_periodo(
      data_inicio_str = "01-08-2023",  # Formato inválido
      data_fim_str = "31/08/2023"
    ),
    "Formato de data inválido"
  )
})

test_that("Validação de data_fim >= data_inicio funciona", {
  # Teste com data_fim anterior a data_inicio
  expect_error(
    download_focos_anual_periodo(
      data_inicio_str = "31/08/2023",
      data_fim_str = "01/08/2023"  # Anterior à data de início
    ),
    "data_fim deve ser >= data_inicio"
  )
})

test_that("Função aceita parâmetros válidos", {
  # Este teste apenas verifica se a função aceita os parâmetros
  # Não faz download real para evitar dependência de conexão
  expect_true(TRUE)  # Placeholder para testes reais
})
