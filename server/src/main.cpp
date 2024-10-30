#include <string>

#include <grpcpp/server.h>
#include <grpcpp/server_builder.h>

#include "chat.grpc.pb.h"

class ChatImpl final : public chat::Chat::Service
{
public:
    ChatImpl() {}

    grpc::Status Heartbeat(grpc::ServerContext* context,
            const chat::HeartbeatRequest* request,
            chat::HeartbeatResponse* response) override
    {
        response->set_success(true);
        return grpc::Status::OK;
    }

    grpc::Status Chat(grpc::ServerContext* context,
            grpc::ServerReaderWriter<chat::ChatResponse, chat::ChatRequest>* stream) override
    {
        std::vector<std::string> expectedMessages = {"one", "two", "three"};

        for (const auto& expectedMsg : expectedMessages) {
            bool receivedValidRequest = process(expectedMsg, stream);
            if (!receivedValidRequest) {
                return grpc::Status::CANCELLED;
            }
        }

        return grpc::Status::OK;
    }

private:
    bool process(std::string expectedMsg, grpc::ServerReaderWriter<chat::ChatResponse, chat::ChatRequest>* stream) {
        chat::ChatResponse response;
        chat::ChatRequest request;
        stream->Read(&request);
        if (request.msg() == expectedMsg) {
            response.set_msg(expectedMsg + "_ack");
            stream->Write(response);
            return true;
        } else {
            return false;
        }
    }
};

int main()
{
    std::string server_address("0.0.0.0:50050");

    ChatImpl service;
    grpc::ServerBuilder builder;
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);
    auto server = builder.BuildAndStart();
    std::cout << "Server listening on " << server_address << std::endl;
    server->Wait();
}
