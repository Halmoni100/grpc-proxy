PROTOC=../../../../server/install/bin/protoc

build:
	$(PROTOC) chat.proto --proto_path=. --swift_opt=Visibility=Public --swift_out=. --grpc-swift_opt=Visibility=Public,Client=true,Server=false --grpc-swift_out=.

