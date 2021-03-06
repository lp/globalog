class GlobaLog
	# The Args module manages the GlobaLog arguments in the background.
	# Author:: lp (mailto:lp@spiralix.org)
	# Copyright:: 2009 Louis-Philippe Perron - Released under the terms of the MIT license
	# 
	# :title:GlobaLog/Args
	module Args
		
		def Args.are(args,override=false)
			$logger_args ||= Hash.new; $logger_args[:opts] = true unless args[:opts].nil?
			if $logger_args[:opts].nil? and override == true
				$logger_args[:log_level] = args[:log_level].to_sym unless args[:log_level].nil?
				$logger_args[:log_output] = args[:log_output] unless args[:log_output].nil?
				$logger_args[:log_opts] = args[:log_opts] unless args[:log_opts].nil?
			else
				$logger_args[:log_level] ||= args[:log_level].to_sym unless args[:log_level].nil?
				$logger_args[:log_output] ||= args[:log_output] unless args[:log_output].nil?
				$logger_args[:log_opts] ||= args[:log_opts] unless args[:log_opts].nil?
			end
		end
		
		def Args::log_output
			$logger_args[:log_output]
		end

		def Args::log_level
			if $logger_args[:log_level].is_a?(Symbol)
				$logger_args[:log_level] = self.sym_to_level($logger_args[:log_level])
			end
			$logger_args[:log_level]
		end
		
		def Args::log_opts
			$logger_args[:log_opts]
		end
		
		def Args.sym_to_level(sym)
			case sym
			when :debug
				return Logger::DEBUG
			when :info
				return Logger::INFO
			when :warn
				return Logger::WARN
			when :error
				return Logger::ERROR
			when :fatal
				return Logger::FATAL
			else
				return Logger::UNKNOWN
			end
		end
		
	end
	
end