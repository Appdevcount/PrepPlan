interface MCPRequest {
    params: {
        name: string;
        arguments?: any;
    };
}
interface MCPResponse {
    content: Array<{
        type: string;
        text: string;
    }>;
    isError?: boolean;
}
declare const listTools: () => Promise<any>;
declare const handleToolCall: (request: MCPRequest) => Promise<MCPResponse>;
export { handleToolCall, listTools };
//# sourceMappingURL=index.d.ts.map