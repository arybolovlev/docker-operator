# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This Dockerfile contains multiple targets.
# Use 'docker build --target=<name> .' to build one.
#
# Every target has a BIN_NAME argument that must be provided via --build-arg=BIN_NAME=<name>
# when building.

ARG GO_VERSION=1.20

# ===================================
# 
#   Non-release images.
#
# ===================================


# dev-builder compiles the binary
# -----------------------------------
FROM golang:$GO_VERSION as dev-builder

ARG BIN_NAME
ARG TARGETOS
ARG TARGETARCH

WORKDIR /build

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/

RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -trimpath -o $BIN_NAME main.go

# dev runs the binary from devbuild
# -----------------------------------
FROM gcr.io/distroless/static:nonroot as dev

ARG BIN_NAME

WORKDIR /
COPY --from=builder /build/$BIN_NAME .
USER 65532:65532

ENTRYPOINT ["/$BIN_NAME"]

# ===================================
# 
#   Set default target to 'dev'.
#
# ===================================
FROM dev
