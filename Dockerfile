# syntax=docker/dockerfile:1

ARG NODE_VERSION=24
ARG DEBIAN_RELEASE=trixie

FROM node:${NODE_VERSION}-${DEBIAN_RELEASE}-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev --no-audit --no-fund

FROM gcr.io/distroless/nodejs${NODE_VERSION}-debian13:nonroot
WORKDIR /app

ENV NODE_ENV=production \
    PORT=44100

COPY --from=deps --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --chown=nonroot:nonroot package.json tsconfig.json server.ts ./
COPY --chown=nonroot:nonroot app ./app
COPY --chown=nonroot:nonroot public ./public

USER nonroot
EXPOSE 44100
STOPSIGNAL SIGTERM

CMD ["--import", "remix/node-tsx", "server.ts"]
