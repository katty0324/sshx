require 'fileutils'
require 'shellwords'

module Sshx
	module Cli
		class << self
			def start(current_command = $0, args = ARGV)

				current_command = File.expand_path(current_command)

				if !init(current_command)
					exit 1
				end

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

			def init(current_command)

				home_directory = File.expand_path('~')

				if File.exist?(home_directory + '/.sshx')
				return true
				end

				puts "\e[36m"
				puts ' ------------------------- '
				puts '   ####  #### #   # #   #  '
				puts '  #     #     #   #  # #   '
				puts '   ###   ###  #####   #    '
				puts '      #     # #   #  # #   '
				puts '  ####  ####  #   # #   #  '
				puts ' ------------------------- '
				puts '     Welcome to sshx!      '
				puts "\e[0m"
				puts 'Initialize sshx...'

				puts 'Import ssh config file...'

				Dir.mkdir(home_directory + '/.sshx')
				FileUtils.symlink(home_directory + '/.ssh/config', home_directory + '/.sshx/ssh_config')
				
				puts 'Make config file...'
				
				File.open(home_directory + '/.sshx/config', 'w'){|file|
					file.puts('Separator .')
					file.puts('Alias true')
					file.puts('Ssh ' + `which ssh`)
					file.puts('TemporaryConfig /tmp/ssh_config')
				}

				puts 'Edit .bashrc file...'

				bashrc_path = nil
				initial_commands = []
				initial_commands.push('# Initialize sshx')
				initial_commands.push('eval "$(sshx init -)"')
				initial_command = initial_commands.join("\n")

				if File.exist?(home_directory + '/.bashrc')
					bashrc_path = home_directory + '/.bashrc'
				elsif File.exist?(home_directory + '/.bash_profile')
					bashrc_path = home_directory + '/.bash_profile'
				else
					puts "\e[33m[ERROR] Failed to find ~/.bashrc or ~/.bash_profile. The following command should be run at the begining of shell.\e[0m"
					puts ''
					puts initial_command
					puts ''
				return false
				end

				File.open(bashrc_path, 'a'){|file|
					file.puts(initial_command)
				}

				puts 'Successfully initialized.'
				puts ''

				return true

			end

			def make_temporary_config(target_path)

				home_directory = File.expand_path('~')

				configs = []
				Dir::foreach(home_directory + '/.sshx/') {|file_path|

					if /^\./ =~ file_path
					next
					end

					file = open(home_directory + '/.sshx/' + file_path)

					namespace = nil
					separator = '.'

					while line = file.gets

						matches = line.scan(/NameSpace\s+([^\s]+)/i)
						if matches.length > 0
						namespace = matches[0][0]
						next
						end

						if namespace
							line = line.gsub(/(Host\s+)([^\s]+)/i, '\1' + namespace + separator + '\2')
						end

						configs.push(line)

					end

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
