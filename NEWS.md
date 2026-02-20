# queimadasR 0.1.0

## Versão Inicial

### Funcionalidades Principais

- `download_focos_anual_periodo()`: Função principal para download de dados de queimadas
  - Download automático de dados anuais consolidados do BDQUEIMADAS
  - Filtros por período, estados e satélites
  - Deduplicação automática de registros
  - Tratamento robusto de erros
  - Compatibilidade com múltiplos formatos de data/hora

### Recursos

- Suporte a aliases de satélites para compatibilidade histórica
- Normalização automática de nomes de estados e satélites
- Mensagens informativas durante o download
- Resumo detalhado do processo de download
- Limpeza automática de arquivos temporários

### Documentação

- Documentação completa das funções com roxygen2
- README com exemplos de uso
- Arquivo de exemplos extenso (examples.R)
- Testes unitários básicos

### Dependências

- R >= 3.5.0
- Pacote base: utils (download.file, unzip)

## Notas de Desenvolvimento

Esta é a versão inicial do pacote. Versões futuras podem incluir:

- Funções adicionais para análise de dados
- Integração com pacotes de visualização
- Suporte a download de dados diários (além de anuais)
- Cache local de dados
- Exportação para formatos adicionais
