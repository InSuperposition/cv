# syntax=docker/dockerfile:1

ARG NODE_VERSION=24
ARG DEBIAN_RELEASE=trixie

FROM public.ecr.aws/docker/library/node:${NODE_VERSION}-${DEBIAN_RELEASE}-slim@sha256:173f125896c3b47ddf056734c7ea789d04595a6a08769a8f78e0df642781fb66 AS deps
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
