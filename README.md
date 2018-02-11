# Speedrun Tracking Discord Bot
A Discord Bot specialising in supporting speedrunning related discord chat rooms.

## Notice
Bot provided AS-IS, I won't be fixing issues for a while if ever, if you make a change to fix something I would appreciate if you could contribute back with a PR.

## Contents

* [Features](#features)
* [Installation](#installation)
  * [Adding Bot to Server](#adding-bot-to-server)
* [Commands](#commands)
  * [Admin Only Commands](#admin-only-commands)
  * [Moderator Only Commands](#moderator-only-commands)
  * [All User Commands](#all-user-commands)
* [Known Issues and Short Comings](#known-issues-and-short-comings)
* [Dependencies](#dependencies)

## Features
* Integrates with speedrun.com's API
* PM's moderators if they opt-in when there are new runs that should be verified
* Announces newly verified runs in discord channels.
* Tracks various statistics for games, categories, and runners such as number of runs submitted, longest held world record.
* Can add custom resource links to things such as splits, tutorial videos, etc.
* Able to add games by name or by their speedrun.com ID
* Easily extendable to add more commands, just create another command module in `lib/run_tracker/commands` and add to the `lib/run_tracker/command_loader.rb` file

## Installation
### Adding Bot to Server
* Clone this repo, install ruby `2.4.2` or the latest through rvm
* Install bundle `gem install bundle`
* run `bundle update && bundle install`
* create a `vars.env` file in the root directory
* Log into the web version of discord, and go to [this page](https://discordapp.com/developers/applications/me)
* Create a new app, give it a name, this bot does not require OAuth2 Authorization.
* To the `vars.env` file add `CLIENT_ID=<your client_id>` and `TOKEN=<your token>`
* Next use the following link to add the bot to your server, replacing `CLIENT_ID` appropriately `discordapp.com/oauth2/authorize?&client_id=CLIENT_ID&scope=bot&permissions=0`
* You should now see the bot offline in your server
* run `rake run` or `make start` if you are on a unix environment.

## Commands
* Commands have 3 tiers of permissions and users can be granted access.
* By default, the server owner has Admin privledges only.
* By default as well, I have hardcoded my own discord_id to have admin privledges, you should disable this or change to your own ID.

### Admin Only Commands
* `~addgame`
* `~grant` - Use @mention autocomplete
* `~clearrundata` - Requires confirmation key 'DOIT'
* `~resetdb` - Requires confirmation key 'DOIT'
* `~removegame`

### Moderator Only Commands
* `~addresource`
* `~optin` - Must be called by the person wanting to receive the PMs
* `~optout` - Must be called by the person wanting to stop receiving PMs
* `~removeresource`
* `~setannounce` - Use the #channel-name autocomplete
* `~setcategoryalias` - I dont recommend changing the category alias as this is a pain in the ass
* `~setgamealias` - This will cascade and modify it's categories ones automatically

### All User Commands
* `~botinfo`
* `~listcategories`
* `~listgames`
* `~listmods`
* `~listresources`
* `~resource`
* `~statscategory`
* `~statsgame`
* `~statsrunner`

## Known Issues and Short Comings
* Too many things are case sensitive
* Tied runs may produce unexpected results
* Individual level leaderboards are not supported
* Subcategories are defined as their own separate categories
* Has not been throughly tested on every type of leaderboard so results may vary.
* One bot cannot support multiple servers at this time, one server per bot only.
* There are definitely bugs that I have not found, this is somewhat unavoidable due to the varied nature of the results of speedrun.com's API and unknown user input.
* Other things I'm forgetting

## Dependencies
* [Speedrun.com's REST API](https://github.com/speedruncomorg/api)
* [DiscordRB](https://github.com/meew0/discordrb)
* [ruby-pg](https://github.com/ged/ruby-pg)
