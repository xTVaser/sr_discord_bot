# Database Schema

## tracked-games
| column name      | type         | notes |  
| ---------------- | ------------ | ---   |  
| game-id          | varchar(255) | PK    |
| announce-channel | integer      | ...   |
| categories       | json         | ...   |
| moderators       | json         | ...   |
## TODO add game_alias for tracked-games
## tracked-runners
| column name            | type         | notes |
| ---------------------- | ------------ | ---   |
| user-id                | varchar(255) | PK    |
| current-personal-bests | json         | ...   |
| historic-runs          | json         | ...   |

## managers
| column name  | type         | notes |
| ------------ | ------------ | ----- |
| user-id      | varchar(255) | PK    |
| access-level | integer      | ..... |
