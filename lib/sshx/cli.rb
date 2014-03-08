require 'fileutils'
require 'shellwords'

module Sshx
	module Cli
		class << self
			def start(args = ARGV)

				Cli.init

				if args.length == 0
					puts 'sshx is just a wrapper of ssh.'
					puts `ssh`
				return
				end

				config_file_path = '/tmp/sshx_config'
				Cli.make_temporary_config(config_file_path)

				command = 'ssh'
				args.each{|arg|
					command << ' ' + arg.shellescape
				}
				command << ' -F ' + config_file_path

				system(command)
				status = $?.exitstatus

				File.unlink(config_file_path)

				exit status

			end

			def init()

				home_directory = File.expand_path('~')

				if !File.exist?(home_directory + '/.sshx')
					Dir.mkdir(home_directory + '/.sshx')
					FileUtils.cp(home_directory + '/.ssh/config', home_directory + '/.sshx/ssh_config')
				end

			end

			def make_temporary_config(target_path)

				home_directory = File.expand_path('~')

				config = ''
				Dir::foreach(home_directory + '/.sshx/') {|file_path|
					if /^\./ =~ file_path
					next
					end
					file = open(home_directory + '/.sshx/' + file_path)
					config << file.read + "\n"
					file.close
				}

				file = open(target_path, 'w')
				file.write(config)
				file.close

			end

		end
	end
end
