# This gem aims to provide a global cascading logging system, command line arguments aware,
# to centralize the settings of your individual loggers.  
# 
# It is thought to be compatible with other gems using OptionParser to collect command line arguments, by hijacking the ARGV at require time before others grabs it.  (So, it must be required before say, 'Test/Unit' to hijack the ARGV).
# 
# Each individual logger can follow the setting's cascade, or not.  If it does, the command line arguments or the first globalog to setup its parameters have precedence over the local settings.  And in case no other globalog is setup is present, the local parameters are used for logging.
# 
# It is essentially compatible with existing Logger, because it uses logger as it base lib.  So all logging is done the same way, with all of logger instance methods also working on globalog instances.  You can then transition code logged with logger easily, by either replacing the Logger initialisation in your code by a GlobaLog initialisation, or by leaving logger where it is and only deriving its output and level settings from globalog class methods of the same names, still allowing you to tap into globalog cascading settings.
# 
# The logging in Globalog is done with Logger so please refer to its documentation for the logging methodologies: http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/
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
#
#  
# Author:: lp (mailto:lp@spiralix.org)
# Copyright:: 2009 Louis-Philippe Perron - Released under the terms of the MIT license
# 
# :title:GlobaLog

require 'logger'
class GlobaLog < Logger
	$logger_args ||= Hash.new
	
	def GlobaLog.logger(def_out,def_level,follow=true)
		Args.are(:log_output => def_out, :log_level => def_level)
		if follow
			log = self.new(Args::log_output)
			log.level = Args::log_level
		else
			log = self.new(def_out)
			log.level = Args.sym_to_level(def_level)
		end
		return log
	end
	
	def GlobaLog::output
		Args::log_output
	end
	
	def GlobaLog::level
		Args::log_level
	end
	
	module Args
		
		def Args.are(args)
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
	
	class OptHijacker < Hash
		require 'optparse'
		
		def initialize
			super()
			self[:log_level] = nil
			self[:log_output] = nil
			opts = OptionParser.new do |opts|
				opts.on('-L','--log-level [STRING]','sets the Test Log Level') do |string|
					self[:log_level] = string.to_sym
				end
				opts.on('-O','--log-output [I/O]','sets the Test Log output') do |io|
					self[:log_output] = io
				end
			end
			opts.parse!($keep_argv)
		end

		def self.keep_wanted_argv
			args = Array.new(ARGV); ARGV.clear; keep = []
			wanted = ['-L', '--log-level', '-O', '--log-output']
			catch :finished do
				loop do
					throw :finished if args.empty?
					catch :found do
						wanted.each do |arg|
							if args[0] == arg
								2.times { keep << args.shift }
								throw :found
							end
						end
						ARGV << args.shift
					end
				end
			end
			$keep_argv ||= keep
		end

		self.keep_wanted_argv
		Args.are(self.new)

	end
	
end