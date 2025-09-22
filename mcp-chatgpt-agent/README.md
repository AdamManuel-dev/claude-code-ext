# MCP ChatGPT Agent

An MCP (Model Context Protocol) server that invokes ChatGPT as a sub-agent using the `codex` command with dangerous bypasses enabled.

## Features

- **ChatGPT Integration**: Invoke ChatGPT through the codex CLI tool
- **Dangerous Bypasses**: Uses `--dangerously-bypass-approvals-and-sandbox` flag
- **Timeout Management**: Configurable timeout for ChatGPT invocations
- **Error Handling**: Comprehensive error handling and validation
- **Security Validation**: Input sanitization and forbidden pattern detection

## Prerequisites

- Node.js 18+
- `codex` CLI tool installed and accessible in PATH
- TypeScript (for development)

## Installation

1. Clone or copy this directory
2. Install dependencies:
```bash
npm install
```

3. Build the project:
```bash
npm run build
```

## Usage

### Starting the MCP Server

```bash
npm start
```

The server will run on stdio and can be connected to by any MCP client.

### Available Tools

#### `invoke-chatgpt`

Invokes ChatGPT as a sub-agent using the codex command.

**Parameters:**
- `prompt` (required): The prompt to send to ChatGPT
- `timeout` (optional): Timeout in milliseconds (default: 30000)

**Example:**
```json
{
  "name": "invoke-chatgpt",
  "arguments": {
    "prompt": "Explain quantum computing in simple terms",
    "timeout": 45000
  }
}
```

## Configuration

### Validation Options

The server includes built-in validation to prevent potentially dangerous commands:

- **Max Prompt Length**: 10,000 characters (configurable)
- **Forbidden Patterns**:
  - `rm -rf` commands
  - `sudo` commands
  - Output redirection to `/dev/null`

### Environment Variables

Currently no environment variables are required, but you can extend the server to support:

- `CODEX_PATH`: Custom path to codex executable
- `MAX_TIMEOUT`: Maximum allowed timeout value
- `LOG_LEVEL`: Logging verbosity

## Security Considerations

⚠️ **Warning**: This MCP server uses the `--dangerously-bypass-approvals-and-sandbox` flag, which disables safety mechanisms in the codex tool. Use with extreme caution and only in trusted environments.

### Security Features

1. **Input Validation**: Prompts are validated for length and forbidden patterns
2. **Process Isolation**: Each ChatGPT invocation runs in a separate process
3. **Timeout Protection**: Prevents runaway processes with configurable timeouts
4. **Error Containment**: Errors are caught and properly reported without crashing the server

### Recommended Practices

- Run in isolated environments only
- Monitor all ChatGPT invocations and outputs
- Implement additional access controls as needed
- Regular security audits of prompts and responses

## Development

### Building

```bash
npm run build
```

### Development Mode

```bash
npm run dev
```

### Project Structure

```
src/
├── index.ts          # Main MCP server implementation
├── validation.ts     # Input validation and security utilities
```

## Error Handling

The server provides detailed error messages for common issues:

- **Command Not Found**: When `codex` is not installed or not in PATH
- **Timeout Errors**: When ChatGPT takes too long to respond
- **Validation Errors**: When prompts fail security validation
- **Process Errors**: When the codex command fails to execute

## Example Integration

### With Claude Code

Add to your MCP configuration:

```json
{
  "mcpServers": {
    "chatgpt-agent": {
      "command": "node",
      "args": ["/path/to/mcp-chatgpt-agent/dist/index.js"]
    }
  }
}
```

### Programmatic Usage

```typescript
import { Client } from '@modelcontextprotocol/sdk/client/index.js';

const client = new Client({
  name: "chatgpt-client",
  version: "1.0.0"
});

// Connect to the MCP server
await client.connect(transport);

// Invoke ChatGPT
const result = await client.request({
  method: "tools/call",
  params: {
    name: "invoke-chatgpt",
    arguments: {
      prompt: "What is the capital of France?",
      timeout: 30000
    }
  }
});

console.log(result.content[0].text);
```

## Troubleshooting

### Common Issues

1. **"codex command not found"**
   - Ensure codex CLI is installed and in your PATH
   - Try running `which codex` or `codex --version` manually

2. **Permission denied errors**
   - Check file permissions on the codex executable
   - Ensure the user has permission to execute system commands

3. **Timeout errors**
   - Increase the timeout value for complex prompts
   - Check network connectivity if codex requires internet access

4. **Validation errors**
   - Review prompt content for forbidden patterns
   - Reduce prompt length if it exceeds limits

### Debugging

Enable detailed logging by modifying the server code or setting log levels:

```typescript
console.error('Debug info:', { prompt, timeout, args });
```

## License

MIT License - See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## Changelog

### v1.0.0
- Initial release
- Basic ChatGPT invocation via codex
- Input validation and security checks
- Comprehensive error handling