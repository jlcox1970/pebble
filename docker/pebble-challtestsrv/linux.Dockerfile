FROM golang:1.11-alpine as builder

RUN apk --update upgrade \
&& apk --no-cache --no-progress add git bash curl \
&& rm -rf /var/cache/apk/*

ENV CGO_ENABLED=0 GOFLAGS=-mod=vendor

WORKDIR /pebble-src
COPY . .

RUN go install -v ./cmd/pebble-challtestsrv/...

## main
FROM alpine:3.8

RUN apk update && apk add --no-cache --virtual ca-certificates

COPY --from=builder /go/bin/pebble-challtestsrv /usr/bin/pebble-challtestsrv

CMD [ "/usr/bin/pebble-challtestsrv" ]