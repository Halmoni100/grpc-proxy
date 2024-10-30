PROTOC = ../install/bin/protoc
GRPC_CPP_PLUGIN_PATH = ../install/bin/grpc_cpp_plugin

.PHONY: clean

all: chat.grpc.pb.cc chat.pb.cc

chat.grpc.pb.cc: chat.proto
	$(PROTOC) -I . --grpc_out=. --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

chat.pb.cc: chat.proto
	$(PROTOC) -I . --cpp_out=. $<

clean:
	rm -f *.pb.cc *.pb.h
