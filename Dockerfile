FROM alpine

ENV DEPS="python3 py3-pip py3-cffi py3-cairo libstdc++" \
    DEPS_BUILD="shadow python3-dev gcc libc-dev" \
	GRAPHITE_VERSION="1.1.5" \
	GUNICORN_VERSION="19.9.0"

RUN apk -U upgrade \
 && apk add nginx apache2-utils $DEPS \
 && ln -sv /usr/bin/pip3 /usr/local/bin/pip \
 && ln -sv /usr/bin/python3 /usr/local/bin/python \
 && apk add $DEPS_BUILD \
 && pip install \
      --no-cache-dir --install-option="--install-scripts=/opt/graphite/bin" \
      gunicorn=="$GUNICORN_VERSION" \
      whisper=="$GRAPHITE_VERSION" graphite-web=="$GRAPHITE_VERSION" \
 && groupadd -g 1000 graphite \
 && useradd -g 1000 -u 1000 -d /opt/graphite graphite \
 && chown -R graphite.graphite /opt/graphite/conf /opt/graphite/storage /var/lib/nginx /var/log/nginx /var/tmp/nginx \
 && ln -s /opt/graphite/conf/local_settings.py /opt/graphite/webapp/graphite/local_settings.py \
 && (echo 'export PATH=/opt/graphite/bin:$PATH' >> /etc/profile) \
 && apk del $DEPS_BUILD \
 && rm -f /var/cache/apk/* \
 && rm -rf /opt/graphite/storage/*

COPY files/ /

EXPOSE 8080
ENV PATH="/opt/graphite/bin:${PATH}" \
    PYTHONPATH="/opt/graphite/webapp"
WORKDIR /opt/graphite
VOLUME /opt/graphite/storage
USER graphite

ENTRYPOINT ["/docker-entrypoint"]
CMD ["/startup"]
