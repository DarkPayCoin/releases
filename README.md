# releases
Latest DarkPay scripts and apps


# releases
Wallets &amp; apps

## WINDOWS 10 users

Please right-click darkpaycoin-qt.exe and open with admin rights to avoid perm errors

## MAC OS X users

Wallet built with 10.11SDK. Use with MacOS 10.11+
There could be artifacts in the let menu bar due to latest QT libs quite unstable with MAC

## LINUX users

Wallet built generic-linux, tested with 14.04/16.04/18.04 Ubuntu




MASTERNODE SETUP GUIDE

v 1.1 - 10/05/2018

------------------------


# DarkPayCoin




# GET YOUR COLD WALLET UP & RUNNING

Download the latest version corresponding to your OS :
https://github.com/DarkPayCoin/darkpaycoin/releases/

# UNPACK & LAUNCH IT

Windows : double-click  darkpaycoin-qt.exe
Mac : open the dmg file and drag darkpaycoin to apps
Linux : click darkpaycoin-qt or in shell : ./darkpaycoin-qt

# GET SOME COINS

We have some interesting bounty programs ...

CREATE YOUR COLD WALLET FOR COLLATERAL

Open console : Tools → Debug console

In the console type following command to get new address :

getaccountaddress MNXXXXX

where « MNXXXX » is the alias (unique name) of your masternode

the console will then return your new address, copy it as we’ll send MN collateral



# SEND COLLATERAL

You will send collateral to yourself, so the coins will remain in your local wallet ; once masternode is enabled, you can put your local wallet offline, your coins will not be exposed to internet and your masternode will work without cointaining any coin.

Click « Send » and enter the address you just created, collateral amount is 10,000 DKPC, then send and confirm




# GETTING YOUR MASTERNODE TX ID

Wait a minute or so, the go back in console and type :

masternode outputs


You will see your collateral transaction id ; please note it as we’ll need it to setup your masternode.
The tx hash and the following number (output_id = 0 or 1) must be noted :



# GETTING YOUR MASTERNODE PRIVATE KEY

In console and type :

masternode genkey


You will see your masternode privkey, note it and never share it !


# MASTERNODE CONFIGURATION (COLD WALLET FILE)

Edit the file masternode.conf file from Tools menu, or manually locate and edit your masternode.conf 
file in the DarkPayCoin directory.


Edit the file to have one-line per MN, be careful to not leave any spaces or tabs after :

MNXXXXX vps_ip_adrr:6667 mn_privkey tx_hash tx_idnothing after last chars 


example :

MN1 4.123.6.66:6667  88frgtsc7zEnaJTeZ7d1D7239Nywaes3gHNZFVJGP6vBQertds 45vghfdcvf68955258364dersbfca18ea871798b516 0

save the file.


# VPS MN CONFIGURATION 

connect your VPS with ssh, get and run the DarkPayCoin MN install script :

rm dpc_mn_install.sh  if you’re updating from previous version
wget https://raw.githubusercontent.com/DarkPayCoin/releases/master/dpc_mn_install.sh && chmod +x dpc_mn_install.sh  && ./dpc_mn_install.sh 

Answer the script and provide your MN private key (or generate new one and put it in masternode.conf local cold wallet file) to auto-configure .

You can monitor it with :


tail -f ~/.darkpaycoin/debug.log


Once finished you can restart cold wallet .


# MN ACTIVATION FROM COLD WALLET

Your masternode will appear in the list as « MISSING », it is normal.
Wait for at least 10 confirmations of your collateral tx and your wallet has fully synced.
Start your masternode from the UI, or you can also start it in the cold wallet console :

Masternode start-alias 0 MNALIAS


example :


VPS commands :

	systemctl status darkpaycoin.service
	systemctl start darkpaycoin.service
	systemctl stop darkpaycoin.service

In your VPS debug.log file the output show MN is active.




# WHERE ARE THE CONF FILES LOCATED ?


Windows
Go to Start > Run > %APPDATA%\DarkPayCoin
(or just enter the above path in explorer)

or in explorer UI click to reach :
C:\Users\%username%\AppData\Roaming\DarkPayCoin

OSX (MacOS)

Open a finder window, then select the "Go" dropdown menu. In this menu please press the "Go to Folder..." option. In the window that opens type: ~/Library/Application Support/DarkPayCoin and press enter. If the folder cannot be found please repeat the steps and enter: ~/.DarkPayCoin

~/Library/Application\ Support/DarkPayCoin
(/Users/YourUserName/Library/Application\ Support/DarkPayCoin)

Linux
~/.DarkPayCoin
(Hidden folder ".DarkPayCoin" - control+h to display in the GUI, ls -a to display in terminal)




# HELP

Need for help ? Ask our devs in Discord : https://discord.gg/Jwnjhwh
