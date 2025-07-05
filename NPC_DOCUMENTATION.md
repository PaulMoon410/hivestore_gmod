# HiveStore NPCs - McCoy Brothers

## Overview
The HiveStore addon now includes two hillbilly shopkeeper NPCs - the McCoy Brothers who run a trading post in the mountains.

## The Brothers

### Jebediah "Jeb" McCoy (Elder Brother)
- **Entity**: `npc_hivestore_elder_brother`
- **Role**: Main shopkeeper, handles all categories
- **Personality**: Older, more experienced, weathered appearance
- **Dialogue**: Friendly but serious, talks about running the business
- **Appearance**: Darker skin, full beard with gray streaks, weathered look

### Cletus "Clete" McCoy (Younger Brother)  
- **Entity**: `npc_hivestore_younger_brother`
- **Role**: Weapons & tools specialist
- **Personality**: Younger, more energetic, enthusiastic about firearms
- **Dialogue**: Excited, talks about hunting and fixing things
- **Appearance**: Lighter skin, light stubble, cleaner appearance

## Features

### Interactive Dialogue
- Multiple greeting messages
- Context-appropriate shop talk
- Farewell messages
- Personality-based responses

### Specialized Stores
- **Elder Brother**: Access to all store categories
- **Younger Brother**: Specialized weapons & tools store with filtered inventory

### Visual Effects
- Custom hillbilly appearance with procedural textures
- Animated name tags
- Particle effects (pipe smoke, tool sparks)
- Realistic facial animations

### Behaviors
- Face players when approached
- Random idle animations
- Occasional maintenance activities
- Invulnerable to damage

## Console Commands (Admin Only)

```
hivestore_spawn_elder       - Spawn Elder Brother NPC
hivestore_spawn_younger     - Spawn Younger Brother NPC  
hivestore_spawn_both        - Spawn Both Brothers
hivestore_remove_npcs       - Remove All NPCs
```

## How to Use

1. **Spawn NPCs**: Use console commands or spawn from the entities menu
2. **Interact**: Walk up to either brother and press E
3. **Shop**: Browse their specialized inventories
4. **Trade**: Purchase items with PeakeCoin

## Customization

### Dialogue
Edit the `Dialogue` tables in each NPC's `init.lua` to customize their speech patterns.

### Appearance
Modify the skin generator in `cl_skin_generator.lua` to change their appearance.

### Behavior
Adjust the `Think()` functions to modify their idle behaviors and animations.

## Integration

The NPCs are fully integrated with the existing HiveStore system:
- Use the same PeakeCoin currency
- Access player balances
- Process transactions
- Trigger store GUI
- Support admin commands

## Future Enhancements

- Custom clothing/accessories
- More detailed facial expressions
- Additional dialogue trees
- Seasonal appearance changes
- Interactive props (smoking pipe, workbench)
