#!/bin/bash

# Get the directory where this script is located
CHAIN_SCRIPTS_DIR=$(dirname "$0")

init_chain() {

    echo "[INFO | entrypoint] Initializing chain..."

    $SHUTTER_BIN chain init --root "${SHUTTER_CHAIN_DATA_DIR}" --genesis-keyper "${GENESIS_KEYPER}" --blocktime "${SM_BLOCKTIME}" --listen-address "tcp://0.0.0.0:${CHAIN_LISTEN_PORT}" --role validator
}

configure_chain() {

    echo "[INFO | entrypoint] Configuring chain..."

    "$CHAIN_SCRIPTS_DIR/configure_shuttermint.sh"
}

run_chain() {
    $SHUTTER_BIN chain --config "$SHUTTER_CHAIN_CONFIG_FILE"
}

init_chain

configure_chain

run_chain
