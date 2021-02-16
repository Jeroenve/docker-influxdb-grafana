FROM debian:buster-20210208-slim
LABEL maintainer="Phil Hawthorne <me@philhawthorne.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

ARG ARCH
ARG INFLUXDB_VERSION
ARG CHRONOGRAF_VERSION
ARG GRAFANA_VERSION

# Grafana database type
ENV GF_DATABASE_TYPE=sqlite3

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

WORKDIR /root

# Clear previous sources
RUN apt-get update -q \
    && apt-get install -qy --no-install-recommends \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        lsb-release
RUN apt-get update -q \
    && apt-get install -qy --no-install-recommends \
        adduser \
        curl \
        git \
        gnupg \
        htop \
        libfontconfig1 \
        nano \
        net-tools \
        supervisor \
        wget \
    && curl \
        --silent \
        --location \
        https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y \
        nodejs \
    && mkdir \
        --parents \
        /var/log/supervisor \
    && rm \
        --recursive \
        --force \
        .profile \
# Cleanup
    && echo "Cleanup" \
    && apt-get \
        -qq \
        clean \
    && rm \
        --force \
        --recursive \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

# Install InfluxDB
COPY influxdb_${INFLUXDB_VERSION}_${ARCH}.deb /tmp

RUN cd /tmp \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
# Cleanup
    && echo "Cleanup" \
    && apt-get \
        -qq \
        clean \
    && rm \
        --force \
        --recursive \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

# Install Chronograf
COPY chronograf_${CHRONOGRAF_VERSION}_${ARCH}.deb /tmp

RUN cd /tmp \
    && dpkg -i chronograf_${CHRONOGRAF_VERSION}_${ARCH}.deb && rm chronograf_${CHRONOGRAF_VERSION}_${ARCH}.deb \
# Cleanup
    && echo "Cleanup" \
    && apt-get \
        -qq \
        clean \
    && rm \
        --force \
        --recursive \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

# Install Grafana
COPY grafana_${GRAFANA_VERSION}_${ARCH}.deb /tmp
RUN cd /tmp \
    && dpkg -i grafana_${GRAFANA_VERSION}_${ARCH}.deb \
# Cleanup
    && echo "Cleanup" \
    && apt-get \
        -qq \
        clean \
    && rm \
        --force \
        --recursive \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

# Configure Supervisord and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY bash/profile .profile

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf

# Configure Grafana
COPY grafana/grafana.ini /etc/grafana/grafana.ini

COPY run.sh /run.sh
RUN ["chmod", "+x", "/run.sh"]
CMD ["/run.sh"]
