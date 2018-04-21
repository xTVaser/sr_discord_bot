module RunTracker
    module Stackdriver
        @LOCAL_LOGGING = false
	    @logging = nil
        begin
            @logging = Google::Cloud::Logging.new
        rescue Exception
            @LOCAL_LOGGING = true
        end

        ##
        # Logs to Stackdriver
        # :INFO :WARNING :ERROR
        def self.log(data, level = :INFO)
            if !@LOCAL_LOGGING
                entry = @logging.entry
                entry.severity = level
                entry.payload = data
		entry.resource.type = "gce_instance"
		entry.log_name = "sr_discord_bot"
                @logging.write_entries(entry)
            else
                if level == :INFO
                    puts "[INFO] #{data}"
                elsif level == :WARNING
                    puts "[WARN] #{data}"
                else
                    puts "[ERROR] #{data}"
                end
            end
        end

        def self.exception(exception)
            self.log("#{exception.message} #{exception.backtrace}", :ERROR)
        end
    end
end
