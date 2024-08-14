ARG UPSTREAM_VERSION
ARG NETWORK

FROM ghcr.io/shutter-network/rolling-shutter:${UPSTREAM_VERSION}

ARG NETWORK

ENV SHUTTER_DATABASEURL=postgres://postgres@db.shutter-${NETWORK}.dappnode:5432/keyper