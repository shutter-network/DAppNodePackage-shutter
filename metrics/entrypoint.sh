#!/bin/sh

update_user_settings() {
    key=$1
    value=$(eval echo \$$key)

    if [ ! -f "$USER_SETTINGS_FILE" ]; then
        touch "$USER_SETTINGS_FILE"
    fi

    if [ -z "$value" ]; then
        echo "[INFO | metrics] Skipped updating $key in user settings file (empty value)"
        return 1
    fi

    if grep -q "^$key=" "$USER_SETTINGS_FILE"; then
        # Update the existing key
        sed -i "s/^$key=.*/$key=$value/" "$USER_SETTINGS_FILE"
        echo "[INFO | metrics] Updated $key to $value in $USER_SETTINGS_FILE"
    else
        # Add the new key
        echo "$key=$value" >>"$USER_SETTINGS_FILE"
        echo "[INFO | metrics] Added $key=$value to $USER_SETTINGS_FILE"
    fi
}

source_envs() {
    set -a

    # shellcheck disable=SC1091
    if [ -f "${ASSETS_DIR}/variables.env" ]; then
        . "${ASSETS_DIR}/variables.env"

    else
        echo "[ERROR | configure] Missing variables file (${ASSETS_DIR}/variables.env)"
        exit 1
    fi

    if [ -z "${_ASSETS_VERSION:-}" ]; then
        _ASSETS_VERSION="$(cat /assets/version)"
    fi

    # shellcheck disable=SC1090
    . "$USER_SETTINGS_FILE"

    set +a
}

# Create an empty JSON file in path USER_SETTINGS_FILE if it does not exist
if [ ! -f "${USER_SETTINGS_FILE}" ]; then
    echo "{}" >"${USER_SETTINGS_FILE}"
fi

update_user_settings "PUSHGATEWAY_URL" "${PUSHGATEWAY_URL}"
update_user_settings "PUSHGATEWAY_USERNAME" "${PUSHGATEWAY_USERNAME}"
update_user_settings "PUSHGATEWAY_PASSWORD" "${PUSHGATEWAY_PASSWORD}"

if [ "${SHUTTER_PUSH_METRICS_ENABLED}" = "false" ]; then
    echo "[INFO | metrics] Metrics push is disabled"
    exit 0
fi

source_envs

exec /vmagent-prod \
    -promscrape.config="${CONFIG_FILE}" \
    -remoteWrite.url="${PUSHGATEWAY_URL}" \
    -remoteWrite.basicAuth.username="${PUSHGATEWAY_USERNAME}" \
    -remoteWrite.basicAuth.password="${PUSHGATEWAY_PASSWORD}"
