# sshx

Extended ssh command to use multi ssh_config, namespace and command completion.

## Installation

You can install sshx from RubyGems.

```bash
gem install sshx
```

## Usage

You can use the sshx in the same way as ssh command because sshx is just a wrapper of ssh.

```bash
sshx hostname
```

## Multi configuration files

While ssh has only one configuration file .ssh/config, sshx can have multi configuration files in .sshx directory.

```bash
$ ls ~/.sshx/
album       blog        config      ssh_config
```

The config file is configuration files for sshx. The album, blog and ssh_config (It's imported from ~/.ssh/config) are configuration for ssh.

## Multi hosts connection with tmux

You can connect to some hosts with [tmux](http://tmux.sourceforge.net/).

```bash
sshx blog.prd.web1,blog.prd.web2,blog.prd.web3
```

tmux must be installed if you use multi hosts connection. 

## Namespace

Syntax of sshx configuration files is the superset of ssh. It supports namespace additionally.

```
Namespace blog

Host prd.web
  HostName blog.katty.in
  Port 22
  User katty0324
  IdentityFile ~/.ssh/id_rsa
```

Then you can use following command.

```bash
sshx blog.prd.web
```

## Command completion

Command completion is also supported in sshx.

```bash
$ sshx blog.p
# If You type [TAB] here
$ sshx blog.prd.web
# the hostname will be compeleted.
```

## License

This tool is under MIT license.
