class GlobaLog
	# Author:: lp (mailto:lp@spiralix.org)
	# Copyright:: 2009 Louis-Philippe Perron - Released under the terms of the MIT license
	# 
	# :title:GlobaLog/Args
	
	module Args
		
		def Args.are(args)
			$logger_args ||= Hash.new
			$logger_args[:log_level] ||= args[:log_level].to_sym
			$logger_args[:log_output] ||= args[:log_output]
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