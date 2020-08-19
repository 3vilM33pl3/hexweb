FROM joseluisq/static-web-server
COPY ./public /public/
ENV SERVER_PORT=$PORT


