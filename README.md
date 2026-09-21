# Worst Delivery Ever

Fast-build Roblox physics game.

## Core loop
ORDER -> LOAD -> DRIVE -> SURVIVE -> DELIVER -> GET PAID -> UPGRADE -> REPEAT

## Development rule
Build the gray-box gameplay loop first. No art polish, monetization, pets, rebirths, trading, crafting, or complex cargo placement until the core run is fun.

## Rojo
- src/server -> ServerScriptService
- src/shared -> ReplicatedStorage
- src/client -> StarterPlayerScripts
- src/gui -> StarterGui

The local proxy setup is preserved separately. Its node_modules and .env are intentionally ignored by Git.
