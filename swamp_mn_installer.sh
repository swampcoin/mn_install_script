#!/bin/bash

###################################
# Script by Swamp Coin Developers #
# SWAMP     v2.0.0.2              #
# https://swampcoin.tech         #
###################################

LOG_FILE=/tmp/install.log

decho () {
  echo `date +"%H:%M:%S"` $1
  echo `date +"%H:%M:%S"` $1 >> $LOG_FILE
}

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  exit "${code}"
}
trap 'error ${LINENO}' ERR

clear

cat <<'FIG'
                                                     ____  ,-.----.    
  .--.--.              .---.   ,---,               ,'  , `.\    /  \   
 /  /    '.           /. ./|  '  .' \           ,-+-,.' _ ||   :    \  
|  :  /`. /       .--'.  ' ; /  ;    '.      ,-+-. ;   , |||   |  .\ : 
;  |  |--`       /__./ \ : |:  :       \    ,--.'|'   |  ;|.   :  |: | 
|  :  ;_     .--'.  '   \' .:  |   /\   \  |   |  ,', |  ':|   |   \ : 
 \  \    `. /___/ \ |    ' '|  :  ' ;.   : |   | /  | |  |||   : .   / 
  `----.   \;   \  \;      :|  |  ;/  \   \'   | :  | :  |,;   | |`-'  
  __ \  \  | \   ;  `      |'  :  | \  \ ,';   . |  ; |--' |   | ;     
 /  /`--'  /  .   \    .\  ;|  |  '  '--'  |   : |  | ,    :   ' |     
'--'.     /    \   \   ' \ ||  :  :        |   : '  |/     :   : :     
  `--'---'      :   '  |--" |  | ,'        ;   | |`-'      |   | :     
                 \   \ ;    `--''          |   ;/          `---'.|     
                  '---"                    '---'             `---`         
FIG

# Check for systemd
#systemctl --version >/dev/null 2>&1 || { decho "systemd is required. Are you using Ubuntu 18.04?"  >&2; exit 1; }

# Check if executed as root user
#if [[ $EUID -ne 0 ]]; then
#	echo -e "This script has to be run as \033[1mroot\033[0m user."
#	exit 1
#fi

# Print variable on a screen
decho "Please make sure you double check information before hitting enter!"

read -e -p "Please enter username that will run SWAMP Core |CaSe SeNsItIvE|: " whoami
if [[ "$whoami" == "" ]]; then
	decho "WARNING: No user entered, exiting!!!"
	exit 3
fi
#if [[ "$whoami" == "root" ]]; then
#	decho "WARNING: User root entered? It is recommended to use a non-root user, exiting!!!"
#	exit 3
#fi
read -e -p "Server IP Address: " ip
if [[ "$ip" == "" ]]; then
	decho "WARNING: No IP entered, exiting!!!"
	exit 3
fi
read -e -p "Please enter Masternode Private Key (e.g. WYZEsru3J3kiy9itrLW1EzBt8RsF23s24co82rswUPrPgpJ6r6o # THE KEY YOU GENERATED IN YOUR WALLET EARLIER): " key
if [[ "$key" == "" ]]; then
	decho "WARNING: No Masternode private key entered, exiting!!!"
	exit 3
fi
read -e -p "(Optional) Install Fail2ban? (Recommended) [Y/n]: " install_fail2ban
read -e -p "(Optional) Install UFW and configure ports? (Recommended) [Y/n]: " UFW

# Install swap
decho "Enabling a swap partition..." 

if free | awk '/^Swap:/ {exit !$2}'; then
	echo "Has swap..."
else
	touch /var/swap.img
	chmod 600 /var/swap.img
	dd if=/dev/zero of=/var/swap.img bs=1024k count=2048
	mkswap /var/swap.img
	swapon /var/swap.img
	echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
fi

# Update package and upgrade Ubuntu
decho "Updating system and installing required packages..."   

sudo apt-get -y update
sudo apt-get -y upgrade

# Install required packages
decho "Installing base packages and dependencies..."

sudo apt-get -y install sudo >> $LOG_FILE 2>&1
sudo apt-get -y install wget >> $LOG_FILE 2>&1
sudo apt-get -y install git >> $LOG_FILE 2>&1
sudo apt-get -y install unzip >> $LOG_FILE 2>&1
sudo apt-get -y install virtualenv >> $LOG_FILE 2>&1
sudo apt-get -y install python-virtualenv >> $LOG_FILE 2>&1
sudo apt-get -y install pwgen >> $LOG_FILE 2>&1
sudo apt-get -y install mc >> $LOG_FILE 2>&1

# Install daemon packages
decho "Installing daemon packages and dependencies..."

sudo apt-get -y install software-properties-common libzmq3-dev pwgen >> $LOG_FILE 2>&1
sudo apt-get -y install git libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libboost-all-dev unzip libminiupnpc-dev python-virtualenv >> $LOG_FILE 2>&1
sudo apt-get -y install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python-pip unzip>> $LOG_FILE 2>&1

# Add Berkely PPA
decho "Installing bitcoin PPA..."

sudo apt-add-repository -y ppa:bitcoin/bitcoin >> $LOG_FILE 2>&1
sudo apt-get -y update >> $LOG_FILE 2>&1
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev >> $LOG_FILE 2>&1

