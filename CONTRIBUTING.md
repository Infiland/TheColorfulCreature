# How to Compile, Test and Develop TCC:
Note: While other IDE's are possible to use, developing TCC is preferable using the GameMaker IDE.
Here are basic instructions on how to successfully run the game

1. Download the [latest version of GameMaker](https://gamemaker.io/en/download) (2024.4)
Official Site: https://gamemaker.io/en/download
Steam: https://store.steampowered.com/app/1670460/GameMaker/
3. Clone this repository https://github.com/Infiland/TheColorfulCreature
4. Open the project in GameMaker from where you cloned it.
5. Download the [Steamworks v1.55 SDK](https://partner.steamgames.com/downloads/list) and put it under the folder 'C:\Users\User\Desktop\sdk' (IT MUST BE IN THIS EXACT LOCATION OR THE GAME WILL NOT WORK), the SDK can be downloaded on https://partner.steamgames.com/ but requires a steam account. For Linux or other platforms, I don't know, find a way lmao  ( ͡° ͜ʖ ͡°)
6. You have to modify the "Steamworks" extension so that it aligns with the sdk path (IT MUST BE 'C:\Users\User\Desktop\sdk' TO AVOID CONFLICTS)
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
1. In GameMaker IDE, click the "Hamburger" icon (three line icon) and click "Included Files"
2. Press "Open in Explorer"
3. Go to folder "Other" and find "contributors.txt"
4. Add yourself in at the bottom of the document!

While debugging or testing in gamemaker, you won't see contributors, unless the steam version is ran.

# How to make a mod for TCC
NOTE: If you are trying to improve the core of the game, consider improving the base game instead.
1. Fork this reposetory
2. In o_loading object in the "Game Start" Event, change the global.moddedGameDir variable to have your mod name, this is so that your mod doesn't conflict with the base game saves.
3. You can modify the mod to however you'd like.
4. Contact Infiland if you want the mod to be available for the general public on steam