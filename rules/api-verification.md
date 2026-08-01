# API Verification Protocol

**Mandatory rule for all AI instances working on cursor-chat project.**

## Rule: Never claim an API exists without verification

When answering questions about third-party APIs (Cursor Cloud Agents, Ollama, etc.):

### 1. Check existing code first
- Look at the actual HTTP client methods in `app/src/main/java/com/cursorchat/app/data/api/CursorAgentsClient.kt`
- Check if there are test files that verify behavior
- Check git log for when endpoints were added: `git log --oneline -10 -- <file_path>`

### 2. Check official documentation before making claims
- **Cursor API:** Search for official docs at https://docs.cursor.com or the Cursor GitHub repo
- **Ollama API:** Check http://localhost:11434 or https://ollama.ai/api
- **Any MCP server:** Check the MCP server's actual resource/tool definitions via `access_mcp_resource` and `use_mcp_tool`

### 3. If documentation is NOT found, ALWAYS prefix your response with:
```
[UNVERIFIED] I cannot find official documentation for this API. The following information is based on code analysis only and may be incorrect. Please verify against the official API docs before relying on it.
```

### 4. When writing code comments or skill files about APIs
- Mark unverified endpoints with: `// ⚠️ UNVERIFIED — endpoint not confirmed via official docs`
- In markdown skills, use the `⚠️ IMPORTANT VERIFICATION NOTE` section before any API-dependent code path

### 5. When in doubt, recommend manual verification
- "To confirm this works, you should test against your live Cursor account or check the official API docs at [URL]"
- Never claim permanent effects (data deletion, etc.) without verified evidence

## Examples of violations to avoid

❌ "The app calls `DELETE /v1/agents/{agentId}` which permanently removes the agent."
✅ "[UNVERIFIED] The code attempts `DELETE /v1/agents/{agentId}`, but this endpoint has not been confirmed via official Cursor API docs. Users should manually delete from Cursor's web/desktop app to be certain."

❌ "This frees transcript + artifacts on Cursor's server."
✅ "The code comment claims this 'frees transcript + artifacts,' but there is no verified documentation confirming this behavior."

## Committing this rule
This file is at `.cursor/rules/api-verification.md` and should be loaded by all AI instances before answering API-related questions.