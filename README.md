# banco-de-dados

Target MySQL 8 schema for Doceterapia.

- `scriptv4.sql`: full schema (`DROP`/`CREATE DATABASE doce_terapia`), demonstrative
  seed data, the stock-ledger backfill, and the main report queries. It is aligned
  with the back-end JPA entities: the entity is the source of truth and the script
  follows it. The back-end runs with `ddl-auto=validate` against a database built
  from this script.
- `modelagemv4.mwb`: MySQL Workbench model. Edited only inside Workbench.

## Stock ledger and initial data loads

The stock balance (`insumo.quantidade_atual`) is a cache. The real balance is the
sum of `movimentacao_estoque` rows for each supply, and only the movement service
writes the cache, in the same transaction.

Because of that, **any future initial data load must create stock through movements,
or run the `SALDO_INICIAL` backfill right after loading**. The backfill block in
`scriptv4.sql` inserts one `SALDO_INICIAL` movement per supply with a non-zero balance,
so that `SUM(movimentacao_estoque.quantidade) = insumo.quantidade_atual` for every
supply. It is idempotent: it skips supplies that already have a `SALDO_INICIAL`
movement, so it is safe to run again after loading more data.

If a data load writes `insumo.quantidade_atual` directly without a matching movement,
the ledger and the cache will disagree until the backfill is run.

The backfill's idempotency is logical, enforced by the `NOT EXISTS` check, not by the
unique key: `movimentacao_estoque.chave_idempotencia` is NULL for `SALDO_INICIAL` rows,
and MySQL unique keys ignore NULLs, so running the block twice relies on `NOT EXISTS`
to avoid duplicates. A supply with a NULL `quantidade_atual` is treated as balance 0, so
no supply is silently skipped.

## Credentials

`usuario.senha` must store only a password hash, never a plaintext password.
