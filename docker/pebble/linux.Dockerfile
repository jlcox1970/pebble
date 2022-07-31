FROM --platform=$TARGETPLATFORM golang:alpine AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

FROM --platform=$TARGETPLATFORM golang:1.12-alpine as builder
RUN apk --update upgrade \
&& apk --no-cache --no-progress add git bash curl \
&& rm -rf /var/cache/apk/*
ENV CGO_ENABLED=0 GOFLAGS=-mod=vendor

WORKDIR /pebble-src
COPY . .

RUN GOOS=linux GOARCH=$TARGETPLATFORM go install -v ./cmd/pebble/...

FROM --platform=$TARGETPLATFORM alpine:3.8

RUN apk update && apk add --no-cache --virtual ca-certificates

COPY --from=builder /go/bin/pebble /usr/bin/pebble
COPY --from=builder /pebble-src/test/ /test
CMD [ "/usr/bin/pebble" ]

EXPOSE 14000
EXPOSE 15000
