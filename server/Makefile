MAKEFILE_DIR = $(shell pwd)

all: build install

build:
	# build grpc
	git submodule update --init --recursive
	cd third_party && mkdir -p build_grpc
	cd third_party/build_grpc && cmake -G Ninja ../grpc -DCMAKE_CXX_STANDARD=20 -DCMAKE_INSTALL_PREFIX=$(MAKEFILE_DIR)/install && ninja && ninja install
	# build server
	cd protos && make clean && make
	
install:
	cd build && ninja install

run:
	install/bin/server

clean:
	rm -rf build
	rm -rf install/bin/server
	rm -rf third_party/build_grpc
