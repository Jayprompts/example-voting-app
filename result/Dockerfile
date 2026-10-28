# pinned to an exact version and digest (Node 24 LTS; Node 18 is end-of-life)
FROM node:24.22.1-slim@sha256:be8204d4bd327363357f532187b752ff62759c31bedf98e9e18fc08c9cbd605c

# add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

# npm is only needed to install packages, not to run the app; removing it drops its bundled CVEs
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
    /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

COPY . .

# Non-root users can't bind ports below 1024, so the app listens on 8080
ENV PORT=8080
EXPOSE 8080

# run as the image's built-in unprivileged "node" user (uid 1000)
USER 1000

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
