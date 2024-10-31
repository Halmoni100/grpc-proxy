PWD = $(shell pwd)

DEPS_DIR = $(PWD)/third_party
PROTOC= $(DEPS_DIR)/install/bin/protoc
GRPC_CPP_PLUGIN = $(DEPS_DIR)/install/bin/grpc_cpp_plugin

SERVER_DIR = $(PWD)/server
SERVER_BINARY = $(SERVER_DIR)/install/bin/server
SERVER_PROTOS = $(SERVER_DIR)/protos/chat.grpc.pb.cc $(SERVER_DIR)/protos/chat.grpc.pb.h $(SERVER_DIR)/protos/chat.pb.cc $(SERVER_DIR)/protos/chat.pb.h

SWIFT_DEPS_BUILD_DIR = $(DEPS_DIR)/swift_build
PROTOC_GEN_SWIFT = $(SWIFT_DEPS_BUILD_DIR)/debug/protoc-gen-swift
PROTOC_GEN_GRPC_SWIFT = $(SWIFT_DEPS_BUILD_DIR)/debug/protoc-gen-grpc-swift

CLIENT_PROTOS_DIR = $(PWD)/client/ChatClient/protos
SWIFT_PROTOS = $(CLIENT_PROTOS_DIR)/chat.grpc.swift $(CLIENT_PROTOS_DIR)/chat.pb.swift 

SUBMODULE_UPDATE_FILES = $(DEPS_DIR)/repos/grpc/CMakeLists.txt $(DEPS_DIR)/repos/grpc-swift/Package.swift $(DEPS_DIR)/repos/swift-protobuf/Package.swift

.PHONY: run_server clean_all clean_server clean_server_deps clean_swift_grpc_deps

default: all

all: $(SWIFT_PROTOS) $(SERVER_BINARY)

$(SWIFT_PROTOS): $(PROTOC_GEN_SWIFT) $(PROTOC_GEN_GRPC_SWIFT) $(PROTOC)
	$(PROTOC) chat.proto --proto_path=$(SERVER_DIR)/protos --swift_opt=Visibility=Public --swift_out=$(CLIENT_PROTOS_DIR) --grpc-swift_opt=Visibility=Public,Client=true,Server=false --grpc-swift_out=$(CLIENT_PROTOS_DIR) --plugin=protoc-gen-swift=$(PROTOC_GEN_SWIFT) --plugin=protoc-gen-grpc-swift=$(PROTOC_GEN_GRPC_SWIFT)

run: $(SERVER_BINARY)
	server/install/bin/server

$(PROTOC_GEN_SWIFT): $(SUBMODULE_UPDATE_FILES)
	mkdir -p $(SWIFT_DEPS_BUILD_DIR)
	cd $(DEPS_DIR)/repos/swift-protobuf && swift build --build-path $(SWIFT_DEPS_BUILD_DIR)
$(PROTOC_GEN_GRPC_SWIFT): $(SUBMODULE_UPDATE_FILES)
	mkdir -p $(SWIFT_DEPS_BUILD_DIR)
	cd $(DEPS_DIR)/repos/grpc-swift && swift build --build-path $(SWIFT_DEPS_BUILD_DIR)


$(SERVER_BINARY): $(SERVER_PROTOS) $(PROTOC) $(GRPC_CPP_PLUGIN) $(SERVER_DIR)/src/main.cpp
	mkdir -p $(SERVER_DIR)/build
	mkdir -p $(SERVER_DIR)/install
	cd $(SERVER_DIR)/build && cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(SERVER_DIR)/install $(SERVER_DIR) && ninja && ninja install

$(SERVER_PROTOS): $(PROTOC) $(GRPC_CPP_PLUGIN)
	$(PROTOC) -I $(SERVER_DIR)/protos --proto_path=$(SERVER_DIR)/protos --cpp_out=$(SERVER_DIR)/protos --grpc_out=$(SERVER_DIR)/protos --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN) chat.proto

$(PROTOC) $(GRPC_CPP_PLUGIN): $(SUBMODULE_UPDATE_FILES)
	mkdir -p $(DEPS_DIR)/build
	mkdir -p $(DEPS_DIR)/install
	cd $(DEPS_DIR)/build && cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=20 -DCMAKE_INSTALL_PREFIX=$(DEPS_DIR)/install $(DEPS_DIR)/repos/grpc && ninja && ninja install

$(SUBMODULE_UPDATE_FILES):
	git submodule update --init --recursive

clean_all: clean_server clean_server_deps clean_swift_grpc_deps

clean_server:
	rm -rf $(SERVER_DIR)/build
	rm -rf $(SERVER_DIR)/install

clean_server_protos:
	rm -f $(SERVER_DIR)/protos/*.pb.cc
	rm -f $(SERVER_DIR)/protos/*.pb.h

clean_server_deps:
	rm -rf $(DEPS_DIR)/build
	rm -rf $(DEPS_DIR)/install

clean_swift_grpc_deps:
	rm -rf $(SWIFT_DEPS_BUILD_DIR)

