FROM golang:1.24.1 AS builder

WORKDIR /srv
COPY ./srv/ ./

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o wireguard-client ./cmd/main.go

#####################################################################################

FROM debian:unstable-slim

RUN apt update && \
    apt install -y wireguard-tools \
    iputils-ping && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/wireguard

WORKDIR /root/

COPY --from=builder /srv/wireguard-client .
COPY setup.sh /root/setup.sh

RUN chmod +x /root/setup.sh

CMD ["/root/setup.sh"]