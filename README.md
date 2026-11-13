# Pass Keys Safely

Get API keys and passwords to your AI agents without them ever sitting in a chat.

## What it does
- Stops a key from being pasted into a chat, and replaces the ones already sitting in old chats, tickets and docs.
- Moves each key through a Bitwarden Send link that opens once, then dies.
- Writes the key where your app reads it, and the agent only sees "placed".

## Install
Copy `skills/pass-keys-safely` into `~/.claude/skills/` or your project's `.claude/skills/`. Install the Bitwarden CLI (https://bitwarden.com/help/cli/).

## Run
In Claude Code, say "I need to give you a key" or "help me clean up keys in our chats".

## Good to know
The Send link stays in the agent's chat history, and for a moment it shows in the script's command line, which other users on a shared machine can see. That's fine: it opens once, so after the script uses it, the link is dead. If anyone opened it first, the script says `link already used or not found`, and you cancel that key with the vendor.

## Why we built it
We run our business on a large team of AI agents. Keys pasted in chats were one of our worst habits, and this is the path we use now.

## Running AI agents of your own?
Start your free evaluation at https://bluhook.com/eval and get the top 3 jobs AI can take off your team.

## License
MIT
