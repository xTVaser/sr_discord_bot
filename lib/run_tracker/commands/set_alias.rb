module RunTracker
  module CommandLoader
    module SetAlias
      extend Discordrb::Commands::CommandContainer

      command(:setalias, description: '',
                         usage: "!setalias <game/category> <new alias>\nAlias must be unique.",
                         min_args: 3,
                         max_args: 3) do |_event, _type, _oldAlias, _newAlias|

        # If the user didnt properly enter the first argument
        if !_type.casecmp('game').zero? || !_type.casecmp('category').zero?
          return :usage
        # If first argument is correct, then check if the newly provided alias is valid
        elsif !/[^a-zA-Z0-9\-()&:]./.match(_newAlias).empty?
          return :usage
        end

        # If they entered game, check for that existing game alias
      end # end command body
    end # end SetAlias
  end
end
