require 'test/unit'

require File.join( File.dirname( File.expand_path(__FILE__)), '..', 'lib', 'globalog')
require File.join( File.dirname( File.expand_path(__FILE__)), 'external_helper')


class TestGlobaLogMain < Test::Unit::TestCase
	include LogMessage
	$test_file = 'test_log'
	
	def setup
		File.new($test_file,'w').close
	end
	
	def test_globalog
		output = STDERR
		level = :error
		@log = GlobaLog.logger(output,level,true)
		assert_equal(output,GlobaLog::output)
		assert_equal(3,GlobaLog::level)
	end
	
	def test_globalog_debug
		prepare_test(:debug)
		check_test(:debug)	
	end
	
	def test_globalog_info
		prepare_test(:info)
		check_test(:info)	
	end
	
	def test_globalog_warn
		prepare_test(:warn)
		check_test(:warn)	
	end
	
	def test_globalog_error
		prepare_test(:error)
		check_test(:error)	
	end
	
	def test_globalog_fatal
		prepare_test(:fatal)
		check_test(:fatal)	
	end
	
	def test_globalog_unknown
		prepare_test(:unknown)
		check_test(:unknown)	
	end
	
	def teardown
		@log.close
		File.delete($test_file)
	end
	
	private
	
	def prepare_test(level)
		@log = GlobaLog.logger($test_file,level,true)
		log_all_level('base test')
		pid1 = fork {log_all_level('fork 1'); exit}
		pid2 = fork {log_all_level('fork 2'); exit}
		Process.waitpid(pid2,0)
		External.new(0).log
		External.new(1).log
		External.new(2).log
	end
	
	def check_test(level)
		f = File.open($test_file,'r'); content = f.read; f.close
		check_players(content)
		check_level(level,content)
	end
	
	def check_players(content)
		assert_match(/base/,content)
		assert_match(/fork 1/,content)
		assert_match(/fork 2/,content)
		assert_match(/external 0/,content)
		assert_match(/external 1/,content)
		assert_match(/external 2/,content)
	end
	
	def check_level(level,content)
		level_match = match_assertions(content)
		level_no_match = no_match_assertions(content)
		case level
		when :debug
			0.upto(5) { |num| level_match[num].call }
		when :info
			0.upto(4) { |num| level_match[num].call }
			5.downto(5) { |num| level_no_match[num].call }
		when :warn
			0.upto(3) { |num| level_match[num].call }
			5.downto(4) { |num| level_no_match[num].call }
		when :error
			0.upto(2) { |num| level_match[num].call }
			5.downto(3) { |num| level_no_match[num].call }
		when :fatal
			0.upto(1) { |num| level_match[num].call }
			5.downto(2) { |num| level_no_match[num].call }
		when :unknown
			0.upto(0) { |num| level_match[num].call }
			5.downto(1) { |num| level_no_match[num].call }
		end
	end
	
	def match_assertions(content)
		[ lambda { assert_match(/unknown/,content) },
			lambda { assert_match(/fatal/,content) },
			lambda { assert_match(/error/,content) },
			lambda { assert_match(/warn/,content) },
			lambda { assert_match(/info/,content) },
			lambda { assert_match(/debug/,content) } ]
	end
	
	def no_match_assertions(content)
		[ lambda { assert_no_match(/unknown/,content) },
			lambda { assert_no_match(/fatal/,content) },
			lambda { assert_no_match(/error/,content) },
			lambda { assert_no_match(/warn/,content) },
			lambda { assert_no_match(/info/,content) },
			lambda { assert_no_match(/debug/,content) } ]
	end
	
	
	
end