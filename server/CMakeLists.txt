cmake_minimum_required(VERSION 3.24)

project(chat-server)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/install)
set(CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR}/install)

find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

set(chat_proto_srcs
    "protos/chat.pb.h"
    "protos/chat.pb.cc")
set(chat_grpc_srcs
    "protos/chat.grpc.pb.h"
    "protos/chat.grpc.pb.cc")
add_library(chat_grpc
    ${chat_proto_srcs}
    ${chat_grpc_srcs})
target_link_libraries(chat_grpc
    gRPC::grpc++_reflection
    gRPC::grpc++
    protobuf::libprotobuf)

add_executable(server
    src/main.cpp)
target_include_directories(server PRIVATE
    protos)
target_link_libraries(server
    chat_grpc)

