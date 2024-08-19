#!/bin/bash

run_chain() {

    echo "[INFO | chain] Starting chain..."

    $SHUTTER_BIN chain --config "$SHUTTER_CHAIN_CONFIG_FILE"
}

# shellcheck disable=SC1090
source "$SHUTTER_ENV_FILE"

run_chain
