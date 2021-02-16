FROM debian:buster-20210208-slim
LABEL maintainer="Phil Hawthorne <me@philhawthorne.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV ARCH=amd64
#ARCH= && dpkgArch="$(dpkg --print-architecture)" && \
#    case "${dpkgArch##*-}" in \
#      amd64) ARCH='amd64';; \
#      arm64) ARCH='arm64';; \
#      armhf) ARCH='armhf';; \
#      armel) ARCH='armel';; \
#      *)     echo "Unsupported architecture: ${dpkgArch}"; exit 1;; \
#    esac \
#    && 

# Default versions
ENV INFLUXDB_VERSION=1.8.2
ENV CHRONOGRAF_VERSION=1.8.6
ENV GRAFANA_VERSION=7.2.0

# Grafana database type
ENV GF_DATABASE_TYPE=sqlite3

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

WORKDIR /root

# Clear previous sources
RUN apt-get update -q \
    && apt-get install -qy \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        git \
        htop \
        libfontconfig \
        nano \
        net-tools \
        supervisor \
        wget \
        gnupg \
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
RUN wget \
    --no-verbose \
    https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
    && rm influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
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
RUN wget \
    --no-verbose \
    https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_${ARCH}.deb \
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
RUN wget \
    --no-verbose \
    https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_${ARCH}.deb \
    && dpkg -i grafana_${GRAFANA_VERSION}_${ARCH}.deb \
    && rm grafana_${GRAFANA_VERSION}_${ARCH}.deb \
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
