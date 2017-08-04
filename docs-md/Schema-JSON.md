top level fields require a DB migration  
This is essentially a DB + Object combined schema for a complete overview of what is planned to be satisfied.
## tracked-games
- `game_id` String
- `categories` JSON
  - `category_id` String
  - `category_name` String (Key)
  - `rules` String  
  - `current_wr_run_id` String  
  - `current_wr_time` Long (seconds)  

  - **STATS**
    - `longest_held_wr` Integer (hours)
    - `num_submitted_runs` Integer
    - `num_submitted_wrs` Integer  


- `mods` - JSON
  - `user_id` String
  - `user_name` String (Key)
  - `discord_id` String
  - `should_notify` Bool
  - `secret_key` String

  - **STATS**
    - `last_verified` Date
    - `total_verified` Integer


## tracked-runners
- `user_id` String
- `historic_runs` JSON
  - `game` JSON
    - `game_id` String
    - `categories` JSON
      - `category_id` String
      - `category_name` String
      - `milestones` JSON
        - `time` String (X:XX)
        - `date` Date

      - **STATS**
        - `num_submitted_runs` Integer
        - `num_previous_wrs` Integer
        - `longest_held_wr` Integer (hours)

    - **STATS**
      - `total_time_overall` Long (seconds)
      - `num_submitted_runs` Integer
      - `num_previous_wrs` Integer

- **STATS**
  - `num_submitted_runs` Integer
  - `total_time_overall` Long (seconds)
