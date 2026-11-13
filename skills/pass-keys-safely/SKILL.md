---
name: pass-keys-safely
description: Get an API key or password to your AI agent without it ever sitting in a chat. Use when an agent needs a key, when someone is about to paste a key into a chat, or when you find keys in old chats, tickets or docs.
---

# Pass keys to AI agents safely

A key pasted into a chat, a ticket or a doc stays readable for good. This skill moves every key through a link that opens once, so the key is seen by one script, one time, and the path is gone.

## When this runs

- The agent needs a new API key, token or password.
- Someone starts to paste a key into the chat. Stop them before they send it.
- You find a key in a chat, a task comment or a shared doc.

## Rules the agent follows

1. Never ask for a key in the chat. Never read a key aloud, print it, or write it into a reply, a log or a commit.
2. Ask once, with the full list of what the key must do. One ask, not four.
3. The key travels one way: a Bitwarden Send link, set to 1 view and to delete after 1 day.
4. A script opens the link and writes the key where the app reads it. The agent only sees "placed".
5. If the link was already used when the script opens it, treat the key as exposed: cancel it with the vendor and ask for a new one.

## Steps for the person who holds the key

1. In Bitwarden, make a new text Send. Paste the key.
2. Set maximum access count to 1 and deletion to 1 day.
3. Copy the Send link. Post it in one private place only, with email and phone previews off for that chat.

## Steps for the agent

1. Run `place_key.sh <NAME> <send-link> <env-file>`, for example `place_key.sh STRIPE_KEY https://send.bitwarden.com/#/send/... .env`.
2. Read only its last line. It prints one of these:
   - `placed NAME`: done.
   - `link already used or not found`: treat the key as exposed, cancel it with the vendor, ask for a new one.
   - `could not open the link`: try once more.
   - exit 3, `key has spaces, quotes or line breaks`: the link is now used. Ask the person who holds the key to place it by hand, or to send a new link. Don't open the link yourself.
   - exit 2: a setup problem the message names (bad NAME, no Bitwarden CLI, the env file is a symlink, or it sits in a git repo and is not ignored). Fix it, then run again. The link was not opened.
3. Never open the link any other way.

## Clean up old keys

1. Search chats, tickets and shared docs with a scanner that hides what it finds, such as `gitleaks detect --redact`, so the agent never reads the keys it's hunting.
2. For each one: cancel it with the vendor, make a new one, send the new one by a Send link.
3. List what you replaced, with the vendor and date. Never list the key itself.
