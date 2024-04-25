APP=$(shell basename $(shell git remote get-url origin))
REGISTRY := ghcr.io/annahurtovenko
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64

define code_builder
	CGO_ENABLED=0 GOOS=$1 GOARCH=$2 go build -v -o kbot -ldflags "-X="github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}
endef

define image_builder
	docker build . --target $1 -t ${REGISTRY}/${APP}:${VERSION}-$1-$2 --build-arg os=$1 --build-arg arch=$2
endef

format:
	gofmt -s -w ./ 

lint:
	golint 

test:
	go test -v

get:
	go get


build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X=github.com/AnnaHurtovenko/kbot/cmd.appVersion=${VERSION}"


linux: format get
	$(call code_builder,linux,amd64)

linux_arm: format get
	$(call code_builder,linux,arm64)

macos: format get
	$(call code_builder,darwin,arm64)

windows: format get
	$(call code_builder,windows,amd64)


image:
	docker build . --target ${TARGETOS} -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

image_linux:
	$(call image_builder,linux,amd64)

image_linux_arm:
	$(call image_builder,linux_arm,arm64)

image_macos:
	@echo "Sorry, but there is no Docker image for MacOS :("

image_windows:
	$(call image_builder,windows,amd64)

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean_arm:
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-arm64