FROM golang:1.17.8 AS builder

WORKDIR /build

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o iptables-server .

FROM alpine:3.19

WORKDIR /

COPY --from=builder /build/iptables-server /

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache curl tzdata iptables && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del tzdata && \
    chmod +x /clash/bin/* && \
    rm -rf /var/cache/*

ENTRYPOINT ["/iptables-server"]