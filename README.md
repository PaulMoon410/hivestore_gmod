# Hive Store - PeakeCoin Integration

A com### Admin Commands
- `!storeadmin` - Open admin panel
- `!additem <n> <price> <category>` - Add new store item
- `!removeitem <n>` - Remove store item
- `!setprice <item> <price>` - Update item price
- `!givepek <player> <amount>` - Give PeakeCoin to player

### NPC Commands (Console)
- `hivestore_spawn_elder` - Spawn Elder Brother (Jeb McCoy)
- `hivestore_spawn_younger` - Spawn Younger Brother (Cletus McCoy)
- `hivestore_spawn_both` - Spawn Both Brothers
- `hivestore_remove_npcs` - Remove All NPCssive store system for Garry's Mod that integrates with the Hive blockchain and uses PeakeCoin as the primary currency.

## Features

- **PeakeCoin Integration**: Use PEK tokens for all transactions
- **Hive Blockchain**: Secure transactions on the Hive network
- **Item Store**: Buy and sell weapons, tools, and cosmetics
- **User Wallets**: Track PeakeCoin balances
- **Admin Panel**: Manage store items and prices
- **Transaction History**: View all purchases and sales
- **Hillbilly Shopkeeper NPCs**: Interactive McCoy Brothers who run the trading post
  - **Jeb McCoy (Elder Brother)**: Main shopkeeper with access to all items
  - **Cletus McCoy (Younger Brother)**: Weapons & tools specialist

## Installation

1. Copy the HiveStore folder to your Garry's Mod addons directory
2. Restart your server or use the console command: `lua_run_cl dofile("addons/HiveStore/lua/autorun/hive_store_init.lua")`

## Usage

- Press F4 to open the Hive Store
- Use !wallet to check your PeakeCoin balance
- Use !store to open the store interface
- Admins can use !storeadmin to manage the store

## Configuration

Edit `lua/hive_store/config.lua` to customize:
- Store items and prices
- PeakeCoin exchange rates
- Admin permissions
- Store appearance

## Commands

### Player Commands
- `!store` - Open the store
- `!wallet` - Check PeakeCoin balance
- `!balance` - Same as !wallet
- `!buy <item>` - Quick buy an item
- `!sell <item>` - Quick sell an item

### Admin Commands
- `!storeadmin` - Open admin panel
- `!additem <name> <price> <category>` - Add new store item
- `!removeitem <name>` - Remove store item
- `!setprice <item> <price>` - Update item price
- `!givepek <player> <amount>` - Give PeakeCoin to player
