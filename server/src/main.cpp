#include <string>

#include <grpcpp/server.h>
#include <grpcpp/server_builder.h>

#include "chat.grpc.pb.h"

class ChatImpl final : public chat::Chat::Service
{
public:
    ChatImpl() {}

    grpc::Status 
};

int main()
{
    std::string server_address("0.0.0.0:50050");

    grpc::ServerBuilder builder;
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
}
