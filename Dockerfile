FROM golang:1.14-alpine AS build
LABEL maintainer="angeliski@hotmail.com"

ENV APP_DIR /opt/urano

COPY . ${APP_DIR}
WORKDIR ${APP_DIR}

RUN apk add build-base git

ARG GITHUB_TOKEN

RUN git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf https://github.com/

RUN go mod download

# Remove debug and disable cross compile to create a small binary
ARG GOOS=linux
ARG GOARCH=amd64
RUN go build -ldflags="-w -s" -o /app/urano *.go

FROM alpine:3.11
COPY --from=build /app/urano /app/urano

# Use an unprivileged user
RUN adduser -D -g '' app
USER app

ENTRYPOINT ["/app/urano"]