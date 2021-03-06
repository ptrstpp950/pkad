# STAGE 1: Build
FROM golang:1.12-alpine AS build

# Install Node and NPM.
RUN apk update && apk upgrade && apk add --no-cache git nodejs bash npm

# Get dependencies for Go part of build
RUN go get -u github.com/jteeuwen/go-bindata/...

WORKDIR /go/src/github.com/PoznajKubernetes/pkad/client
# install npm dependencies
COPY client/package.json .
RUN npm install
WORKDIR /go/src/github.com/PoznajKubernetes/pkad

# download go modules
COPY go.sum .
COPY go.mod .
ENV GO111MODULE=on
RUN go mod download

# Copy all sources in
COPY . .

# This is a set of variables that the build script expects
ARG VERSION_NAME=test
ENV VERBOSE=0
ENV PKG=github.com/PoznajKubernetes/pkad
ENV ARCH=amd64
ENV VERSION=${VERSION_NAME}


# Do the build. Script is part of incoming sources.
RUN chmod +x build/build-with-cache.sh && build/build-with-cache.sh

# STAGE 2: Runtime
FROM alpine

USER nobody:nobody
COPY --from=build /go/bin/pkad /pkad

CMD [ "/pkad" ]
