# Contribuindo para o Pacote queimadasR

Obrigado por considerar contribuir para o pacote queimadasR! Este documento fornece diretrizes e instruções para contribuir.

## Como Contribuir

### Reportando Bugs

Antes de criar um relatório de bug, verifique se o problema já não foi reportado. Se você encontrar um bug, abra uma issue descrevendo:

- Uma descrição clara do problema
- Passos para reproduzir o problema
- Exemplos específicos para demonstrar os passos
- Comportamento observado e o que você esperava
- Sua configuração (versão do R, sistema operacional, etc.)

### Sugerindo Melhorias

As sugestões de melhorias são bem-vindas. Ao criar uma sugestão de melhoria, inclua:

- Uma descrição clara da melhoria sugerida
- Exemplos de como a melhoria funcionaria
- Possíveis casos de uso
- Referências a outras ferramentas ou pacotes similares

### Pull Requests

- Faça um fork do repositório
- Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
- Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
- Push para a branch (`git push origin feature/AmazingFeature`)
- Abra um Pull Request

## Diretrizes de Desenvolvimento

### Estilo de Código

- Siga o estilo de código R padrão (snake_case para funções e variáveis)
- Use comentários para explicar código complexo
- Mantenha as linhas com menos de 80 caracteres quando possível

### Documentação

- Todas as funções exportadas devem ter documentação roxygen2
- Inclua exemplos na documentação das funções
- Atualize o README se necessário

### Testes

- Adicione testes para novas funcionalidades
- Execute `devtools::test()` antes de fazer um pull request
- Mantenha a cobertura de testes acima de 80%

### Commits

- Use mensagens de commit claras e descritivas
- Referencie issues relacionadas nas mensagens de commit
- Um commit deve representar uma mudança lógica

## Processo de Revisão

Após enviar um pull request:

1. Um mantenedor revisará seu código
2. Podem ser solicitadas mudanças
3. Uma vez aprovado, seu PR será mesclado

## Código de Conduta

Este projeto adota um Código de Conduta para garantir um ambiente acolhedor para todos. Esperamos que todos os contribuidores sigam este código em todas as interações.

## Dúvidas?

Sinta-se livre para abrir uma issue com a tag `question` ou entrar em contato com os mantenedores.

Obrigado por contribuir!
