# Single stage on purpose: the official MySQL image is the runtime. The schema is
# created by the back-end migrations, so no init script is copied.
FROM mysql:8.4.4

EXPOSE 3306

# mysqladmin ping succeeds once the server accepts connections.
HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=10     CMD mysqladmin ping -h 127.0.0.1 --silent || exit 1

LABEL org.opencontainers.image.source="https://github.com/projeto-doceterapia/banco-de-dados"       org.opencontainers.image.title="doceterapia-banco-de-dados"       org.opencontainers.image.description="MySQL 8.4 for Doceterapia; schema applied by the back-end"
