# sshx

Extended ssh command to use multi ssh_config, namespace and command completion.

## Usage

You can use the sshx in the same way as ssh command because sshx is just a wrapper of ssh.

```bash
sshx hostname
```

## Multi configuration files

While ssh has only one configuration file .ssh/config, sshx can have multi configuration files in .sshx directory.

```bash
$ ls ~/.sshx/
album	blog	config
```

The album and blog are configuration files for sshx.

## Namespace

Syntax of sshx configuration files is the superset of ssh. It supports namespace additionally.

```
NameSpace blog

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
