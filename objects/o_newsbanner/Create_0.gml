y = -600
image_alpha = 0
depth = -15001
req = 18 //Change this so that news can appear
newsText = string_upper(loc(618))

//text = "New Level Editor has been released! The UI was updated to make it easy for people to make levels. You can now make levels much more quickly, the UI makes more sense, and this was in development during February and March. This is still in 'Beta' so please give us feedback in the official discord server.\n\nHave fun!"
//text = "Wow! We have released [rainbow][wave]SKINS[/] for the setting button! To gather them, participate in the [c_yellow]'Distance Cog'[/] event where you have to put your mouse on the setting button in order to rotate the settings cog enough to get it going! The more you spin it, the farther it goes. 1st place gets a golden cog, 2nd place silver, and 3rd bronze.\n\nHave Fun!"
//text = "What's this? You can earn a random key while playing? But what kind of game will you get? Is the game even public or not? And most of all, is it even a steam key, or something else entirely... You will find out eventually, only select players will be chosen at random or by simply playing."
//text = "Added donation DLCs. These are solely to support the developer. When you purchase the donation DLCs, you get a badge which is upgradable! Also, in future updates, donators will be able to play 'Special Levels' which are donator only levels. For base game players, the special levels will appear in Endless Run.\n\nHave fun!"
//text = "Full Release of the game has been released! It has been 5 years of development, thank you so much for playing. If you have any bugs to report, or any features you want me to add, let me know on discord. Thanks :)\n\n\n\nInfiland"
//text = "Release 1.0.6 is here! [c_yellow]New Cheats have been added![/] Also check out the Level Select, added [c_yellow]very important text[/] over there! Removed the Wiki button and placed the development contribution in the Support Section.\n\nIf you have any bugs to report, or any features you want me to add, let me know on discord.\n[rainbow]Merry Christmas"
//text = "Release 1.1.0 is here! Added 30 NEW ACHIEVEMENTS, changed Steam Achievements, thus having a new progression system, some levels are improved, added further controller support like adding an ability to skip levels and scrolling through achievements and changing settings!\n\nI'm sure you'll find more interesting things. [rainbow]Have Fun and happy 2024!"
//text = "Release 1.1.1 is here! Added better modding support and controller icons! Also improved customization code much better so that later things can be added easily.\n\nHave Fun!"
//text = "Release 1.1.2 is here! A new skin has been added and improved customization code even more.\n\nHave fun!"
//text = "Release 1.1.3 is here! You can now get skins through the wheel! Just become an active player and you'll be able to get all of the skins in The Colorful Creature!\n\nHave Fun!"
//text = "Release 1.1.4 is here! You can now restart challenges with CTRL + Restart.\n\n Have Fun!"
//text = "Release 1.1.6 is here! Fixed few bugfixes and added tiny suprises! Also fullscreen finally saves and there's borderless fullscreen so yay!\n\nHave fun!"
//text = "Release 1.1.7 is here! Added partial Czech, Portuguese and Slovenian! Improvements to Calendar! Code Refactored all of the skins, hats and items in the game! Well, you might not even know what that means but whatever!\n\nHave fun!"
//text = "The FREEDOM UPDATE! The game is now open sourced! You can now help develop the game, ensuring a longlasting life of this game. I have many things to talk about, so please read the 'News' on this. If you want to contribute, click the 'Help Development' or 'Feedback' buttons to get started.\n\nThank you!"
//text = "Release 1.1.8 is here! Added quests and 40 OF THEM!! You can now earn credits by completing quests, each day you have 3 random quests to beat. Along with the update come general improvements.\n\nHave fun!"
text = "Release 1.1.9 introduces the TCC Economy! You can now recieve drops by actively playing the game, then you can trade with other players and sell those items!\n\nAlso, added [rainbow][wave]SKIN MASTERIES[/] so you can truly show your bling!\n\nHave fun!"
//text = "What's better than a soundtrack? [rainbow][wave]A SUPER SOUNDTRACK![/]\n\nThe difference? It includes all .flp files so you can remix songs, it also has unused songs and sound effects!\n\nAnd finally, you get a [s_badgesmenu,15] Isn't that cute?"

if global.moddedGameDir != "" {
text = "You are running a modded client! Save files will not be confilcted with the modded game. Have fun!\n\n[c_yellow]Mod Name: " + string(global.moddedGameDir)	
newsText = string_upper(loc(677))
sprite_index = s_moddedbanner
} else {
if req <= global.gamenews { instance_destroy() }	
}