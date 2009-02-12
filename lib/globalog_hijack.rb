class GlobaLog
	# Author:: lp (mailto:lp@spiralix.org)
	# Copyright:: 2009 Louis-Philippe Perron - Released under the terms of the MIT license
	# 
	# :title:GlobaLog/Hijack
	
	class Hijack < Hash
		require 'optparse'
		
		def initialize
			super()
			self[:log_level] = :fatal
			self[:log_output] = STDERR
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