MAKEFILE_DIR = $(shell pwd)

default: all

all: build install

build: build/server
	# build grpc
	git submodule update --init --recursive
	cd third_party && mkdir -p build_grpc
	cd third_party/build_grpc && cmake -G Ninja ../grpc -DCMAKE_CXX_STANDARD=20 -DCMAKE_INSTALL_PREFIX=$(MAKEFILE_DIR)/install && ninja && ninja install
	# build server
	cd protos && make clean && make
	
install: install/bin/server
	cd build && ninja install

run: install
	install/bin/server

clean:
	rm -rf build
	rm -rf install/bin/server

clean_third_party:
	rm -rf install
	rm -rf third_party/build_grpc
