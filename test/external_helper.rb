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
	include LogMessage
	
	def initialize
		@log = GlobaLog.logger(STDERR,:warn)
	end
	
	def log
		log_all_level('external')
	end
	
end
