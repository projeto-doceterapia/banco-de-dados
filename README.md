# banco-de-dados

Imagem MySQL 8.4 da Doceterapia.

O banco nasce vazio: a imagem cria apenas o banco de `MYSQL_DATABASE` e o usuário de
`MYSQL_USER`, sem nenhum script de inicialização. Quem cria o schema é o back-end, com as
migrações Flyway, na primeira subida.

## Volume existente

Um volume criado por uma versão anterior da imagem já tem as tabelas do `scriptv4.sql`, mas
não tem o histórico do Flyway. O back-end recusa a subida com um erro de schema não vazio. O
mesmo acontece, por checksum, quando a migração já aplicada é editada. Nos dois casos, recrie
o volume (por exemplo, `docker compose down -v`), o que apaga todos os dados dele.

Publique o back-end com o Flyway antes desta imagem: o back-end anterior só valida o schema e
não sobe sobre um banco vazio.

## Arquivos históricos

Estes arquivos ficam só como histórico. Não são a fonte do schema, não entram na imagem e não
são mais atualizados:

- `scriptv4.sql`: schema (`DROP`/`CREATE DATABASE doce_terapia`), dados de seed demonstrativos,
  o backfill do livro-razão de estoque e as principais queries de relatório.
- `modelagemv4.mwb`: modelo do MySQL Workbench.

## Livro-razão de estoque e cargas iniciais de dados

O saldo de estoque (`insumo.quantidade_atual`) é um cache. O saldo real é a soma das
linhas de `movimentacao_estoque` de cada insumo, e apenas o serviço de movimentação
escreve o cache, na mesma transação.

Por isso, **toda carga inicial de dados futura deve criar estoque por meio de
movimentações, ou rodar o backfill de `SALDO_INICIAL` logo após a carga**. O bloco de
backfill em `scriptv4.sql` insere uma movimentação `SALDO_INICIAL` por insumo com saldo
diferente de zero, de modo que `SUM(movimentacao_estoque.quantidade) = insumo.quantidade_atual`
para cada insumo. Ele é idempotente: pula os insumos que já possuem uma movimentação
`SALDO_INICIAL`, então é seguro rodá-lo novamente após carregar mais dados.

Se uma carga de dados escrever `insumo.quantidade_atual` diretamente sem uma movimentação
correspondente, o livro-razão e o cache ficarão divergentes até que o backfill seja rodado.

A idempotência do backfill é lógica, garantida pela verificação `NOT EXISTS`, não pela
chave única: `movimentacao_estoque.chave_idempotencia` é NULL para as linhas `SALDO_INICIAL`,
e as chaves únicas do MySQL ignoram NULLs, então rodar o bloco duas vezes depende do `NOT EXISTS`
para evitar duplicatas. Um insumo com `quantidade_atual` NULL é tratado como saldo 0, de modo
que nenhum insumo é pulado silenciosamente.

## Credenciais

`usuario.senha` deve armazenar apenas um hash de senha, nunca uma senha em texto puro.
