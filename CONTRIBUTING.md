# How to Compile, Test and Develop TCC:
Note: While other IDE's are possible to use, developing TCC is preferable using the GameMaker IDE.
Here are basic instructions on how to successfully run the game

1. Download the [latest version of GameMaker](https://gamemaker.io/en/download) (2024.4.1)
Official Site: https://gamemaker.io/en/download
Steam: https://store.steampowered.com/app/1670460/GameMaker/
3. Clone this repository https://github.com/Infiland/TheColorfulCreature
4. Open the project in GameMaker from where you cloned it.
5. The game requires [Steamworks SDK 1.55](https://partner.steamgames.com/downloads/list), put the sdk folder in to 'C:\Users\User\Documents\sdk' (IT MUST BE IN THIS EXACT LOCATION OR THE GAME WILL NOT WORK).
If you use Mac, I don't know, find a way lmao  ( ͡° ͜ʖ ͡°)
6. You have to see if the "Steamworks" extension aligns with the sdk path (IT MUST BE 'C:\Users\User\Documents\sdk' TO AVOID CONFLICTS)
7. Click 'Run' or press F5 in GameMaker to test the game

You can also do live debugging in GameMaker (F6), [read more here](https://gamemaker.io/en/tutorials/debugger)

# How to make changes in TCC
Note: Infiland can only update the game through steam on Steamworks, contributors can help make changes to the game
1. Make your local branch so that no conflicts happen
2. Make a change and commit
3. Do a pull request and wait for Infiland to accept the change

# How to make an issue
If you have any things to add, report bugs, or suggest something, it's a good idea to make an issue.

1. Go to the issues tab and click "New Issue"
2. While not required, you can write a title with "Feature: " / "Bug: " / "Suggestion: " / "Documentation: " or other and then specify the main point.
3. Write the issue with detail, unless the change is small.
4. Put respective labels, if your issue is an easy to fix/add, consider putting a "good first issue" label. Put "help wanted" if you don't know how to add/fix something.
5. Click "submit new issue", Infiland will assign the particular issue to a milestone for a set release.

# How to credit yourself in TCC
Note: This isn't required but if you'd like to credit yourself for helping the game, do the following:
1. In GameMaker IDE, click the "Hamburger" icon (three line icon) and click "Included Files" and press "Open in Explorer"
2. Go to folder "Other" and find "contributors.txt"
3. Add yourself in at the bottom of the document!

While debugging or testing in gamemaker, you won't see contributors, unless the steam version is ran.

# How to add new or edit translations
All translations for the game are found in [this google sheet](https://docs.google.com/spreadsheets/d/1sO2gPX9AtXJVg1b7byPOB_xi-h8dwmZt5X0aZ08_LOo/edit#gid=0) , please update the docs if you are changing anything.
Each cell is highlighted with a color:
- Words that aren't highlighted mean that they are ready to be translated (WHITE color)
- If you are unsure how to translate a certain word, highlight it in a YELLOW color. They can be highlighted by editors
- Words highlighted in GREEN means they are translated in-game
- Words highlighted in BLUE means the word was changed and needs to be re-translated again, return it to WHITE color once it has been translated
- If the word is green and you think that a translation is wrong, highlight it in WHITE and translate it properly!

As for importing translations from the google doc to the game, here's how you do it.

## Editing
1. In GameMaker IDE, click the "Hamburger" icon (three line icon) and click "Included Files" and press "Open in Explorer"
2. Go to folder "Languages" and find the .lang file you would like to edit.
3. Make sure the .lang file is correct like in the google sheets file, each word needs to have a number id.

## Adding a new language
1. In GameMaker IDE, click the "Hamburger" icon (three line icon) and click "Included Files" and press "Open in Explorer"
2. Go to folder "Languages" and make a new .lang file
3. Place translatons in the .lang file from the google sheets file, each word needs to have a number id and a language's ini at the top should be unique.
4. Go to the script switchlang(), place a new case (which will be the new language id) to add the new language. (WILL IMPROVE THIS LATER)
5. Go to the room r_settings and in the layer "Languages", add a new instance "o_changelanguages", then edit the creation code to include the new language id. (WILL IMPROVE THIS LATER SO YOU DON'T HAVE TO DO THIS)
Also go to the object "o_changelanguages" and in the draw event add a new case for the new language
6. In the object "o_settingspausemenu" in the Create Event under Languages, increment the for loop limit by 1 (WILL IMPROVE THIS LATER)

### Additional / Optional
7. Go to the script setLanguageDependingOnRegion() and add your language code for the game to auto-translate the game.

Note: The loc(id) function checks for a translated word based on ID.

## Store Page Translating
You can translate all of my store pages on Steam by going to [this repository](https://github.com/Infiland/InfilandGamesStorePageTranslations)

# How to make a mod for TCC
NOTE: If you are trying to improve the core of the game, consider improving the base game instead.
1. Fork this reposetory
2. In o_loading object in the "Game Start" Event, change the global.moddedGameDir variable to have your mod name, this is so that your mod doesn't conflict with the base game saves.
3. You can modify the mod to however you'd like.
4. Contact Infiland if you want the mod to be available for the general public on steam