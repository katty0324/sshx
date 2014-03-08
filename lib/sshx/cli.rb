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
				puts Cli.config_completion(config_file_path)

				shell_args = []
				args.each{|arg|
					shell_args.push(arg.shellescape)
				}

				system('ssh ' + shell_args.join(' ') + ' -F ' + config_file_path)
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

				configs = []
				Dir::foreach(home_directory + '/.sshx/') {|file_path|
					if /^\./ =~ file_path
					next
					end
					file = open(home_directory + '/.sshx/' + file_path)
					configs.push(file.read)
					file.close
				}

				file = open(target_path, 'w')
				file.write(configs.join("\n"))
				file.close

			end

			def config_completion(config_path)

				hosts = []

				open(config_path) {|file|
					while line = file.gets
						matches = line.scan(/Host\s+([^\s]+)/i)
						if matches.length == 0
							next
						end
						hosts.push(matches[0][0])
					end
				}
				
				return 'complete -W "' + hosts.join(' ') + '" sshx'

			end
			
		end
	end
end
