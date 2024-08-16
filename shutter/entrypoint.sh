#!/bin/sh

# To use staker scripts
# shellcheck disable=SC1091
. /etc/profile

export_config_envs() {
    supported_networks="gnosis"

    SHUTTER_P2P_ADVERTISEADDRESSES="/ip4/${_DAPPNODE_GLOBAL_PUBLIC_IP}/tcp/23003"
    SHUTTER_BEACONAPIURL=$(get_beacon_api_url_from_global_env "$NETWORK" "$supported_networks")
    SHUTTER_GNOSIS_NODE_CONTRACTSURL=http://execution.mainnet.dncore.dappnode:8545
    SHUTTER_GNOSIS_NODE_ETHEREUMURL=$(get_execution_ws_url_from_global_env "$NETWORK" "$supported_networks")

    export SHUTTER_P2P_ADVERTISEADDRESSES SHUTTER_BEACONAPIURL SHUTTER_GNOSIS_NODE_CONTRACTSURL SHUTTER_GNOSIS_NODE_ETHEREUMURL
}

generate_config() {
    $SHUTTER_BIN gnosiskeyper generate-config --output "$SHUTTER_GENERATED_CONFIG_FILE"
}

init_keyper_db() {
    # TODO: DB must be running
    $SHUTTER_BIN gnosiskeyper initdb --config "$SHUTTER_GENERATED_CONFIG_FILE"
}

init_chain() {
    $SHUTTER_BIN chain init --root "${SHUTTER_CHAIN_DATA_DIR}" --genesis-keyper "${GENESIS_KEYPER}" --blocktime "${SM_BLOCKTIME}" --listen-address "tcp://0.0.0.0:${CHAIN_LISTEN_PORT}" --role validator
}

configure_keyper() {
    configure-keyper.sh
}

configure_chain() {
    configure-shuttermint.sh
}

run_shutter_node() {
    $SHUTTER_BIN chain --config "$SHUTTER_CHAIN_CONFIG_FILE"
}

perform_healthcheck() {
    echo "[INFO | entrypoint] Waiting for node to be healthy..."

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
