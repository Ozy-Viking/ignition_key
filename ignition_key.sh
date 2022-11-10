#!/bin/zsh

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`

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
		exit 1
	fi
}
function SHOWHELPANDEXIT(){
	echo "${BLUE}Usage: sudo ./ignition_key.sh [user_id{1000-1500}]${NC}\nLeave black to use default user_id: 1000"
	exit 0
}

if [ $1 = -h ] || [ $1 = --help ]
then
	SHOWHELPANDEXIT
fi

# Testing if root...
if [ $UID -ne 0 ]
then
	RED "You must run this script as root!"
	exit 1
fi

LOGINUSERID=1000

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
else
	RED "USING BASH"
fi

shellrc=(~/.bashrc)


if [ ! -e added.repos ] # Stop adding repos 10000 times
then
	BLUE "Set up repositories"
	BLUE "Adding sublime-text repo"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo add-apt-repository ppa:ts.sch.gr/ppa

	touch added.repos 
fi

BLUE "Updating repositories..."
sudo apt update

BoilerDirectories=('Documents' 'Music' 'Pictures' 'Public' 'Templates' 'Videos') 

PythonVersonNumber=3

PythonPackages=('python3-full' 'python3-pip' 'python3-dev' 'build-essential' 'python3-doc' 'python-is-python3' 'python3-requests' 'python-dev-is-python3' 'python3-venv' 'idle' 'python3-pil' 'python3-requests')

PythonModuleNames=('flask' 'flask-login' 'colorama' 'passlib' 'pwntools' 'netifaces' 'iptools' 'pyopenssl' 'pydispatch' 'scapy')

PackageNames=('git' 'nmap' 'terminator' 'apt-transport-https' 'sublime-text' 'simplescreenrecorder' 'taskwarrior' 'guake' 'openvpn' 'docker.io' 'curl' 'pinta' 'exiftool'  'sqlitebrowser' 'wireshark' 'xclip' 'binwalk' 'tesseract-ocr' 'foremost' 'bsdgames' 'hexedit' 'golang' 'golang-go' 'sqlite' 'nikto' 'zbar-tools' 'qrencode' 'pdfcrack' 'virtualbox-qt' 'vagrant' 'fcrackzip' 'unrar' 'steghide' 'ffmpeg' 'gimp' 'cmake' 'mplayer' 'sshpass' 'tcpflow' 'tcpdump' 'libcompress-raw-lzma-perl' 'oracle-java8-installer' 'zsh' 'zsh-syntax-highlighting' 'zsh-common' 'zsh-dev' 'zsh-doc' 'zsh-static' 'zsh-autosuggestions'
	)




BLUE 'Installing Python Packages...'
for name in $PythonNames
do
	BLUE "Installing $name..."
	apt-get install -y $name --install-suggests
	CheckError "Failed to install: $(name)"
done

BLUE 'Installing Python Modules...'
for name in $PythonModuleNames
do
	BLUE "Installing $name..."
	pip install $name
	CheckError "Failed to install: $(name)"
done

BLUE 'Installing General Packages...'
for name in $PackageNames
do
	BLUE "Installing $name..."
	apt install -y $name
	CheckError "Failed to install: $(name)"
done

BLUE "Removing boilerplate home directories..."
for dir in $BoilerDirectories
do
	BLUE "Removing $dir..."
	rmdir ~/$dir
done

BLUE "Adding xclip alias..."
grep "alias xclip" ~/.bashrc
if [ $? -eq 1 ]
then
	echo "alias xclip='xclip -selection clipboard'" >> $shellrc
fi

BlUE "Adding GIT default credentials"
git config --global user.name "Ozy-Viking"
git config --global user.email "zthankin@gmail.com"

BLUE "Setting terminator as the default terminal emulator..."
sed -i s/Exec=gnome-terminal/Exec=terminator/g /usr/share/applications/gnome-terminal.desktop

BLUE "Installing Spotify..."
sudo snap install spotify

BLUE "Adding self to docker..."
sudo groupadd docker
sudo usermod -aG docker $(LOGINUSER)
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
rm discord.deb

BLUE "Installing Atom..."
wget "https://atom.io/download/deb" -O atom.deb
dpkg -i atom.deb
rm atom.deb

BLUE "Installing Hopper..."
wget "https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.3.14-Linux.deb"
dpkg -i Hopper-v4-4.3.14-Linux.deb
rm Hopper-v4-4.3.14-Linux.deb

BLUE "Downloading stegsolve.jar..."
wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
chmod +x "stegsolve.jar"

BLUE "Install Real VNC Viewer..."
wget "https://realvnc.com/download/file/viewer.files/VNC-Viewer-6.22.826-Linux-x86.deb" -O vnc_viewer.deb
dpkg -i vnc_viewer.deb
rm vnc_viewer.deb

BLUE "Install Real VNC Connect (Server)..."
wget 'https://realvnc.com/download/file/vnc.files/VNC-Server-6.2.1-Linux-x64.deb' -O vnc_server.deb
dpkg -i vnc_server.deb
rm vnc_server.deb

BLUE "Adding VNC Connect (Server) service to the default startup /etc/rc.local..."
grep "vncserver-x11-serviced.service" /etc/rc.local
if [ $? -eq 1 ]
then
	echo "systemctl start vncserver-x11-serviced.service" >> ~/etc/rc.local
fi

# TODO: replicate kali linux zsh.
# BLUE "Forcing a color prompt in ~/.bashrc..."
# grep "export PS1" ~/.bashrc
# if [ $? -eq 1 ]
# then
# 	echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> ~/.bashrc
# fi

