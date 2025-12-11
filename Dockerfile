# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=22.12.0

FROM node:${NODE_VERSION}-slim AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY tsconfig.json wrangler.jsonc worker-configuration.d.ts ./
COPY src ./src

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

FROM node:${NODE_VERSION}-slim AS runtime
ENV NODE_ENV=production \
    WRANGLER_SEND_METRICS=false \
    WRANGLER_TELEMETRY=false

WORKDIR /app
COPY --from=deps /app /app
COPY --from=deps /entrypoint.sh /entrypoint.sh

RUN chown -R node:node /app /entrypoint.sh

USER node
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD []
