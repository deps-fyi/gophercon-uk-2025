# NOTE that you should be digest pinning!
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder
# these will get injected in by Docker
ARG TARGETOS TARGETARCH

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go install gitlab.com/tanna.dev/dependabot-graph@latest

FROM node:22.13

LABEL org.opencontainers.image.source https://github.com/deps-fyi/gophercon-uk-2025

WORKDIR /app

RUN npm i -g @jamietanna/renovate-graph

COPY --from=builder /go/bin/dependabot-graph /usr/local/bin/dependabot-graph

COPY ./scan.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/scan.sh"]
