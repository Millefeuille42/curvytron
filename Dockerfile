FROM buildpack-deps:stable-curl AS node

ENV NODE_VERSION=0.12.18 \
    NPM_VERSION=2.15.11 \
    NODE_DIST_URL="https://nodejs.org/dist"

RUN curl -SLO "$NODE_DIST_URL/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz"
RUN npm install -g npm@"$NPM_VERSION" \
    && npm cache clean --force

### --- ###

FROM python:2.7-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/bin/ /usr/local/bin/

COPY . /curvytron
WORKDIR /curvytron

RUN npm install \
    && npm run install \
    && npm run build \
    && npm cache clean --force

FROM debian:stable-slim

COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/bin/ /usr/local/bin/

COPY --from=build /curvytron/web /curvytron/web
COPY --from=build /curvytron/bin /curvytron/bin
COPY --from=build /curvytron/node_modules /curvytron/node_modules
COPY --from=build /curvytron/package.json /curvytron/package.json
COPY --from=build /curvytron/config.json.sample /curvytron/config.json.sample

WORKDIR /curvytron
RUN useradd -M -s /usr/sbin/nologin curvytron \
    && chown curvytron:curvytron /curvytron

USER curvytron
COPY --chown=curvytron --chmod=0600 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
