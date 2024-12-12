# 🎄 Dream Christmas - FiveM Script

**Dream Christmas** is a festive multiplayer script designed for FiveM servers, bringing the holiday spirit with Snow, Snowballs, Snowman, Christmas trees, presents, and more!

**💸 Price:** We believe Christmas should be free for everyone! No server owner should feel pressured to spend money to bring the holiday cheer to their players. Let’s celebrate this wonderful season together—no excuses, just joy and community spirit! 🎅🎄  

It's offical next year, Christmas 2025, this script will be expanded once again. It was so well received that we want to continue it. Have a wonderful holiday season! 🎁

## Features
- **❄️ Snow System (with Snowballs)**\
    ![Picture1](https://i.imgur.com/DhPLtgV.png)
    ![Picture2](https://i.imgur.com/QqoCi59.gif)

- **☃️ Prop System (e.g. Snowman)**\
    ![Picture3](https://i.imgur.com/eyWSXka.gif)
    ![Picture4](https://i.imgur.com/kjxVuej.gif)
    ![Picture5](https://i.imgur.com/PA6TtBA.png)
    ![Picture6](https://i.imgur.com/io4wLq1.png)

- **🎄 Christmas Tree System**\
    ![Picture7](https://i.imgur.com/TVEFAlQ.gif)
    ![Picture8](https://i.imgur.com/JO3KYrz.png)
    ![Picture9](https://i.imgur.com/QvV8h6y.gif)

- **🎁Present System**\
    ![Picture10](https://i.imgur.com/ttkKvup.gif)
    ![Picture11](https://i.imgur.com/DyD6075.gif)
    ![Picture12](https://i.imgur.com/MZxq7ub.gif)

🗨️ Just some insights... test it for yourself 🎅

## Installation
1. **Download and extract** the script into your `resources` folder.
2. Add `ensure dream_christmas` to your `server.cfg`.
3. Configure settings in `/settings` to match your server's preferences.
4. Adjust the bridge system `/bridge/<framework>/*.lua`, if necessary.
5. Make sure to start `ox_lib` and `ox_target` before!

## Configuration
All settings are customizable in the script. Here are a few examples:
- **Language:** Change `DreamCore.Language` to `'en'`, `'de'`, etc.
- **Snow System:** Toggle snow and snowballs, and adjust snowball damage.
- **Prop System:** Adjust spawn intervals, zones, and rewards.
- **Christmas Tree & Present Rewards:** Configure cooldowns and prizes.

# ToDo
- [ ] Christmas Lootdrop
- [ ] Christmas Adventcalendar
- [x] QBCore Bridge with qb-target compatibility
- [x] Notify Trigger in config
- [x] Snowballs Serverside
- [x] Present Gift cooldown save after restart
- [x] Random Prop fixed option instead of random spawn
- [x] Ox_inventory compatibility
- [x] Webhooks
- [ ] Christmas Music / Soundeffect
- [x] Prevent Snowballs pickup indoors
- [x] Unarm Player when decorating tree, open gift etc.
- [x] Small HUD Overlay UI for Gifts etc.
- [ ] Setuper/Placer for PropSystem and Christmas Trees and Presents (To place them easily on the map)
- [ ] Christmas Quests
- [ ] PropSystem add more props
- [ ] Christmas Present remove when cooldown (open)
- [ ] Smoother Teleport to the prop
- [x] Snow Overlay when outside 
- [ ] Build Snowman
- [ ] Own timesync or something to fix the problem with multiple weather scripts
- [ ] Exports for other scripts

## Support 
For assistance, reporting bugs, or sharing suggestions, you can:  
- **Join our Discord:** [Dream Services Support](https://discord.gg/zppUXj4JRm)  
- **Create an Issue:** Submit your feedback or bug report directly on GitHub.  
- **Collaborate with us:** Open a Pull Request to contribute and improve the script.  

We’re here to help and always welcome contributions! 🚀

## Credits
- Script by **Dream Services** ([Tuncion](https://github.com/Tuncion)).  
  Give credit where it's due! Toggle `DreamCore.GiveCredits` to `true` to display a small thank-you message in-game. 

Happy Holidays! 🎅
