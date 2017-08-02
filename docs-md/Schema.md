# Database Schema

## tracked-games
| column name      | type         | notes |  
| ---------------- | ------------ | ---   |  
| game-id          | varchar(255) | PK    |
| game-alias       | varchar(255) | Req   |
| game-name        | text         | Req   |
| announce-channel | integer      | Req   |
| categories       | json         | ...   |
| moderators       | json         | ...   |

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
| access-level | integer      | Req   |
