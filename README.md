# Speedrun Tracking Discord Bot
A Discord Bot specialising in supporting speedrunning related discord chat rooms.

## Notice
Bot provided AS-IS, I won't be fixing issues for a while if ever, if you make a change to fix something I would appreciate if you could contribute back with a PR.

## Contents

* [Features](#features)
* [Installation](#installation)
  * [Adding Bot to Server](#adding-bot-to-server)
  * [Setting up Heroku](#setting-up-heroku)
* [Commands](#commands)
  * [Admin Only Commands](#admin-only-commands)
  * [Moderator Only Commands](#moderator-only-commands)
  * [All User Commands](#all-user-commands)
* [Known Issues and Short Comings](#known-issues-and-short-comings)


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
* Install bundle
* run `rake update`
* create a `vars.env` file in the root directory
* Log into the web version of discord, and go to [this page](https://discordapp.com/developers/applications/me)
* Create a new app, give it a name, give bot does not require OAuth2 Authorization.
* To the `vars.env` file add `CLIENT_ID=<your client_id>` and `TOKEN=<your token>`
* Next use the following link to add the bot to your server, replacing `CLIENT_ID` appropriately `discordapp.com/oauth2/authorize?&client_id=CLIENT_ID&scope=bot&permissions=0`
* You should now see the bot offline in your server

### Setting up Heroku
* Create a heroku account and link with a credit card to get a full 1000 free hours every month, otherwise you will not be able to run this bot 24/7
* Create a new app with a Postgres data-addon, as well as a `worker` dyno, enable this dyno
* You can either set it to work off the local git CLI, or fork (or not) the repo and let it build from that
* Go into settings and then configure the environment variables
* Add the `CLIENT_ID` and `TOKEN` vars.
* Get the Postgres Database credentials and add them to the environment variables as `DATABASE_URL`
* Heroku should spin up the process and you should see the bot come online in your server
* If not, look for problems by going to the `more` dropdown and clicking `view logs` sometimes restarting all dynos is required.
* The reason this works is due to the `Procfile` in the root directory, fyi.

## Commands
* Commands have 3 tiers of permissions and users can be granted access.
* By default, the server owner has Admin privledges only.

### Admin Only Commands

### Moderator Only Commands

### All User Commands

## Known Issues and Short Comings

  
Discord bot specialising in supporting speedrunning related chat rooms

Speedrun.com API [https://github.com/speedruncom/api](https://github.com/speedruncom/api)
