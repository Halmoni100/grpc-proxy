MAKEFILE_DIR = $(shell pwd)

default: build

build:
	git submodule update --init
	mkdir -p third_party/build
	# build protoc-gen-swift
	cd third_party/swift-protobuf && swift build --build-path ../build
	# build protoc-gen-grpc-swift
	cd third_party/grpc-swift && swift build --build-path ../build

clean:
	rm -rf third_party/build
