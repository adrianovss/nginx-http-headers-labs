ARG NGINX_VERSION=1.22.1

FROM nginx:$NGINX_VERSION

ARG NGINX_VERSION=1.22.1
ARG HEADERS_MORE_VERSION=v0.34

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        libpcre++-dev \
        zlib1g-dev \
        libgeoip-dev \
        wget \
        git

RUN cd /opt \
    && git clone --depth 1 -b $HEADERS_MORE_VERSION --single-branch https://github.com/openresty/headers-more-nginx-module.git \
    && cd /opt/headers-more-nginx-module \
    && git submodule update --init \
    && cd /opt \
    && wget -O - http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar zxfv - \
    && mv /opt/nginx-$NGINX_VERSION /opt/nginx \
    && cd /opt/nginx \
    && ./configure --with-compat --add-dynamic-module=/opt/headers-more-nginx-module \
    && make modules 

FROM nginx:$NGINX_VERSION

COPY --from=0 /opt/nginx/objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules

RUN chmod -R 644 \
        /usr/lib/nginx/modules/ngx_http_headers_more_filter_module.so \
    && sed -i '1iload_module \/usr\/lib\/nginx\/modules\/ngx_http_headers_more_filter_module.so;' /etc/nginx/nginx.conf 


RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]