FROM alpine:3.15

RUN \
  # security
  apk add -U --no-cache --upgrade busybox && \
  # download
  apk add -U --no-cache autoconf autoconf-doc automake curl c-ares c-ares-dev gcc patch python3-dev libc-dev libevent libevent-dev libtool make openssl-dev pkgconfig postgresql-client bash

ADD . /tmp/pgbouncer

RUN \
  # compile
  cd /tmp/pgbouncer && \
  ./autogen.sh && \
  ./configure --prefix=/usr --with-cares && \
  make && \
  # install
  cp pgbouncer /usr/bin && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  cp etc/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini.example && \
  cp etc/userlist.txt /etc/pgbouncer/userlist.txt.example && \
  touch /etc/pgbouncer/userlist.txt && \
  chown -R postgres /var/run/pgbouncer /etc/pgbouncer && \
  # cleanup
  cd /tmp && \
  rm -rf /tmp/pgbouncer* && \
  apk del --purge autoconf autoconf-doc automake curl c-ares-dev gcc patch libc-dev libevent-dev libtool make openssl-dev pkgconfig

USER postgres
EXPOSE 5432
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]