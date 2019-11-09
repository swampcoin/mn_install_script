# mn_install_script
Automated SwampCoin Masternode Installation Guide
This is a complete guide to setup a Masternode for SwampCoin using the sutomated install script. This method uses a "cold" Windows wallet with a "hot" <b>Ubuntu 16.04 Linux</b> VPS. The reason for this is so your coins will be safe in your Windows wallet offline and the VPS will host the Masternode but will not hold any coins.  <u>Other versions of ubuntu not supported</u>. 

Requirements
Download the latest SwampCoin Windows wallet here https://github.com/swampcoin/swamp/releases
Download and install an SSH Client of your choice
Exactly 1000 SWAMP coins sent to a new receiving address with at least 15 confirmations
Ubuntu 16.04 VPS (use Vultr with this link and we both get free credit https://www.vultr.com/?ref=8233173 )
Running the Masternode script
In your wallet, select 'Debug Console' from the Tools menu
Use command 'masternode genkey' (this is your Masternode Private Key)
Open SSH Client, enter your VPS IP, use port '22' and login with username 'root'
Use the password provided by the VPS provider to gain access to the server
Once you are logged in, make sure yhave git installed
sudo apt-get install git -y
Once confirmed run:
git clone https://github.com/swampcoin/mn_install_script.git && cd mn_install_script && chmod +x swamp_mn_installer.sh && ./swamp_mn_installer.sh

Completing the Masternode setup
In your VPS terminal, use command 'swamp-cli mnsync status' and wait for AssetID: to be 999
In your wallet, select 'Debug Console' from the Tools menu
In the Debug Console type the command 'masternode outputs' (these outputs will be used in Masternode Configuration File)
In your wallet, select 'Open Masternode Configuration File' from the Tools menu
Following the example, enter the required details on a new line (without #) and save the file
In your wallet, click 'Reload Config' from the 'Masternodes' tab
Select your Masternode and click 'Start alias'
In your VPS terminal, use command 'swamp-cli masternode status' and you should see your Masternode was successfully started


Error Troubleshooting
If for some reason you don’t have Git installed, you can install git with the following command:

sudo apt-get install git -y
If script doesn't start:

Check that you have write permission in the current folder
Check that you can change permission on a file
If you are still facing issues, please get in contact with the Veco Developers on Discord (https://discord.gg/PxwMzE2)
