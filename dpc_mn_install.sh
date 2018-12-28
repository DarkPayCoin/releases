#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='darkpaycoin.conf'
CONFIGFOLDER='/root/.darkpaycoin'
COIN_DAEMON='darkpaycoind'
COIN_CLI='darkpaycoin-cli'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/DarkPayCoin/darkpay/releases/download/v3.1.99/DarkPay-3.1.99-LINUX64.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='darkpaycoin'
COIN_PORT=6667
RPC_PORT=6668
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



purgeOldInstallation() {

echo -e "
▼ DarkPayCoin Installer v1.02
-----------------------------               
"

    echo -e "${GREY}Welcome to $COIN_NAME VPS setup script for your masternode${NC}"

    echo -e "${GREY}Searching and removing old $COIN_NAME files and configurations${NC}"
    #kill wallet daemon
	sudo killall $COIN_DAEMON > /dev/null 2>&1
    #remove old ufw port allow
    sudo ufw delete allow $COIN_PORT/tcp > /dev/null 2>&1
    #remove old files
    sudo rm $COIN_CLI $COIN_DAEMON $CHAIN> /dev/null 2>&1
    sudo rm -rf ~/.$COIN_NAME > /dev/null 2>&1
    #remove binaries and $COIN_NAME utilities
    cd /usr/local/bin && sudo rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1 && cd
    echo -e "${GREEN}* Done${NONE}";
}



function download_node() {
  mkdir /root/.darkpaycoin
  echo -e "${GREY}Downloading and Installing VPS $COIN_NAME Daemon${NC}"
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
   echo -e "${GREY}Downloading and Installing fast sync pack, please be patient and wait till the end of process...${NC}"
	wget -q $CHAIN_LINK
     echo -e "${GREY}Extracting fast sync pack, please be patient and wait till the end of process...${NC}"

	unzip $CHAIN 
  cp -r blocks /root/.darkpaycoin
  cp -r chainstate /root/.darkpaycoin
  cp peers.dat /root/.darkpaycoin
  rm -rf $TMP_FOLDER >/dev/null 2>&1
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


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=$RPC_PORT
port=$COIN_PORT
listen=1
server=1
daemon=1
addnode=136.243.185.4:6667
addnode=46.101.231.40:6667
addnode=67.99.220.116:6667
addnode=206.189.173.84:6667
EOF
}

function create_key() {
  echo -e "${YELLOW}Enter your ${RED}$COIN_NAME Masternode GEN Key${NC}. Or press enter generate new Genkey"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_PATH$COIN_DAEMON -daemon
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the GEN Key${NC}"
    sleep 30
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  fi
  $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
maxconnections=256
bind=$NODEIP
masternode=1
masternodeaddr=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY

#ADDNODES


EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
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


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC} Run again to re-install"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC} Run again to re-install"
  exit 1
fi
}

function prepare_system() {
echo -e "Preparing the VPS to setup. ${GREY}$COIN_NAME Masternode${NC}"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${PURPLE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-add-repository -y ppa:ubuntu-toolchain-r/test
apt-get update >/dev/null 2>&1
apt-get install libzmq3-dev -y >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 gcc-6 g++-6
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5 gcc-6 g++-6"
 exit 1
fi
clear
}

function important_information() {
 echo
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${GREEN}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${GREEN}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE GENKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN."
 if [[ -n $SENTINEL_REPO  ]]; then
 echo -e "${RED}Sentinel${NC} is installed in ${RED}/root/sentinel_$COIN_NAME${NC}"
 echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
}

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  #install_sentinel
  important_information
  configure_systemd
}


##### Main #####
clear
display_logo
purgeOldInstallation
checks
prepare_system
download_node
setup_node
