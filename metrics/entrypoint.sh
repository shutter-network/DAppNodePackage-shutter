#!/bin/sh

if [ "${SHUTTER_PUSH_METRICS_ENABLED}" = "false" ]; then
    echo "[INFO | metrics] Metrics push is disabled"
    exit 0
fi

set -eu

set -a

# shellcheck disable=SC1091
if [ -f "${ASSETS_DIR}/variables.env" ]; then
    . "${ASSETS_DIR}/variables.env"
else
    echo "[ERROR | configure] Missing variables file (${ASSETS_DIR}/variables.env)"
    exit 1
fi

set +a

# TODO: Update script with upstream version
if [ -z "${_ASSETS_VERSION:-}" ]; then
    _ASSETS_VERSION="$(cat /assets/version)"
    export _ASSETS_VERSION
fi

exec /vmagent-prod \
    -promscrape.config="${CONFIG_FILE}" \
    -remoteWrite.url="${PUSHGATEWAY_URL}" \
    -remoteWrite.basicAuth.username="${PUSHGATEWAY_USERNAME}" \
    -remoteWrite.basicAuth.password="${PUSHGATEWAY_PASSWORD}"
