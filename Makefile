APP=$(shell basename $(shell git remote get-url origin))
REGESTRY := ghcr.io/Kbot
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
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

get:
	go get 

linux:
	GOOS=linux GOARCH=amd64 go build -v -o kbot -ldflags "-X=github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}"

arm:
	GOOS=linux GOARCH=arm64 go build -v -o kbot -ldflags "-X=github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}"

macos:
	GOOS=darwin GOARCH=amd64 go build -v -o kbot -ldflags "-X=github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}"


windows:
	GOOS=windows GOARCH=amd64 go build -v -o kbot -ldflags "-X=github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}"