# Production Stack installation instructions for Windows Users

The Open Source GIS full production stack was developed for use on machines running a Linux distribution. Hence for Windows users, it is recommended that you download and install the following for a smooth user experience when using the Open Source GIS Stack (OSGS).

1. [Windows Subsytem for Linux (WSL) and your Linux distribution of choice](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
2. [Docker](https://docs.docker.com/desktop/windows/install/)
3. [Bash and Git for Windows](https://git-scm.com/download/win)


**Note**: The OSGS stack was tested using the Ubuntu on the Windows Subsystem for Linux (WSL)

For Ubuntu create the .ssh directory and the authorized_keys file.  ```cd ~``` then follow these [directions](https://itectec.com/ubuntu/ubuntu-bash-home-user-ssh-authorized_keys-no-such-file-or-directory/). 

Next, you need to install the make utility for your Linux distribution. The make commands available for the OSGS platform are in the ```Makefile```. You also need to install the following dependencies: rpl, pwgen, pip using:

```
sudo apt-get update
sudo apt install make
sudo apt-get install rpl
sudo apt-get install pwgen
sudo apt-get install apache2-utils (#should solve your problem with missing htpasswd binary)
sudo apt install python3-pip
```

Sign up for a [Github account](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account) if you do not have one and [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) the [kartoza / osgs](https://github.com/kartoza/osgs) repository. Using the Git Bash terminal [clone](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository-from-github/cloning-a-repository) the forked repository onto your local machine. Start up your Linux distribution terminal and [navigate](https://www.how2shout.com/how-to/how-to-access-windows-subsystem-for-linux-from-ubuntu-terminal.html) to the location of the cloned repository.
