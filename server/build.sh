#!/bin/bash

git submodule update --init --recursive

rm -rf install
mkdir install

cd third_party
rm -rf build_grpc
mkdir build_grpc
cd build_grpc
cmake -G Ninja ../grpc -DCMAKE_CXX_STANDARD=20 -DCMAKE_INSTALL_PREFIX=~/Projects/swift/grpc-proxy/server/install
ninja
ninja install

cd ../../protos
make clean
make