decho "Installing miniupnpc..."
sudo apt-get -y install libminiupnpc-dev

decho "Installing libzmq..."
sudo apt-get -y install libzmq3-dev


if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
	decho "Optional install: Fail2ban"
	cd ~
	sudo apt-get -y install fail2ban >> $LOG_FILE 2>&1
	systemctl enable fail2ban >> $LOG_FILE 2>&1
	systemctl start fail2ban >> $LOG_FILE 2>&1
fi

if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
	decho "Optional install: UFW"
	sudo apt-get -y install ufw >> $LOG_FILE 2>&1
	sudo ufw allow ssh/tcp >> $LOG_FILE 2>&1
	sudo ufw allow sftp/tcp >> $LOG_FILE 2>&1
	sudo ufw allow 33333/tcp >> $LOG_FILE 2>&1
	sudo ufw allow 33334/tcp >> $LOG_FILE 2>&1
	sudo ufw default deny incoming >> $LOG_FILE 2>&1
	sudo ufw default allow outgoing >> $LOG_FILE 2>&1
	sudo ufw logging on >> $LOG_FILE 2>&1
	sudo ufw --force enable >> $LOG_FILE 2>&1
fi

decho "Create user $whoami (if necessary)"

# Deactivate trap only for this command
trap '' ERR
getent passwd $whoami > /dev/null 2&>1

if [ $? -ne 0 ]; then
	trap 'error ${LINENO}' ERR
	adduser --disabled-password --gecos "" $whoami >> $LOG_FILE 2>&1
else
	trap 'error ${LINENO}' ERR
fi

# Create swamp.conf
decho "Setting up SWAMP Core..." 

# Generate random passwords
user=`pwgen -s 16 1`
password=`pwgen -s 64 1`

echo 'Creating swamp.conf...'
mkdir -p $HOME/.swampcore/
cat << EOF > $HOME/.swampcore/swamp.conf
rpcuser=$user
rpcpassword=$password
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
masternode=1
masternodeprivkey=$key
externalip=$ip
EOF
chown -R $whoami:$whoami $HOME

# Install SWAMP Daemon
echo 'Downloading daemon...'
cd
wget https://github.com/swampcoin/swamp/releases/download/v2.0.0.2/swamp-v2002-ubuntu18-64.zip >> $LOG_FILE 2>&1
unzip swamp-v2002-ubuntu18-64.zip >> $LOG_FILE 2>&1
chmod -R 755 swampd swamp-cli swamp-tx >> $LOG_FILE 2>&1
cp swampd swamp-cli swamp-tx /usr/bin/ >> $LOG_FILE 2>&1
rm -rf swampd swamp-cli swamp-tx swamp-v2002-ubuntu18-64.zip >> $LOG_FILE 2>&1

# Run swampd 
sudo swampd

echo 'SWAMP Core prepared and launched...'

sleep 10

# Setting up sentinel
decho "Setting up sentinel..."

# Install sentinel
echo 'Downloading sentinel...'
git clone https://github.com/swampcoin/sentinel.git $HOME/sentinel
#chown -R $whoami:$whoami $HOME/sentinel
rm $HOME/sentinel/sentinel.conf
echo 'Creating sentinel.conf...'
cat << EOF > $HOME/sentinel/sentinel.conf
# specify path to swamp.conf or leave blank
# default is the same as SwampCore
swamp_conf=$HOME/.swampcore/swamp.conf

# valid options are mainnet, testnet (default=mainnet)
network=mainnet
#network=testnet

# database connection details
db_name=database/sentinel.db
db_driver=sqlite
EOF
#chown -R $HOME/sentinel/sentinel.conf

echo 'Setting up sentinel...'
cd $HOME/sentinel
virtualenv ./venv
./venv/bin/pip install -r requirements.txt

# Deploy script to keep daemon alive
cat << EOF > $HOME/swampdkeepalive.sh
until swampd; do
    echo "swampd crashed with error $?.  Restarting.." >&2
    sleep 1
done
EOF

chmod +x $HOME/swampdkeepalive.sh
chown $whoami:$whoami $HOME/swampdkeepalive.sh

# Setup crontab
echo "@reboot sleep 30 && $HOME/swampdkeepalive.sh" >> newCrontab
echo "* * * * * cd $HOME/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> newCrontab
crontab -u $whoami newCrontab
rm newCrontab

# Final Masternode instructions
decho "Starting your Masternode"
echo ""
echo "To start your Masternode please follow the steps below:"
echo "1 - In your VPS terminal, use command 'swamp-cli mnsync status' and wait for AssetID: to be 999" 
echo "2 - In your wallet, select 'Debug Console' from the Tools menu"
echo "3 - In the Debug Console type the command 'masternode outputs' (these outputs will be used in Masternode Configuration File)" 
#echo "4 - In your wallet, select 'Open Masternode Configuration File' from the Tools menu"
echo "5 - Following the example, enter the required details on a new line (without #) and save the file"
echo "6 - Close and re-open your wallet"
echo "7 - Select the masternode tab, then select your Masternode and click 'Start alias'"
echo "8 - In your VPS terminal, use command 'swamp-cli masternode status' and you should see your Masternode was successfully started"
echo ""
decho "If you have any issues, please get in contact with the SWAMP Developers on Discord (https://discord.gg/PxwMzE2)" 


#su $whoami
