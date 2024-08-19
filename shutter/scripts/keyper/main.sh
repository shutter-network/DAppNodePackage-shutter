#!/bin/bash

# Get the directory where this script is located
KEYPER_SCRIPTS_DIR=$(dirname "$0")

# To use staker scripts
# shellcheck disable=SC1091
. /etc/profile

generate_config_envs() {
    supported_networks="gnosis"

    echo "[INFO | entrypoint] Exporting configuration environment variables..."

    SHUTTER_P2P_ADVERTISEADDRESSES="/ip4/${_DAPPNODE_GLOBAL_PUBLIC_IP}/tcp/23003"
    SHUTTER_BEACONAPIURL=$(get_beacon_api_url_from_global_env "$NETWORK" "$supported_networks")
    SHUTTER_GNOSIS_NODE_CONTRACTSURL=http://execution.gnosis.dncore.dappnode:8545
    SHUTTER_GNOSIS_NODE_ETHEREUMURL=$(get_execution_ws_url_from_global_env "$NETWORK" "$supported_networks")

    echo "[INFO | entrypoint] SHUTTER_P2P_ADVERTISEADDRESSES: $SHUTTER_P2P_ADVERTISEADDRESSES"
    echo "[INFO | entrypoint] SHUTTER_BEACONAPIURL: $SHUTTER_BEACONAPIURL"
    echo "[INFO | entrypoint] SHUTTER_GNOSIS_NODE_CONTRACTSURL: $SHUTTER_GNOSIS_NODE_CONTRACTSURL"
    echo "[INFO | entrypoint] SHUTTER_GNOSIS_NODE_ETHEREUMURL: $SHUTTER_GNOSIS_NODE_ETHEREUMURL"
}

generate_config() {

    # Check if the configuration file already exists
    if [ -f "$SHUTTER_GENERATED_CONFIG_FILE" ]; then
        echo "[INFO | entrypoint] Configuration file already exists. Skipping generation..."
        return
    fi

    echo "[INFO | entrypoint] Generating configuration files..."

    $SHUTTER_BIN gnosiskeyper generate-config --output "$SHUTTER_GENERATED_CONFIG_FILE"
}

init_keyper_db() {
    echo "[INFO | entrypoint] Waiting for the database to be ready..."

    until pg_isready -h "db.shutter-${NETWORK}.dappnode" -p 5432 -U postgres; do
        echo "[INFO | entrypoint] Database is not ready yet. Retrying in 5 seconds..."
        sleep 5
    done

    echo "[INFO | entrypoint] Initializing keyper database..."

    $SHUTTER_BIN gnosiskeyper initdb --config "$SHUTTER_GENERATED_CONFIG_FILE"
}

configure_keyper() {

    echo "[INFO | entrypoint] Configuring keyper..."

    "$KEYPER_SCRIPTS_DIR/configure_keyper.sh"
}

perform_chain_healthcheck() {
    echo "[INFO | entrypoint] Waiting for chain to be healthy..."

    while true; do
        # Perform the health check
        if curl -sf http://localhost:26657/status >/dev/null; then
            echo "[INFO | entrypoint] Service is healthy. Exiting health check loop."
            break # Exit the loop if the service is healthy
        else
            echo "[INFO | entrypoint] Service is not healthy yet. Retrying in 30 seconds..."
        fi

        # Wait for the next interval (30 seconds)
        sleep 30
    done
}

run_keyper() {
    $SHUTTER_BIN gnosiskeyper --config "$KEYPER_CONFIG_FILE"
}

generate_config_envs

export SHUTTER_P2P_ADVERTISEADDRESSES SHUTTER_BEACONAPIURL SHUTTER_GNOSIS_NODE_CONTRACTSURL SHUTTER_GNOSIS_NODE_ETHEREUMURL

generate_config

init_keyper_db

configure_keyper

perform_chain_healthcheck

run_keyper
