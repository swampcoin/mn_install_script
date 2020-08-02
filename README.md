# mn_install_script
<b>Automated SwampCoin Masternode Installation Guide</b>
<br>
This is a complete guide to setup a Masternode for SwampCoin using the automated install script. This method uses a "cold" Windows wallet with a "hot" <b>Ubuntu 18.04 Linux</b> VPS. The reason for this is so your coins will be safe in your Windows wallet offline and the VPS will host the Masternode but will not hold any coins.  <u>Other versions of ubuntu not supported</u>. 
<br><br>
<b>Requirements</b>
Download the latest SwampCoin Windows wallet here https://github.com/swampcoin/swamp/releases<br>
Download and install an SSH client (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)<br>
Exactly 20000 SWAMP coins sent to a new receiving address with at least 15 confirmations<br>
A private key generate from your local wallet (<b>masternode genkey</b> in debug console)<br>
Ubuntu 18.04 VPS (use Vultr with this link and we both get free credit https://www.vultr.com/?ref=8233173 )<br>
The ip address of your VPS/Server<br>
Your local wallet's masternode.conf file configured as documented in the <b>Preparing the conf Files</b> section of https://github.com/swampcoin/swamp/blob/master/doc/masternode-setup.md<br><br>
<b>Running the Masternode script</b><br>
In your wallet, select 'Debug Console' from the Tools menu<br>
Use command 'masternode genkey' (this is your Masternode Private Key) and save it for use later<br>
Use command 'masternode outputs' (this is your txid or transaction id of the 20k collateral), save it <br>
Open SSH Client, enter your VPS IP, use port '22' and login with username 'root'<br>
Use the password provided by the VPS provider to gain access to the server<br>
Once you are logged in, make sure you have git installed:<br><br>
sudo apt-get install git -y<br><br>
Once confirmed run the full install script:<br><br>
git clone https://github.com/swampcoin/mn_install_script.git && cd mn_install_script && chmod 755 swamp_mn_installer.sh && ./swamp_mn_installer.sh<br><br>
To install sentinel only (the script above does this so skip if have run the full install):

git clone https://github.com/swampcoin/mn_install_script.git && cd mn_install_script && chmod 755 sentinel_setup.sh && ./sentinel_setup.sh<br><br>

<b>Completing the Masternode setup,</b><br>
In your VPS terminal, use command 'swamp-cli mnsync status' and wait for AssetID: to be 999<br>
In your wallet, select 'Debug Console' from the Tools menu<br>
In the Debug Console type the command 'masternode outputs' (these outputs will be used in Masternode Configuration File)<br>
In your wallet, select 'Open Masternode Configuration File' from the Tools menu<br>
Following the example, enter the required details on a new line (without #) and save the file<br>
In your wallet, click 'Reload Config' from the 'Masternodes' tab<br>
Select your Masternode and click 'Start alias'<br>
In your VPS terminal, use command 'swamp-cli masternode status' and you should see your Masternode was successfully started<br><br>

<b>Error Troubleshooting</b><br>
If for some reason you don’t have Git installed, you can install git with the following command:<br><br>

sudo apt-get install git -y<br><br>

If script doesn't start:<br>

Check that you have write permission in the current folder<br>
Check that you can change permission on a file<br>
If you are still facing issues, please get in contact with the Swamo Coin community on Discord (https://discord.gg/PxwMzE2)
