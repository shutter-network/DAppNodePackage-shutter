ARG ASSETS_VERSION
ARG UPSTREAM_VERSION

FROM ghcr.io/shutter-network/assets:${ASSETS_VERSION} as assets

RUN rsync -aq --delete /assets-source/ /assets/

ARG UPSTREAM_VERSION
FROM ghcr.io/shutter-network/keyper:${UPSTREAM_VERSION}

ARG NETWORK
ARG KEYPER_CONFIG_DIR
ARG SHUTTER_CHAIN_DIR
ARG KEYPER_PORT
ARG CHAIN_PORT
ARG STAKER_SCRIPTS_VERSION

RUN apt-get update && \
    apt-get --yes --no-install-recommends install supervisor postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV SHUTTER_GNOSIS_SM_BLOCKTIME=10 \
    SHUTTER_GNOSIS_GENESIS_KEYPER=0x440Dc6F164e9241F04d282215ceF2780cd0B755e \
    SHUTTER_GNOSIS_MAXTXPOINTERAGE=5 \
    SHUTTER_DATABASEURL=postgres://postgres@db.shutter-${NETWORK}.dappnode:5432/keyper \
    SHUTTER_SHUTTERMINT_SHUTTERMINTURL=http://localhost:26657 \
    CHAIN_LISTEN_PORT=26657 \
    SHUTTER_BIN=/rolling-shutter \
    SHUTTER_ENV_FILE=/shutter.env \
    KEYPER_GENERATED_CONFIG_FILE=${KEYPER_CONFIG_DIR}/generated.toml \
    KEYPER_CONFIG_FILE=${KEYPER_CONFIG_DIR}/keyper.toml \
    SHUTTER_CHAIN_DIR=${SHUTTER_CHAIN_DIR} \
    KEYPER_PORT=${KEYPER_PORT} \
    SHUTTER_CHAIN_CONFIG_FILE=${SHUTTER_CHAIN_DIR}/config/config.toml \
    ASSETS_DIR=/assets \
    SHUTTER_SETTINGS_SRC_DIR=/usr/src/go-shutter-settings \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/dvt_lsd_tools.sh /etc/profile.d/

COPY go-shutter-settings ${SHUTTER_SETTINGS_SRC_DIR}
COPY supervisord.conf /etc/supervisord.conf
COPY promtail_config.yaml /etc/promtail_config.yaml

RUN go build -C ${SHUTTER_SETTINGS_SRC_DIR} -o /usr/local/bin/go_shutter_settings

RUN mkdir -p ${KEYPER_CONFIG_DIR} ${SHUTTER_CHAIN_DIR} ${ASSETS_DIR} /opt/supervisor && \
    chmod +rx /etc/profile.d/dvt_lsd_tools.sh

COPY scripts /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh
COPY --from=assets ${ASSETS_DIR}/ ${ASSETS_DIR}/

# For pushing logs to loki
RUN apt-get -y install wget gpg
RUN mkdir -p /etc/apt/keyrings/
RUN wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
# promtail & rotatelogs (from apache2)
RUN apt-get update && apt-get -y install promtail apache2

RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl

ARG NODE_VERSION=22.14.0
ARG NODE_PACKAGE=node-v$NODE_VERSION-linux-x64
ARG NODE_HOME=/opt/$NODE_PACKAGE

ENV NODE_PATH $NODE_HOME/lib/node_modules
ENV PATH $NODE_HOME/bin:$PATH

RUN curl https://nodejs.org/dist/v$NODE_VERSION/$NODE_PACKAGE.tar.gz | tar -xzC /opt/

RUN npm install -g wscat

# Placed here to rebuild less layers
ENV CHAIN_PORT=${CHAIN_PORT} \
    SHUTTER_P2P_LISTENADDRESSES="/ip4/0.0.0.0/tcp/${KEYPER_PORT},/ip4/0.0.0.0/udp/${KEYPER_PORT}/quic-v1" \
    NETWORK=${NETWORK}

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]