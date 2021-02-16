#!/bin/bash

# Basic implementation of a new docker image build script according to:
#   https://stackoverflow.com/a/42754636

set -Eeuo pipefail

ARCH=amd64
INFLUXDB_VERSION=1.8.4
CHRONOGRAF_VERSION=1.8.10
GRAFANA_VERSION=7.4.1

#------------------------------------------------------------------------------
# Download the influxDB, chronograf and Grafana
#------------------------------------------------------------------------------
# wget \
#     --no-verbose \
#     https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_${ARCH}.deb

# wget \
#     --no-verbose \
#     https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_${ARCH}.deb

# wget \
#     --no-verbose \
#     https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_${ARCH}.deb

#------------------------------------------------------------------------------
# Build the docker image
#------------------------------------------------------------------------------
docker \
    build \
    --build-arg \
    ARCH=${ARCH} \
    --build-arg \
    INFLUXDB_VERSION=${INFLUXDB_VERSION} \
    --build-arg \
    CHRONOGRAF_VERSION=${CHRONOGRAF_VERSION} \
    --build-arg \
    GRAFANA_VERSION=${GRAFANA_VERSION} \
    --tag \
    jeroenve/docker-influxdb-grafana:latest \
    .
