APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=22annagurt11
VERSION=$(shell git describe --tags --abbrev=0 2>/dev/null || echo 'v0.0.0')-$(shell git rev-parse --short HEAD | sed 's/^-//')
TARGETOS=linux
TARGETARCH=arm64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X=github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}"

echo-version:
	echo ${VERSION}

image: echo-version
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot

get:
	go get 
