Gem::Specification.new do |s|
  s.name              = 'sshx'
  s.version           = '0.0.0'
  s.summary           = 'Extended ssh command'
  s.files             = `git ls-files`.split("\n")
  s.authors           = ['katty0324']
  s.email             = 'kataoka@sirok.co.jp'
  s.homepage          = 'https://github.com/katty0324/sshx'
  s.rubyforge_project = 'sshx'
  s.description       = 'Extended ssh command to use multi ssh_config, namespace and command completion.'
end
