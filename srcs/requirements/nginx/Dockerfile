FROM debian:bookworm

RUN set -eux; \
	apt-get update && apt-get install -y \
	nginx openssl \
	&& rm -rf /var/lib/apt/lists/*


COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/generate_cert.sh /usr/local/bin/generate_cert.sh
RUN chmod +x /usr/local/bin/generate_cert.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx_setup.sh"] 

