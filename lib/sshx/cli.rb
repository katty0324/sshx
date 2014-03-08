require 'fileutils'
require 'shellwords'

module Sshx
	module Cli
		class << self
			def start(args = ARGV)

				init

				if args.length == 0
					puts 'sshx is just a wrapper of ssh.'
					puts `ssh`
				return
				end

				config_file_path = '/tmp/sshx_config'
				make_temporary_config(config_file_path)

				if args.length == 2 && args[0] == 'init' && args[1] == '-'
					puts make_commands(config_file_path).join("\n")
					File.unlink(config_file_path)
				return
				end

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

			def get_hosts(config_path)

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

				return hosts

			end

			def make_commands(config_path)

				commands = []

				hosts = get_hosts(config_path)
				commands.concat(make_complete_commands(hosts))
				commands.concat(make_alias_commands())

				return commands

			end

			def make_complete_commands(hosts)

				commands = [];

				commands.push('_sshx(){ COMPREPLY=($(compgen -W "' + hosts.join(' ') + '" ${COMP_WORDS[COMP_CWORD]})) ; }')
				commands.push('complete -F _sshx sshx')

				return commands

			end

			def make_alias_commands()

				commands = [];

				commands.push('alias ssh=sshx')
				commands.push('complete -F _sshx ssh')

				return commands

			end

		end
	end
end
