# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /workspace
RUN corepack enable

FROM base AS deps
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY apps/az-jina-mcp/package.json ./apps/az-jina-mcp/package.json
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm install --filter ./apps/az-jina-mcp... --frozen-lockfile

FROM base AS runtime
WORKDIR /workspace/apps/az-jina-mcp

RUN useradd -r -u 10001 -m appuser
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
ENV PORT=8080

# Preserve pnpm workspace node_modules layout so package-local .bin symlinks
# (for example wrangler) resolve correctly at runtime.
COPY --from=deps /workspace/node_modules /workspace/node_modules
COPY --from=deps /workspace/apps/az-jina-mcp/node_modules ./node_modules
COPY apps/az-jina-mcp/package.json ./package.json
COPY apps/az-jina-mcp/tsconfig.json ./tsconfig.json
COPY apps/az-jina-mcp/wrangler.jsonc ./wrangler.jsonc
COPY apps/az-jina-mcp/worker-configuration.d.ts ./worker-configuration.d.ts
COPY apps/az-jina-mcp/src ./src
RUN chown -R appuser:appuser /workspace

USER appuser
EXPOSE 8080
STOPSIGNAL SIGTERM

CMD ["pnpm", "run", "start:aca"]
