#!/bin/bash

set -eu

# shellcheck disable=SC1091
if [[ -f ${ASSETS_DIR}/variables.env ]]; then
    . "${ASSETS_DIR}/variables.env"
else
    echo "[ERROR | configure-keyper.sh] Missing variables file (${ASSETS_DIR}/variables)"
    exit 1
fi

mv "$SHUTTER_GENERATED_CONFIG_FILE" "$KEYPER_CONFIG_FILE"

# Values set from assets container and compose env varibles
sed -i "/^InstanceID/c\InstanceID = ${_ASSETS_INSTANCE_ID}" "$KEYPER_CONFIG_FILE"
sed -i "/^DatabaseURL/c\DatabaseURL = \"${SHUTTER_DATABASEURL}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^BeaconAPIURL/c\BeaconAPIURL = \"${SHUTTER_BEACONAPIURL}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^MaxNumKeysPerMessage/c\MaxNumKeysPerMessage = ${_ASSETS_MAX_NUM_KEYS_PER_MESSAGE}" "$KEYPER_CONFIG_FILE"
sed -i "/^EncryptedGasLimit/c\EncryptedGasLimit = ${_ASSETS_ENCRYPTED_GAS_LIMIT}" "$KEYPER_CONFIG_FILE"
sed -i "/^MaxTxPointerAge/c\MaxTxPointerAge =  ${SHUTTER_GNOSIS_MAXTXPOINTERAGE}" "$KEYPER_CONFIG_FILE"
sed -i "/^GenesisSlotTimestamp/c\GenesisSlotTimestamp = ${_ASSETS_GENESIS_SLOT_TIMESTAMP}" "$KEYPER_CONFIG_FILE"
sed -i "/^SyncStartBlockNumber/c\SyncStartBlockNumber = ${_ASSETS_SYNC_START_BLOCK_NUMBER}" "$KEYPER_CONFIG_FILE"
sed -i "/^PrivateKey/c\PrivateKey = \"${SHUTTER_GNOSIS_NODE_PRIVATEKEY}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^ContractsURL/c\ContractsURL = \"${SHUTTER_GNOSIS_NODE_CONTRACTSURL}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^DeploymentDir/c\DeploymentDir = \"\"  # unused" "$KEYPER_CONFIG_FILE"
sed -i "/^EthereumURL/c\EthereumURL = \"${SHUTTER_GNOSIS_NODE_ETHEREUMURL}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^KeyperSetManager/c\KeyperSetManager = \"${_ASSETS_KEYPER_SET_MANAGER}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^KeyBroadcastContract/c\KeyBroadcastContract = \"${_ASSETS_KEY_BROADCAST_CONTRACT}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^Sequencer/c\Sequencer = \"${_ASSETS_SEQUENCER}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^ValidatorRegistry/c\ValidatorRegistry = \"${_ASSETS_VALIDATOR_REGISTRY}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^DiscoveryNamespace/c\DiscoveryNamespace = \"${_ASSETS_DISCOVERY_NAME_PREFIX}-${_ASSETS_INSTANCE_ID}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^ShuttermintURL/c\ShuttermintURL = \"${SHUTTER_SHUTTERMINT_SHUTTERMINTURL}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^ValidatorPublicKey/c\ValidatorPublicKey = \"$(cat /data/chain/config/priv_validator_pubkey.hex)\"" "$KEYPER_CONFIG_FILE"
sed -i "/^ListenAddresses/c\ListenAddresses = \"${SHUTTER_P2P_LISTENADDRESSES}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^AdvertiseAddresses/c\AdvertiseAddresses = \"${SHUTTER_P2P_ADVERTISEADDRESSES}\"" "$KEYPER_CONFIG_FILE"
sed -i "/^CustomBootstrapAddresses/c\CustomBootstrapAddresses = ${_ASSETS_CUSTOM_BOOTSTRAP_ADDRESSES}" "$KEYPER_CONFIG_FILE"
sed -i "/^DKGPhaseLength/c\DKGPhaseLength = ${_ASSETS_DKG_PHASE_LENGTH}" "$KEYPER_CONFIG_FILE"
sed -i "/^DKGStartBlockDelta/c\DKGStartBlockDelta = ${_ASSETS_DKG_START_BLOCK_DELTA}" "$KEYPER_CONFIG_FILE"
sed -i "/^Enabled/c\Enabled = ${SHUTTER_METRICS_ENABLED}" "$KEYPER_CONFIG_FILE"
