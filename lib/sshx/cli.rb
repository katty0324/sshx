require 'fileutils'
require 'shellwords'

module Sshx
	module Cli
		class << self
			def start(args = ARGV)

				Cli.init

				if args.length == 0 then
					puts 'sshx is just a wrapper of ssh.'
					puts `ssh`
				return
				end

				command = 'ssh'
				args.each{|arg|
					command << ' ' + arg.shellescape
				}
				
				system(command)
				exit $?.exitstatus

			end

			def init

				home_directory = File.expand_path('~')

				if !File.exist?(home_directory + '/.sshx')
					Dir.mkdir(home_directory + '/.sshx')
					FileUtils.cp(home_directory + '/.ssh/config', home_directory + '/.sshx/ssh_config')
				end

			end

		end
	end
end
