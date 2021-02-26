# MolPhyPackInstaller

Automatic installer shell scripts for molecular phylogenetic analyses.

## Prerequisites

On Debian GNU/Linux compatible distributions, Debian 11 Bullseye, Ubuntu 20.04LTS or Linux Mint 20 or later is required.

On Red Hat Enterprise Linux compatible distributions, Red Hat Enterprise Linux 8 or CentOS 8 is required.
Red Hat Enterprise Linux users need to enable CodeReady Linux Builder repository before installing Claident.
CentOS users need to enable PowerTools repository before installing Claident.

## How to use

```
#install molecular phylogenetic analysis programs and required programs
sh installMolPhyPack_Debian.sh
```

### If you need proxy to access the internet

Type and run the following commands before installation.

```
export http_proxy=http://server.address:portnumber
export https_proxy=http://server.address:portnumber
export ftp_proxy=http://server.address:portnumber
```

If you need username and password to use proxy, use the following commands instead of the above commands.

```
export http_proxy=http://username:password@server.address:portnumber
export https_proxy=http://username:password@server.address:portnumber
export ftp_proxy=http://username:password@server.address:portnumber
```

### How to change installation PATH

Set PREFIX environment variable before installation like below.

```
export PREFIX=/path/to/instllation/path
#install molecular phylogenetic analysis programs and required programs
sh installMolPhyPack_Debian.sh
```

### How to update to new version

Run installation scripts in a new working directory.
