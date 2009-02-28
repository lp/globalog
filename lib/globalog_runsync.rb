class GlobaLog
	
	def debug(arg,&block)
		sync_level(:debug) { super(arg,&block) }
	end
	
	def info(arg,&block)
		sync_level(:info) { super(arg,&block) }
	end
	
	def warn(arg,&block)
		sync_level(:warn) { super(arg,&block) }
	end
	
	def error(arg,&block)
		sync_level(:error) { super(arg,&block) }
	end
	
	def fatal(arg,&block)
		sync_level(:fatal) { super(arg,&block) }
	end
	
	def unknown(arg,&block)
		sync_level(:unknown) { super(arg,&block) }
	end
	
	private
	
	def sync_level(level)
		self.level = Args::log_level
		if Args.sym_to_level(level) >= Args::log_level
			yield
		end
	end
	
end