module LogMessage
	
	def log_all_level(identifier)
		@log.debug('test') {"#{identifier} -- debug"}
		@log.info('test') {"#{identifier} -- info"}
		@log.warn('test') {"#{identifier} -- warn"}
		@log.error('test') {"#{identifier} -- error"}
		@log.fatal('test') {"#{identifier} -- fatal"}
		@log.unknown('test') {"#{identifier} -- unknown"}
	end
	
end

class External
	require 'logger'
	include LogMessage
	
	def initialize(type)
		case type
		when 0
			@log = GlobaLog.logger(STDERR,:warn)
			@id = type
		when 1
			@log = Logger.new(*GlobaLog::logger_params)
			@log.level = GlobaLog::level
			@id = type
		when 2
			@log = Logger.new(GlobaLog::output,*GlobaLog::options)
			@log.level = GlobaLog::level
			@id = type
		end
	end
	
	def log
		log_all_level("external #{@id}")
	end
	
end
