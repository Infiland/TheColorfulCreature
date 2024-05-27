# How to make changes in TCC
Note: Infiland can only update the game through steam on Steamworks, contributors can help make changes to the game
1. Make your local branch / fork so that no conflicts happen
2. Make a change and commit
3. Do a pull request and wait for Infiland to accept the change :+1:
---
# How to make an issue
If you have any things to add, report bugs, or suggest something, it's a good idea to make an issue.

1. Go to the issues tab and click "New Issue"
2. While not required, you can write a title with "Feature: " / "Bug: " / "Suggestion: " / "Documentation: " or other and then specify the main point.
3. Write the issue with detail, unless the change is small.
4. Put respective labels, if your issue is an easy to fix/add, consider putting a "good first issue" label. Put "help wanted" if you don't know how to add/fix something.
5. Click "submit new issue", Infiland will assign the particular issue to a milestone for a set release. :+1:
---
# How to credit yourself in TCC
Note: This isn't required but if you'd like to credit yourself for helping the game, do the following:
1. Go to folder "Other" and find ["contributors.txt"](https://github.com/Infiland/TheColorfulCreature/blob/main/datafiles/Other/contributors.txt)
2. Add yourself in at the bottom of the document! :+1:

NOTE: While debugging or testing in gamemaker, you won't see contributors, unless the compiled steam version is ran.
If you really want to test out the feature, copy the contributors.txt to the runtime folder, the destination will be shown in the output console if the game crashes while failing to find the file.
---
# How to add new or edit translations
All translations for the game are found in [this google sheet](https://docs.google.com/spreadsheets/d/1sO2gPX9AtXJVg1b7byPOB_xi-h8dwmZt5X0aZ08_LOo/edit#gid=0) , please update the docs if you are changing anything.
Each cell is highlighted with a color:
- Words that aren't highlighted mean that they are ready to be translated (WHITE color) :white_circle: 
- If you are unsure how to translate a certain word, highlight it in a YELLOW :warning: color. They can be highlighted by editors
- Words highlighted in GREEN :white_check_mark: means they are translated in-game
- Words highlighted in BLUE :large_blue_circle: means the word was changed and needs to be re-translated again, return it to WHITE :white_circle: color once it has been translated
- If the word is GREEN :white_check_mark: and you think that a translation is wrong, highlight it in WHITE :white_circle: and translate it properly!

As for importing translations from the Google doc to the game, here's how you do it.
---
## Editing
1. Go to folder [Languages](https://github.com/Infiland/TheColorfulCreature/tree/main/datafiles/Languages) and find the .lang file you would like to edit.
2. Make sure the .lang file is correct like in the google sheets file, each word needs to have a number id.
---
## Adding a new language
1. Go to folder [Languages](https://github.com/Infiland/TheColorfulCreature/tree/main/datafiles/Languages) and make a new .lang file inside the folder.
2. Place translatons in the .lang file from the google sheets file, each word needs to have a number id and a language's ini at the top should be unique.
3. Go to the script [switchlang()](https://github.com/Infiland/TheColorfulCreature/blob/main/scripts/switchlang/switchlang.gml), place a new case (which will be the new language id) to add the new language. (WILL IMPROVE THIS LATER)
4. Go to the room r_settings and in the layer "Languages", add a new instance "o_changelanguages", then edit the creation code to include the new language id. (WILL IMPROVE THIS LATER SO YOU DON'T HAVE TO DO THIS)
Also go to the object [o_changelanguages in the Draw event](https://github.com/Infiland/TheColorfulCreature/blob/main/objects/o_changelanguagesettings/Draw_0.gml) add a new case for the new language
5. In the object [o_settingspausemenu in the Create event](https://github.com/Infiland/TheColorfulCreature/blob/main/objects/o_settingspausemenu/Create_0.gml) under the //Languages comment, increment the for loop limit by 1 (WILL IMPROVE THIS LATER)
---
### Additional / Optional
7. Go to the script [setLanguageDependingOnRegion()](https://github.com/Infiland/TheColorfulCreature/blob/main/scripts/setLanguageDependingOnRegion/setLanguageDependingOnRegion.gml) and add your language code for the game to auto-translate the game.

Note: The [loc(id)](https://github.com/Infiland/TheColorfulCreature/blob/main/scripts/loc/loc.gml) function checks for a translated word based on ID.
---
## Store Page Translating
You can translate all of my store pages on Steam by going to [this repository](https://github.com/Infiland/InfilandGamesStorePageTranslations)
---
# How to make a mod for TCC
NOTE: If you are trying to improve the core of the game, consider improving the base game instead.
1. Fork this reposetory
2. In [o_loading in the Game Start event](https://github.com/Infiland/TheColorfulCreature/blob/R1.2.0/objects/o_loading/Other_2.gml), change the global.moddedGameDir variable to have your mod name, this is so that your mod doesn't conflict with the base game saves.
3. You can modify the mod to however you'd like.
4. Contact Infiland if you want the mod to be available for the general public on steam! :+1: