#!/bin/bash

###### DKPC PHASE 2 MN/VPS UPDATE SCRIPT v1.0 #######


TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='darkpaycoin.conf'
CONFIGFOLDER='/root/.darkpaycoin'
COIN_DAEMON='darkpaycoind'
COIN_CLI='darkpaycoin-cli'
COIN_PATH='/usr/local/bin/'
#COIN_TGZ='https://github.com/DarkPayCoin/releases/raw/master/latest/LINUX64/DarkPay-latest-LINUX64.zip'
COIN_TGZ='https://github.com/DarkPayCoin/darkpay/releases/download/v3.1.99/DarkPay-3.1.99-LINUX64.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='darkpaycoin'
COIN_PORT=6667
RPC_PORT=6668
#CHAIN_LINK='https://github.com/DarkPayCoin/releases/raw/master/dpc_fastsync.zip'
CHAIN_LINK='https://darkpaycoin.io/utils/dpc_fastsync.zip'
CHAIN='dpc_fastsync.zip'

NODEIP=$(curl -s4 icanhazip.com)

BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m" 
PURPLE="\033[0;35m"
RED='\e[38;5;202m'
GREY='\e[38;5;245m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'



# splash screen


function display_logo() {

echo -e "                                                                                                                                                     
       \e[38;5;52m      .::::::::::::::::::::::::::::::::::..                                        
       \e[38;5;202m   ..::::c:cc:c:c:c:c:c:c:c:c:c:c:c:cc:c::::.                                      
          .:.                                    ::.                                      
          .:c:                                   c::                                       
           .:c:                                 c::                                       
            .:c:                               cc:                                        
             .:c:                             c::                                         
              .:c:                           c::                                         
               .:c:                         c::                                            
                .:cc                       c::                                            
                 .:cc                     c::                                              
                  .:cc                   c::                                               
                   .:cc                 c::                                                
                    .:cc               c::                                                 
                     .:cc             c::                                                  
                      .::c           c:.                                                   
                       .:cc         c::                                                    
                        .::c       c:.                                                     
                         .::c     c:.                                                      
                           ::c.  c:.                                                       
                             .:.:.            \e[0m                                               
 

888888ba                    dP       \e[38;5;202m 888888ba                    \e[0m
88     8b                   88       \e[38;5;202m 88     8b                   \e[0m
88     88 .d8888b. 88d888b. 88  .dP  \e[38;5;202ma88aaaa8P' .d8888b. dP    dP \e[0m
88     88 88'   88 88'   88 88888     \e[38;5;202m88        88    88 88    88 \e[0m
88    .8P 88.  .88 88       88   8b.  \e[38;5;202m88        88.  .88 88.  .88 \e[0m
8888888P   88888P8 dP       dP    YP  \e[38;5;202mdP         88888P8  8888P88 \e[0m
                                                  \e[38;5;202m             88\e[0m
                                                  \e[38;5;202m        d8888P  \e[0m

"
sleep 0.5
}

function start_message() {

echo -e "
             ▼ DarkPay MN/VPS UPDATER
----------------------------------------------------               
"
echo -e "${GREY}Welcome to $COIN_NAME VPS update script for your masternode$"
echo -e "The script will download latest release and make sure configuration is OK.
"

}

function checks() {



if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}*** You are not running Ubuntu 16.04. Installation is cancelled. ***${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${GREEN}$COIN_NAME old daemon found.${NC}"
  
fi
}



purgeOldInstallation() {


    echo -e "${GREY}Stopping existing daemon an removing old executable...${NC}"


    #kill wallet daemon
	sudo killall $COIN_DAEMON > /dev/null 2>&1
    #remove old ufw port allow
    sudo ufw delete allow $COIN_PORT/tcp > /dev/null 2>&1
    #remove old files
    sudo rm $COIN_CLI $COIN_DAEMON $CHAIN> /dev/null 2>&1
    #sudo rm -rf ~/.$COIN_NAME > /dev/null 2>&1
    #remove binaries and $COIN_NAME utilities
    cd /usr/local/bin && sudo rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1 && cd
    echo -e "${GREEN}* Done${NONE}";
}


function prepare_system() {
echo -e "${GREY}Checking VPS setup, please wait (it may take several minutes depending on your system)...${NC}"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
# echo -e "${PURPLE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
# echo -e "Installing required packages, it may take some time to finish.${NC}"

apt-add-repository -y ppa:ubuntu-toolchain-r/test

apt-get update 
apt-get install libzmq3-dev -y 
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 gcc-6 g++-6 -y


if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "dpkg --configure -a"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5 gcc-6 g++-6"
 exit 1
fi

}

function download_node() {
  echo -e "${GREY}Downloading and installing latest release...${NC}"
  cd $TMP_FOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  unzip $COIN_ZIP >/dev/null 2>&1
  compile_error
#  cd linux
  chmod +x $COIN_DAEMON
  chmod +x $COIN_CLI
  cp $COIN_DAEMON $COIN_PATH
  cp $COIN_DAEMON /root/
  cp $COIN_CLI $COIN_PATH
  cp $COIN_CLI /root/
  cd ~ >/dev/null 2>&1
	
  #download chain
cd $CONFIGFOLDER >/dev/null 2>&1
  echo -e "${GREY}* Downloading last bootstrap to sync fast...${NC}"
wget -q $CHAIN_LINK
 echo -e "${GREY}* Cleaning chain and blocks files...${NC}"
 rm -rf $CONFIGFOLDER/blocks > /dev/null 2>&1
 rm -rf $CONFIGFOLDER/chainstate > /dev/null 2>&1

  echo -e "${GREY}* Unpacking bootstrap... Please wait, it could take several minutes depending on hardware.${NC}"

        unzip -f $CHAIN 
  echo -e "${GREY}* Unpacking bootstrap done !${NC}"
rm -rf $COIN_ZIP >/dev/null 2>&1
rm -rf $TMP_FOLDER >/dev/null 2>&1
rm -rf $CONFIGFOLDER/banlist.dat
  echo -e "${GREY}* Made some cleanup, starting node...${NC}"

}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}

function create_config() {
    echo -e "Keeping exitsting config folder."
}

function create_key() {
    echo -e "Keeping exitsting MN privkey."
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE

#ADDNODES
addnode=46.101.231.40
addnode=142.93.97.228
addnode=206.189.173.84
addnode=165.227.172.190
addnode=159.65.144.67
addnode=128.199.198.131
addnode=178.62.80.178
addnode=128.199.203.152
addnode=81.50.134.65
whitelist=46.101.231.40
whitelist=142.93.97.228
whitelist=206.189.173.84
whitelist=165.227.172.190
whitelist=159.65.144.67
whitelist=128.199.198.131
whitelist=178.62.80.178
whitelist=128.199.203.152
whitelist=81.50.134.65

EOF
}


function enable_firewall() {
  echo -e "${GREY}Checking firewall to allow ingress on port $COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}



function important_information() {
 echo
 echo -e "${GREY}-------------------------------------------------------------${NC}"
 echo -e "${GREY}-------------------------------------------------------------${NC}"
 echo -e "$COIN_NAME Phase2 Masternode is up and running listening on port ${GREEN}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${GREEN}$NODEIP:$COIN_PORT${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN."

 echo -e "-------------------------------------------------------------"
 echo -e "NOW PLEASE ${RED}ENABLE YOUR MN FROM YOUR CONTROL WALLET{NC}"

}


function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC} Run again to re-install"
  exit 1
fi
}




###### MAIN
##### Main #####
clear

display_logo
start_message
checks
purgeOldInstallation
#prepare_system
clear
download_node

get_ip
create_config
create_key
update_config
enable_firewall

 important_information
 configure_systemd
