# Install sentinel
echo 'Installing dependencies...'
sudo apt-get -y python-pip
sudo apt-get -y install python
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
