require 'fileutils'
require 'shellwords'

module Sshx
	module Cli
		class << self

			@@home_directory = File.expand_path('~')
			@@namespace_separator = '.'
			@@enable_alias = true
			@@ssh_path = `which ssh`
			@@ssh_config_path = @@home_directory + '/.ssh/config'
			@@sshx_config_path = @@home_directory + '/.sshx/config'
			def start(args = ARGV)

				if !init()
					exit 1
				end

				load_config()

				if args.length == 0
					puts 'sshx is just a wrapper of ssh.'
					puts `#{@@ssh_path}`
				return
				end

				make_ssh_config()

				if args.length == 2 && args[0] == 'init' && args[1] == '-'
					puts make_commands().join("\n")
				return
				end

				shell_args = []
				args.each{|arg|
					shell_args.push(arg.shellescape)
				}

				system(@@ssh_path + ' ' + shell_args.join(' '))
				status = $?.exitstatus

				exit status

			end

			def init()

				if File.exist?(@@home_directory + '/.sshx')
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

				Dir.mkdir(@@home_directory + '/.sshx')
				FileUtils.cp(@@home_directory + '/.ssh/config', @@home_directory + '/.sshx/ssh_config')

				puts 'Make config file...'

				File.open(@@home_directory + '/.sshx/config', 'w'){|file|
					file.puts('NamespaceSeparator ' + @@namespace_separator)
					file.puts('EnableAlias ' + (@@enable_alias?'true':'false'))
					file.puts('SshPath ' + @@ssh_path)
				}

				puts 'Edit .bashrc file...'

				bashrc_path = nil
				initial_commands = []
				initial_commands.push('# Initialize sshx')
				initial_commands.push('eval "$(sshx init -)"')
				initial_command = initial_commands.join("\n")

				if File.exist?(@@home_directory + '/.bashrc')
					bashrc_path = @@home_directory + '/.bashrc'
				elsif File.exist?(@@home_directory + '/.bash_profile')
					bashrc_path = @@home_directory + '/.bash_profile'
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

			def load_config()

				file = open(@@home_directory + '/.sshx/config')
				while line = file.gets

					line = line.chomp

					matches = line.scan(/NamespaceSeparator\s+([^\s]*)/i)
					if matches.length > 0
					@@namespace_separator = matches[0][0]
					next
					end

					matches = line.scan(/EnableAlias\s+([^\s]*)/i)
					if matches.length > 0
					@@enable_alias = (matches[0][0] =~ /true$/i ? true : false)
					next
					end

					matches = line.scan(/SshPath\s+([^\s]*)/i)
					if matches.length > 0
					@@ssh_path = matches[0][0]
					next
					end

				end
				file.close

			end

			def make_ssh_config()

				@@home_directory = File.expand_path('~')

				configs = []
				Dir::foreach(@@home_directory + '/.sshx/') {|file_path|

					if /^\./ =~ file_path
					next
					end

					if /^config$/i =~ file_path
					next
					end

					file = open(@@home_directory + '/.sshx/' + file_path)

					namespace = nil

					while line = file.gets

						line = line.chomp

						matches = line.scan(/Namespace\s+([^\s]+)/i)
						if matches.length > 0
						namespace = matches[0][0]
						next
						end

						if namespace
							line = line.gsub(/(Host\s+)([^\s]+)/i, '\1' + namespace + @@namespace_separator + '\2')
						end

						configs.push(line)

					end

					file.close

				}

				file = open(@@ssh_config_path, 'w')
				file.write(configs.join("\n"))
				file.close

			end

			def get_hosts()

				hosts = []

				open(@@ssh_config_path) {|file|
					while line = file.gets

						line = line.chomp

						matches = line.scan(/Host\s+([^\s]+)/i)
						if matches.length == 0
						next
						end

						hosts.push(matches[0][0])

					end
				}

				return hosts

			end

			def make_commands()

				commands = []

				hosts = get_hosts()
				commands.concat(make_complete_commands(hosts))
				if @@enable_alias
					commands.concat(make_alias_commands())
				end

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
