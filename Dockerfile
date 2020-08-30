FROM joseluisq/static-web-server
COPY ./public /public/
ENV SERVER_PORT=8080
ENV SERVER_CORS_ALLOW_ORIGINS https://www.googletagmanager.com

