-- Installation and Setup Instructions for Hive Store

## Quick Installation

1. Copy the entire `HiveStore` folder to your Garry's Mod `addons` directory:
   - For servers: `garrysmod/addons/`
   - For single-player: `Steam/steamapps/common/GarrysMod/garrysmod/addons/`

2. Restart your Garry's Mod server or game

3. The addon will automatically initialize and create necessary data directories

## Configuration

### Basic Setup
1. Edit `lua/hive_store/config.lua` to customize:
   - Store name and currency settings
   - PeakeCoin integration parameters
   - UI colors and appearance
   - Admin permissions

### PeakeCoin Integration
1. To connect real Hive accounts, players need to link their Steam accounts to Hive usernames
2. Edit the `sv_peakecoin.lua` file to implement real blockchain transactions
3. For testing, the addon uses simulated PeakeCoin transactions

### Adding Custom Items
1. Edit `lua/hive_store/shared/sh_items.lua`
2. Add new items to the `HiveStore.Items` table following the existing format
3. Restart the server to load new items

## Commands

### Player Commands
- `!store` or `F4` - Open the Hive Store
- `!wallet` or `!balance` - Check PeakeCoin balance
- `!buy <item_id>` - Quick purchase an item
- `!sell <item_id>` - Quick sell an item
- `!refresh` - Refresh balance from Hive blockchain

### Admin Commands
- `!storeadmin` - Open admin management panel
- `!givepek <player> <amount>` - Give PeakeCoin to a player
- `!setprice <item_id> <price>` - Update item price

### Console Commands
- `hive_store_open` - Open store interface
- `hive_store_wallet` - Display wallet information
- `hive_store_refresh` - Refresh balance

## File Structure

```
HiveStore/
├── addon.json                 # Addon metadata
├── README.md                  # This file
├── lua/
│   ├── autorun/
│   │   └── hive_store_init.lua # Main initialization
│   └── hive_store/
│       ├── config.lua          # Configuration settings
│       ├── shared/
│       │   └── sh_items.lua    # Item definitions
│       ├── server/
│       │   ├── sv_init.lua     # Server initialization
│       │   ├── sv_database.lua # Database management
│       │   ├── sv_peakecoin.lua# PeakeCoin integration
│       │   ├── sv_commands.lua # Chat commands
│       │   └── sv_networking.lua# Network communication
│       └── client/
│           ├── cl_init.lua     # Client initialization
│           ├── cl_gui.lua      # User interface
│           └── cl_networking.lua# Client networking
└── materials/
    └── hive_store/            # Store icons and images
```

## Troubleshooting

### Common Issues

1. **Store won't open**
   - Check console for errors
   - Ensure all files are in correct directories
   - Verify addon.json is valid

2. **Balance not updating**
   - Check PeakeCoin API configuration
   - Verify Hive account linking
   - Use `!refresh` command to manually update

3. **Items not spawning**
   - Check item class names in sh_items.lua
   - Verify you have the required addons for custom items
   - Check server console for spawn errors

4. **Admin commands not working**
   - Verify admin groups in config.lua
   - Check if admin permissions are enabled
   - Ensure player has correct user group

### Debug Mode
1. Set developer mode in console: `developer 1`
2. Check logs in `garrysmod/data/hive_store/`
3. Review transaction logs for debugging

## Integration with Real Hive Blockchain

To implement real PeakeCoin transactions:

1. **Install Hive Libraries**: Add Hive JavaScript libraries
2. **Keychain Integration**: Implement Hive Keychain for secure transactions
3. **Account Linking**: Create system for players to link Steam to Hive accounts
4. **Transaction Verification**: Verify blockchain transactions before item delivery
5. **Error Handling**: Implement proper error handling for failed transactions

## Support

For issues or questions:
1. Check the console for error messages
2. Review configuration settings
3. Test with default settings first
4. Check if all dependencies are installed

## License

This addon is provided as-is for educational and entertainment purposes.
