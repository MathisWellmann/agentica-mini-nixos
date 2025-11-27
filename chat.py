"""
Example output:

➜  ~/repos/situ/prototypes/simple-situ git:(charlie/simple-situ) ✗ uv run python -m chat
Send empty message to end the chat.
User: Hello!
Agent: Hello! I'm ready to assist you.
User: What is the time?
Agent: 2025-08-06 12:35:29
User: What is the 32nd power of 3?
Agent: 1853020188851841
User:
➜  ~/repos/situ/prototypes/simple-situ git:(charlie/simple-situ) ✗
"""

import asyncio

from agentica import AgentError, local_runtime, spawn

RED = "\033[91m"
GREEN = "\033[92m"
PURPLE = "\033[95m"
RESET = "\033[0m"
GREY = "\033[90m"

# Spawn a sub agent, and get it to work out the 32nd power of 3


async def chat():
    print("Send empty message to end the chat.")

    local_runtime.print_logs(False)

    agent = await spawn(scope={'spawn_agent': local_runtime.spawn_agent})

    while user_input := input(f"\n{PURPLE}User{RESET}: "):
        try:
            # Invoke agent against user prompt
            result, stream = agent.call_stream(str, user_input)

            # Stream intermediate "thinking" to console
            print(GREY)
            async for chunk in stream:
                print(chunk, end="", flush=True)
            print(RESET)

            # Print final result
            print(f"\n{GREEN}Agent{RESET}: {await result}")

        except AgentError as agent_error:
            print(f"\n{RED}AgentError: {agent_error.reason}{RESET}")

    print("\nExiting...")


if __name__ == "__main__":
    asyncio.run(chat())
