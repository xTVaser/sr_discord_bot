# Database Schema

## tracked-games
| column name      | type         | notes |  
| ---------------- | ------------ | ---   |  
| game_id          | varchar(255) | PK    |
| game_alias       | varchar(255) | Req   |
| game_name        | text         | Req   |
| announce_channel | varchar(255) | Req, Text but is a number   |
| categories       | json         | ...   |
| moderators       | json         | ...   |

## tracked-runners
| column name            | type         | notes |
| ---------------------- | ------------ | ---   |
| user_id                | varchar(255) | PK    |
| current_personal_bests | json         | ...   |
| historic_runs          | json         | ...   |

## managers
| column name  | type         | notes |
| ------------ | ------------ | ----- |
| user_id      | varchar(255) | PK    |
| access_level | integer      | Req   |
