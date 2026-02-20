# Guia de Instalação do Pacote queimadasR

## Pré-requisitos

- R >= 3.5.0
- Conexão com a internet para download dos dados

## Instalação do Pacote

### Opção 1: Instalação do GitHub (Recomendado)

```r
# Instalar remotes se necessário
install.packages("remotes")

# Instalar o pacote queimadasR
remotes::install_github("seu-usuario/queimadasR")
```

### Opção 2: Instalação do Arquivo Compilado

Se você tem o arquivo `queimadasR_0.1.0.tar.gz`:

```r
install.packages("/caminho/para/queimadasR_0.1.0.tar.gz", repos = NULL, type = "source")
```

### Opção 3: Instalação do Diretório

Se você tem o diretório do pacote:

```r
install.packages("/caminho/para/queimadasR", repos = NULL, type = "source")
```

## Verificação da Instalação

Para verificar se o pacote foi instalado corretamente:

```r
library(queimadasR)
?download_focos_anual_periodo
```

Se a documentação aparecer, a instalação foi bem-sucedida!

## Solução de Problemas

### Erro: "Package 'queimadasR' not found"

Certifique-se de que o caminho para o arquivo ou diretório está correto.

### Erro: "Cannot open file"

Verifique se você tem permissão de leitura no arquivo ou diretório.

### Erro: "Dependency not found"

O pacote `queimadasR` depende apenas do R base. Se receber este erro, tente reinstalar.

## Próximas Etapas

Após a instalação bem-sucedida, consulte o README.md para exemplos de uso.
