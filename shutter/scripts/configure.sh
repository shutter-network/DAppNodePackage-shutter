#!/bin/bash

# To use staker scripts
# shellcheck disable=SC1091
. /etc/profile

generate_shutter_env_file() {
    supported_networks="gnosis"

    echo "[INFO | configure] Exporting configuration environment variables..."

    SHUTTER_P2P_ADVERTISEADDRESSES="/ip4/${_DAPPNODE_GLOBAL_PUBLIC_IP}/tcp/23003"
    SHUTTER_BEACONAPIURL=$(get_beacon_api_url_from_global_env "$NETWORK" "$supported_networks")
    SHUTTER_GNOSIS_NODE_CONTRACTSURL=http://execution.gnosis.dncore.dappnode:8545
    SHUTTER_GNOSIS_NODE_ETHEREUMURL=$(get_execution_ws_url_from_global_env "$NETWORK" "$supported_networks")

    # Create the shutter.env file with the environment variables
    cat >"$SHUTTER_ENV_FILE" <<EOF
export SHUTTER_P2P_ADVERTISEADDRESSES="${SHUTTER_P2P_ADVERTISEADDRESSES}"
export SHUTTER_BEACONAPIURL="${SHUTTER_BEACONAPIURL}"
export SHUTTER_GNOSIS_NODE_CONTRACTSURL="${SHUTTER_GNOSIS_NODE_CONTRACTSURL}"
export SHUTTER_GNOSIS_NODE_ETHEREUMURL="${SHUTTER_GNOSIS_NODE_ETHEREUMURL}"
EOF

    # Print the shutter.env file
    echo "[INFO | configure] Generated shutter.env file:"
    cat "$SHUTTER_ENV_FILE"
}

generate_keyper_config() {

    # Check if the configuration file already exists
    if [ -f "$SHUTTER_GENERATED_CONFIG_FILE" ]; then
        echo "[INFO | configure] Configuration file already exists. Skipping generation..."
        return
    fi

    echo "[INFO | configure] Generating configuration files..."

    $SHUTTER_BIN gnosiskeyper generate-config --output "$SHUTTER_GENERATED_CONFIG_FILE"
}

init_keyper_db() {
    echo "[INFO | configure] Waiting for the database to be ready..."

    until pg_isready -h "db.shutter-${NETWORK}.dappnode" -p 5432 -U postgres; do
        echo "[INFO | configure] Database is not ready yet. Retrying in 5 seconds..."
        sleep 5
    done

    echo "[INFO | configure] Initializing keyper database..."

    $SHUTTER_BIN gnosiskeyper initdb --config "$SHUTTER_GENERATED_CONFIG_FILE"
}

init_chain() {

    echo "[INFO | configure] Initializing chain..."

    $SHUTTER_BIN chain init --root "${SHUTTER_CHAIN_DATA_DIR}" --genesis-keyper "${SHUTTER_GNOSIS_GENESIS_KEYPER}" --blocktime "${SHUTTER_GNOSIS_SM_BLOCKTIME}" --listen-address "tcp://0.0.0.0:${CHAIN_LISTEN_PORT}" --role validator
}

configure_keyper() {

    echo "[INFO | configure] Configuring keyper..."

    "configure_keyper.sh"
}

configure_chain() {

    echo "[INFO | configure] Configuring chain..."

    "configure_shuttermint.sh"
}

trigger_chain_start() {

    echo "[INFO | configure] Triggering chain start..."

    supervisorctl start chain
}

trigger_keyper_start() {

    echo "[INFO | configure] Triggering keyper start..."

    supervisorctl start keyper
}

generate_shutter_env_file

# shellcheck disable=SC1090
source "$SHUTTER_ENV_FILE"

generate_keyper_config

init_keyper_db

init_chain

configure_keyper

configure_chain

trigger_chain_start

trigger_keyper_start
