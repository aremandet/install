#!/bin/bash
# Script pour installation du raspberry
# Configuration par gui 
# startlxde-pi

# Initialisations des variables 
couleur_rouge_gras="\033[31;1m"
couleur_jaune_gras="\033[33;1m"
couleur_normal="\033[0m"
ip="192.168.1.100"
gateway="192.168.1.1"
ssh_port="22100"

# Vérification que le script est bien lancé en root
if [ "$EUID" -ne 0 ];then
	echo -e "$couleur_rouge_gras""Erreur: Executer le script en root""$couleur_normal"
	exit
fi

# Configuration du language du systeme
echo "Configuration du language du systeme"
sudo sed -i "s/^LANG.*/LANG=fr_FR.UTF-8/g" /etc/default/locale

# Configuration du clavier
echo "Configuration du clavier"
sudo setxkbmap fr
sudo sed -i "s/^XKBLAYOUT=.*/XKBLAYOUT="fr"/" /etc/default/keyboard


# Configuration du password root
echo "Configuration du password root"
echo -e -n "$couleur_jaune_gras"
sudo passwd root
echo -e -n "$couleur_normal"

# Configuration du password pi
echo "Configuration du password pi"
echo -e -n "$couleur_jaune_gras"
sudo passwd pi
echo -e -n "$couleur_normal"

# Suppresion du programme de bienvenue: piwiz
echo "Suppresion du programme de bienvenue: piwiz"
if [ ! -f /etc/xdg/autostart/piwiz.desktop.sauv ]; then
	sudo mv /etc/xdg/autostart/piwiz.desktop /etc/xdg/autostart/piwiz.desktop.sauv
fi

# Configuration de la timezone
echo "Configuration de la timezone"
sudo rm /etc/localtime 2>/dev/null
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
sudo rm /etc/timezone 2>/dev/null/st

# Configuration de l'adresse IP 
echo "Configuration de l'adresse IP $ip"
# désactivation du service dhcp au démarrage
sudo systemctl stop service dhcpd.service
sudo systemctl disable service dhcpd.service
if [ ! -f /etc/network/interfaces.sauv ]; then
	sudo mv /etc/network/interfaces /etc/network/interfaces.sauv
fi
sudo touch /etc/network/interfaces
echo -e "$couleur_jaune_gras""Adresse IP du produit :""$couleur_normal"
read ip
echo -e "$couleur_jaune_gras""Adresse IP de la passerelle par defaut :""$couleur_normal"
read gateway
network=`echo $ip |sed "s/\(.*\).\(.*\).\(.*\)..*/\1/"`
network=`echo $network"0"`
sudo echo "# Configuration reseau" > /etc/network/interfaces
sudo echo "auto lo" >> /etc/network/interfaces
sudo echo "iface lo inet loopback" >> /etc/network/interfaces
sudo echo "" >> /etc/network/interfaces
sudo echo "auto eth0" >> /etc/network/interfaces
sudo echo "iface eth0 inet static" >> /etc/network/interfaces
sudo echo "address $ip" >> /etc/network/interfaces
sudo echo "netmask 255.255.255.0" >> /etc/network/interfaces
sudo echo "network $network" >> /etc/network/interfaces
sudo echo "gateway $gateway" >> /etc/network/interfaces
sudo systemctl disable dhcpcd >/dev/null 2>&1 
sudo systemctl enable networking >/dev/null 2>&1
sudo /etc/init.d/dhcpcd stop
sudo /etc/init.d/networking restart #>/dev/null

# Configuration de SSH
echo "Configuration de ssh port $ssh_port"
if [ ! -f /etc/ssh/sshd_config.sauv ]; then
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.sauv
fi
sudo sed -i "s/.*Port.*/Port $ssh_port/" /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart
sudo udapte-rc.d ssh defaults
sudo udapte-rc.d ssh enable
sudo systemctl enable ssh


# Installation de paquets
echo "Installation de paquets"
sudo apt-get update 
sudo apt-get install vim geditgedit numlockx locale-all

# Configuration du language du système
echo "Configuration du language du système"
sudo dpkg-reconfigure locales
sudo dpkg-reconfigure keyboard-configuration

# Configuration de l'activativation de la touche verrouillage num
echo "Configuration de l'activativation de la touche verrouillage num"
sudo mkdir /etc/anthony
sudo echo "/bin/bash" > /etc/anthony/numlockx.sh
sudo echo "numlockx on" > /etc/anthony/numlockx.sh
sudo chmod +x /etc/anthony/numlockx.sh
sudo echo "@reboot cd /etc/anthony && ./numlockx.sh" >> /var/spool/cron/crontabs/pi

# Configuration de git
echo "Configuration de git"
echo -e "$couleur_jaune_gras""Utilisateur git :""$couleur_normal"
read git_username
echo -e "$couleur_jaune_gras""Email utilisateur git :""$couleur_normal"
read git_email_username
git config --global user.name "$git_username"
git config --global user.email "$git_email_username"
git config --global core.editor "vim"


# Mise à jour du système
echo "Mise à jour du système"
echo -e "$couleur_jaune_gras""Voulez-vous mettre à jour le système ? (oui/non (par défaut))""$couleur_normal"
read mise_a_jour
if [ "$mise_a_jour" == "oui" ];then
	sudo apt-get update 
	sudo apt-get upgrade
fi

# Mise à jour du microcode
echo "Mise à jour du microcode"
echo -e "$couleur_jaune_gras""Voulez-vous mettre à jour le micro-code? (oui/non (par défaut))""$couleur_normal"
read mise_a_jour_microcode
if [ "$mise_a_jour_microcode" == "oui" ];then
	sudo rpi-update
fi

#sudo reboot
#cd ~Documents
#git clone https://github.com/aremandet/rpi_3_bp_domotic_sensor

#git config --global user.name anthony
#git config --global user.email aremandet@live.fr
#git config --global core.editor "vim"
