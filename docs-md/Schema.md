# Database Schema

## tracked-games
| column name      | type         | notes |  
| ---------------- | ------------ | ---   |  
| game_id          | varchar(255) | PK    |
| game_alias       | varchar(255) | Req   |
| game_name        | text         | Req   |
| announce_channel | bigint       | Req   |
| categories       | json         | ...   |
| moderators       | json         | ...   |

## tracked-runners
| column name            | type         | notes |
| ---------------------- | ------------ | ---   |
| user_id                | varchar(255) | PK    |
| user_name              | varchar(255) | ...   |
| historic_runs          | json         | ...   |
| num_submitted_wrs      | integer      | ...   |
| num_submitted_runs     | integer      | ...   |
| total_time_overall     | bigint       | ...   |

## managers
| column name  | type         | notes |
| ------------ | ------------ | ----- |
| user_id      | varchar(255) | PK    |
| access_level | integer      | Req   |
