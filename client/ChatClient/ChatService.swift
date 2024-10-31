//
//  ChatService.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import GRPC
import Logging

import Foundation

typealias Request = Chat_ChatRequest
typealias Response = Chat_ChatResponse

class ChatService {
    static let shared = ChatService()
    
    enum State {
        case idle
        case streaming(BidirectionalStreamingCall<Request, Response>)
    }
    
    private let logger: Logging.Logger
    
    private var mutex = DispatchSemaphore(value: 1)
    private var state: State = .idle
    private var client: Chat_ChatNIOClient
    
    private init() {
        logger = Logger(label: "ChatService")
        
        var nioLogger = Logger(label: "io.grpc", factory: StreamLogHandler.standardOutput(label:))
        nioLogger.logLevel = .trace
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1, logger: nioLogger)
        
        var grpcLogger = Logger(label: "gRPC", factory: StreamLogHandler.standardOutput(label:))
        grpcLogger.logLevel = .trace
        
        let channel = ClientConnection
            .insecure(group: group)
            .connect(host: "localhost", port: 50051)
        let callOptions = CallOptions(logger: grpcLogger)
        
        self.client = Chat_ChatNIOClient(channel: channel, defaultCallOptions: callOptions)
    }
    
    func startChatStream(completion: ((Response) -> Void)? = nil) {
        mutex.wait()
        
        switch self.state {
        case .idle:
            logger.info("Start streaming")
            let call = self.client.chat { response in
                completion?(response)
            }
            self.state = .streaming(call)
        default: break
        }
        
        mutex.signal()
    }
    
    func streamChatMsg(_ msg: String) {
        mutex.wait()
        
        switch self.state {
        case let .streaming(call):
            var request = Chat_ChatRequest()
            request.msg = msg
            call.sendMessage(request, promise: nil)
        default: break
        }
        
        mutex.signal()
    }
    
    func stopChatStream() {
        mutex.wait()
        
        switch self.state {
        case let .streaming(stream):
            logger.info("stop streaming")
            stream.sendEnd(promise: nil)
            self.state = .idle
        default: break
        }
        
        mutex.signal()
    }
}
