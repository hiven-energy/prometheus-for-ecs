FROM golang:1.15 AS builder

WORKDIR /src
COPY . .

RUN go env -w GOPROXY=direct
RUN go mod download
RUN go mod tidy
RUN go mod vendor

ARG TARGETOS
ARG TARGETARCH

RUN CGO_ENABLED=0 GO111MODULE=on GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -a -mod=vendor -tags=netgo -o config-reloader cmd/main.go 

FROM alpine:latest AS final

WORKDIR /home/prometheus-for-ecs
COPY --from=builder /src/config-reloader .
ENV GO111MODULE=on
ENTRYPOINT ["./config-reloader"]