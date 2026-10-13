# Single stage on purpose: there is nothing to compile, the official
# MySQL image is the runtime, and it runs scripts in
# /docker-entrypoint-initdb.d on first start with an empty volume.
FROM mysql:8.4.4

# scriptv4.sql creates the doce_terapia schema on first initialization.
COPY scriptv4.sql /docker-entrypoint-initdb.d/scriptv4.sql

EXPOSE 3306

# mysqladmin ping succeeds once the server accepts connections.
HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=10 \
    CMD mysqladmin ping -h 127.0.0.1 --silent || exit 1

LABEL org.opencontainers.image.source="https://github.com/projeto-doceterapia/banco-de-dados" \
      org.opencontainers.image.title="doceterapia-banco-de-dados" \
      org.opencontainers.image.description="MySQL 8.4 preloaded with the Doceterapia schema (scriptv4.sql)"
