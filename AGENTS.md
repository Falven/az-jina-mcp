# az-jina-mcp Agent Notes

## Scope

- This file applies to `apps/az-jina-mcp/**`.
- Runtime scripts and dependencies source of truth: `apps/az-jina-mcp/package.json`.

## Dev / Runtime Commands

- From `apps/az-jina-mcp`: `pnpm run dev --local --ip 0.0.0.0 --port 8080`
- From `apps/az-jina-mcp`: `pnpm exec wrangler dev --local --ip 0.0.0.0 --port 8080`

## Startup Gotchas

- If command output shows `wrangler dev -- --local --ip 0.0.0.0 --port 8080`, wrangler may bind default `8787` instead of `8080`.
- Avoid passing an extra literal `--` after `pnpm run dev` for this package.
- For ACA deployments, ensure wrangler binds `0.0.0.0:8080` so health probes on container port `8080` succeed.
- `pnpm run start:aca` requires `MCP_SEARCH_BASE`, `MCP_READER_BASE`, and `API_BASE_URL`.
  - The script uses shell `${VAR:? ... is required}` expansion and exits immediately if any are missing.

## Dockerfile Layout Note

- Keep runtime path aligned with pnpm workspace symlinks:
  - Use `WORKDIR /workspace/apps/az-jina-mcp`.
  - Preserve both `/workspace/node_modules` and app-local `node_modules` in runtime image.
