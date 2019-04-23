FROM alpine:3.9

LABEL description="Imagem contendo um serviço web e php-fpm"
LABEL maintainer="Rafael Dutra <raffaeldutra@gmail.com>"

ENV PHP_FPM_VERSION="~=7.2"
ENV NGINX_VERSION="~=1.14"

RUN apk add --update --no-cache \
    nginx=${NGINX_VERSION} \
    php7-fpm=${PHP_FPM_VERSION} \
    supervisor \
 && rm -rf /var/cache/apk/*

RUN mkdir -p /var/www/app

# Arquivos de configuração
COPY docker/php-fpm/pool.conf            /etc/php7/php-fpm.d/www.conf
COPY docker/nginx/nginx.conf             /etc/nginx/nginx.conf
COPY docker/supervisor/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf

# Todos arquivos e diretórios estão com o usuário nobody
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx

USER nobody
WORKDIR /var/www/app

EXPOSE 8080

# Para melhor controle de dois serviços em uma única imagem o uso é de supervisor fica mais facilitado
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]