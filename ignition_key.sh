#!/bin/zsh

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`

# Define defaults...
BoilerDirectories=(Documents Music Pictures Public Templates Videos) 
FILENAMES=('Standard-Apps' 'Python-Apps' 'Python-Packages')
LOGINUSERID=1000
shellrc=(~/.bashrc)


function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}
function CheckError(){
	if [ $? -eq 1 ] || [ $ERRORFLAG -eq 1 ]
	then
		RED "[-]${NC} $@"
		if [ $EXITFLAG -eq 1 ]
		exit 1
	fi
}
function SHOWHELP(){
	echo "${BLUE}Usage:${NC} sudo ./ignition_key.sh [user_id{1000-1500}]\nLeave black to use default user_id: 1000"
}
#--------------------------------------------------------

if [ $1 = "-h" ] || [ $1 = "--help" ]
then
	SHOWHELP
	exit 0
fi

# Testing if root...
if [ $UID -ne 0 ]
then
	RED "You must run this script as root!"
	SHOWHELP
	exit 1
fi



if [ $1 -gt 999 ] && [ $1 -lt 1501 ]
then 
	LOGINUSERID=$1
fi

echo $LOGINUSERID
LOGINUSER=$(id -nu $LOGINUSERID) 2>/dev/null
CheckError "Not a valid user. You used $LOGINUSERID"

if [ $SHELL = '/bin/zsh' ] || [ $SHELL = '/usr/bin/bash' ]
then
	BLUE "USING ZSH"
	shellrc=(~/.zshrc)
else
	RED "USING BASH"
	shellrc=(~/.bashrc)
fi

#--------------------------------------------------------

BLUE 'Adding repositories...'
if [ ! -e added.repos ] # Stop adding repos 10000 times
then
	BLUE "Set up repositories"
	BLUE "Adding sublime-text repo"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	add-apt-repository -y ppa:ts.sch.gr/ppa
	add-apt-repository -y ppa:fin1ger/cpupower
	touch added.repos 
fi

BLUE "Updating repositories..."
sudo apt update


for file in "filenames/${FILENAMES[@]}"
do
	if [ $file = 'Python-Packages' ] # Ensure python is installed first
	then
		BLUE 'Installing Python Packages...'
		for name in $PythonModuleNames
		do
			if [ -z $name ]
			then
				continue
			fi
			GREEN "[+] Installing $name..."
			pip3 install $name
			CheckError "Failed to install: $name"
		done
		continue
	fi

	BLUE "Installing Applications..."
	while read name; 
	do
		if [ -z $name ]
		then
			continue
		fi
		GREEN "[+] Installing $name..."
		apt-get install -y -qq $name
		CheckError "Failed to install: $name"
	done < $file
	echo
done

#--------------------------------------------------------

BLUE "Removing boilerplate home directories..."
for dir in $BoilerDirectories
do
	BLUE "Removing $dir..."
	rmdir /home/$LOGINUSER/$dir
	if [ $? -eq 1 ]
	then
		RED "[-]${NC} Failed to remove $dir."
	fi
done

BLUE "Adding xclip alias..."
grep "alias xclip" $shellrc
if [ $? -eq 1 ]
then
	echo "alias xclip='xclip -selection clipboard'" >> $shellrc
fi

BlUE "Adding GIT default credentials"
git config --global user.name "Ozy-Viking"
git config --global user.email "zthankin@gmail.com"
CheckError "Git failed to add config."

BLUE "Setting terminator as the default terminal emulator..."
sed -i s/Exec=gnome-terminal/Exec=terminator/g /usr/share/applications/org.gnome.Terminal.desktop
CheckError "Failed to set terminator as default terminal emulator."
# Location on pop-OS

# BLUE "Installing Spotify..."
# sudo snap install spotify

BLUE "Adding self to docker..."
sudo groupadd docker
sudo usermod -aG docker $LOGINUSER
if [ 'docker' = "$(id -nG 1000 | grep docker)" ]
then
	ERRORFLAG=1
	CheckError "Failed to join docker group.\nCurrent Groups: $(id -nG 1000)"
fi

BLUE "Adding GOPATH and GOBIN to .bashrc, so future installs are easy.."
grep "export GOPATH" $shellrc
if [ $? -eq 1 ]
then
	echo "export GOPATH=\$HOME/.go/" >> $shellrc
fi
grep "export GOBIN" $shellrc
if [ $? -eq 1 ]
then
	echo "export GOBIN=\$HOME/.go/bin" >> $shellrc
	echo "export PATH=\$PATH:\$GOBIN" >> $shellrc
fi

BLUE 'Installing Discord'
wget 'https://discord.com/api/download?platform=linux&format=deb' -O discord.deb
dpkg -i discord.deb
CheckError "Failed to install Discord"
rm discord.deb

BLUE "Installing Atom..."
wget "https://atom.io/download/deb" -O atom.deb
dpkg -i atom.deb
CheckError "Failed to install atom"
rm atom.deb

BLUE "Installing Hopper..."
wget "https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.3.14-Linux.deb"
dpkg -i Hopper-v4-4.3.14-Linux.deb
CheckError "Failed to install hopper"
rm Hopper-v4-4.3.14-Linux.deb

BLUE "Downloading stegsolve.jar..."
wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
CheckError "Failed to wget stegsolve"
chmod +x "stegsolve.jar"

BLUE "Install Real VNC Viewer..."
wget "https://realvnc.com/download/file/viewer.files/VNC-Viewer-6.22.826-Linux-x86.deb" -O vnc_viewer.deb
dpkg -i vnc_viewer.deb
CheckError "Failed to install VNC-Viewer-6"
rm vnc_viewer.deb

BLUE "Install Real VNC Connect (Server)..."
wget 'https://realvnc.com/download/file/vnc.files/VNC-Server-6.2.1-Linux-x64.deb' -O vnc_server.deb
dpkg -i vnc_server.deb
CheckError "Failed to install VNC-Server-6"
rm vnc_server.deb

BLUE "Adding VNC Connect (Server) service to the default startup /etc/rc.local..."
grep "vncserver-x11-serviced.service" /etc/rc.local
if [ $? -eq 1 ]
then
	echo "systemctl start vncserver-x11-serviced.service" >> ~/etc/rc.local
fi

# TODO: replicate kali linux zsh.
# BLUE "Forcing a color prompt in ~/.bashrc..."
# grep "export PS1" $shellrc
# if [ $? -eq 1 ]
# then
# 	echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> $shellrc
# fi
