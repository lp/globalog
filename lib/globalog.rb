# This gem aims to provide a global cascading logging system, command line arguments aware,
# to centralize the settings of your individual loggers.  
# 
# It is thought to be compatible with other gems using OptionParser to collect command line arguments, by hijacking the ARGV at require time before others grabs it.  (So, it must be required before say, 'Test/Unit' to hijack the ARGV).
# 
# Each individual logger can follow the setting's cascade, or not.  If it does, the command line arguments or the first globalog to setup its parameters have precedence over the local settings.  And in case no other globalog is setup is present, the local parameters are used for logging.
# 
# It is essentially compatible with existing Logger, because it uses logger as it base lib.  So all logging is done the same way, with all of logger instance methods also working on globalog instances.  You can then transition code logged with logger easily, by either replacing the Logger initialisation in your code by a GlobaLog initialisation, or by leaving logger where it is and only deriving its output and level settings from globalog class methods of the same names, still allowing you to tap into globalog cascading settings.
# 
# The logging in GlobaLog is done with Logger so please refer to its documentation for the logging methodologies: http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/
# 
# ///////////////////////////////////////////////////////////////////////////////////////
# Example:
# 
#   # script1.rb
#   require 'globalog'
#   $log = GlobaLog.logger(STDERR,:warn)
#   
#   module Script1
#     def example
#       $log.warn("Example") {"Printing Warning!!"}
#       $log.info("Example") {"Printing Info!!"}
#       $log.debug("Example") {"Printing Debug!!"}
#     end
#   end
#   
# calling the example method will result in:
# 
#   Script1.example   # => Printing Warning!!
#   
# But if you require script1, inside an other script, setting different GlobaLog init parameters, they will have precedence and cascade down as in the example below.
# 
#   # script2.rb
#   require 'globalog'
#   require 'script1'
#   
#   $log = GlobaLog.logger(STDERR,:info)
#   Script1.example
#   
# running script2 will output:
#   
#   > ruby script2.rb
#   => Printing Warning!!
#   => Printing Info!!
#   
# And you can also run script2 with arguments to get different log level or output:
# 
#   > ruby script2.rb -L debug
#   => Printing Warning!!
#   => Printing Info!!
#   => Printing Debug!!
#   
# So this allow you to set a default Logger setting in your libraries, override them with an other default setting in client scripts and still get the flexibility to override both defaults at runtime by providing command line arguments.  Ideal for testing purposes where you want a default log level for test overriding the Local log level of your tested libraries, while allowing you to choose the test log level at runtime. 
# See Logger rdoc for full operation details: http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/
#  
# Author:: lp (mailto:lp@spiralix.org)
# Copyright:: 2009 Louis-Philippe Perron - Released under the terms of the MIT license
# 
# :title:GlobaLog

require 'logger'
class GlobaLog < Logger
	require File.join( File.dirname( File.expand_path(__FILE__)), 'globalog_args')
	require File.join( File.dirname( File.expand_path(__FILE__)), 'globalog_hijack')
	require File.join( File.dirname( File.expand_path(__FILE__)), 'globalog_runsync')
	
	# The GlobaLog.logger acts as a constructor method for the logger.
	# === Parameters
	# * _def_out_ = the output io or logfile path
	# * _def_level_ = the log level, as a symbol (i.e. :warn, :info, etc)
	# * _opt1_, _opt2_ = (optional) logger extra log rotation parameters (see Logger rdoc for more details) 
	# * _master_ = (optional) the logger presence in the cascading settings chain
	# _master_ can be any of the following:
	# * _true_ = Impose its settings on the loggers down the chain
	# * _false_ = Use the chain settings if present (default)
	# * _nil_ = Is out of the chain
	# === Example
	# 	@log = GlobaLog.logger('logfile.txt',:error,true)
	
	def GlobaLog.logger(def_out,def_level, opt1= :empty, opt2= :empty, opt3= :empty)
		logger_opts = []; master = false
		[opt1,opt2,opt3].each do |opt|
			if opt == :empty
				next
			elsif opt == true || opt == false || opt == nil
				master = opt
			else
				logger_opts << opt
			end
		end
		Args.are({:log_output => def_out, :log_level => def_level, :log_opts => logger_opts},master)	
		if master.nil?
			log = self.new(def_out,*logger_opts)
			log.level = Args.sym_to_level(def_level)
		else
			log = self.new(Args::log_output,*logger_opts)
			log.level = Args::log_level
		end
		return log
	end
	
	# The GlobaLog::output method return the current log output.
	# Can be used to chain existing Logger instances to GlobaLog cascade, 
	# when you don't want to replace them with GlobaLog instances.
	# (and you can only replace the constructor, the logging will still work)
	# === Example
	# 	$logger = Logger.new(GlobaLog::output)
	def GlobaLog::output
		Args::log_output
	end
	
	# The GlobaLog::level method return the current log level.
	# Can be used to chain existing Logger instances to GlobaLog cascade, 
	# when you don't want to replace them with GlobaLog instances.
	# (and you can only replace the constructor, the logging will still work)
	# === Example
	# 	$logger.level = GlobaLog::level
	def GlobaLog::level
		Args::log_level
	end
	
	# The GlobaLog::options method return the current extra Logger options.
	# i.e. Log rotations, size, etc.
	# They are returned as array so must be splatted before they are usefull for classic Logger initialization.
	# === Example
	# 	$logger = Logger.new(GlobaLog::output,*GlobaLog::options)
	def GlobaLog::options
		Args::log_opts
	end
	
	# The GlobaLog::logger_params method return the current full Logger parameter arguments.
	# They are returned as array so must be splatted before they are usefull for classic Logger initialization.
	# === Example
	# 	$logger = Logger.new(*GlobaLog::logger_params)
	def GlobaLog::logger_params
		return Args::log_output, *Args::log_opts
	end
	
end