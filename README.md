# Dynamic Ability Creation System (DACS)

Vertical slice: conversational Gemini ability creation → deterministic validation → server-authored gameplay + visuals.

This is **not** a full MMO. It proves the loop:

player idea → AI conversation → ability concept → generated rules → validation → player confirm → created ability → visuals → experiment → versioned data that can evolve later.

## File structure

```
Rojovideo/
  default.project.json
  aftman.toml
  src/
    shared/DACS/          schema, primitives, sanitize, remotes, visual budget
    server/DACS/          authority: AI bridge, validator, loopholes, dry-run,
                          executor, registry/kill switch, persistence, tests
    client/DACS/          chat UI, HUD, pooled visuals, input
  proxy/                  Gemini API (key never lives in Roblox)
    server.js
    prompts/
    .env.example
```

## Setup

1. Install [Aftman](https://github.com/LPGhatguy/aftman) / Rojo `7.7.0-rc.1` (see `aftman.toml`).
2. Get a [Gemini API key](https://aistudio.google.com/apikey).
3. Proxy:

```
cd proxy
copy .env.example .env
# put GEMINI_API_KEY in .env
# DACS_SECRET must match src/shared/DACS/Constants.luau SHARED_SECRET
npm install
npm start
```

4. In Roblox Studio: **Game Settings → Security → Allow HTTP Requests**.
5. Serve the place:

```
rojo serve
```

Connect the Rojo plugin to `localhost:34872`, then Play.

6. If Studio cannot reach `127.0.0.1:3000`, run the proxy on the same machine and keep `Constants.PROXY_URL` as `http://127.0.0.1:3000`.

## Environment

| Variable | Where | Purpose |
|---|---|---|
| `GEMINI_API_KEY` | `proxy/.env` | Google Gemini |
| `GEMINI_MODEL` | `proxy/.env` | default `gemini-3.6-flash` |
| `DACS_SECRET` | `proxy/.env` + `Constants.SHARED_SECRET` | shared header `X-DACS-Secret` |
| `PORT` | `proxy/.env` | default 3000 |

The Roblox server never holds the Gemini key. It only talks to the local proxy.

## Playtest

- **N** toggles the creator.
- Type a fantasy (example: *I want to control my heart rate...*).
- Confirm **This is mine** when the summary appears (no power scores, no tiers).
- **F** uses/toggles the ability. **Q** shifts states.
- A red dummy in front of spawn is tagged `DACS_NPC` for influence tests.
- If generation fails after retries, rephrase or take the placeholder **Steady Breath**.

## Testing

On Studio Play, the server prints `[DACS TEST PASS/FAIL]` for 24 cases (no Gemini). Watch the Output window.

## Architecture (short)

- **AI** returns JSON only. Never Luau.
- **Reject before create.** Failed schema / loophole / dry-run never binds.
- **Retries:** up to 3; then player rephrase or placeholder.
- **Primitives clamp again** in `MechanicExecutor` (NaN/Inf/max).
- **Registry kill switch:** `AbilityPersistence.disableAbility(id, reason)`.
- **Telemetry** suspends outliers that exceed category max.

See the in-chat handoff for schema, security, limitations, and next stage.

## Known limitations

Studio unpublished places use an in-memory mock DataStore. Publish the place for real persistence. Visuals are a controlled primitive set, not arbitrary meshes. Multiplayer counterplay is prototyped, not a full PvP ruleset.
