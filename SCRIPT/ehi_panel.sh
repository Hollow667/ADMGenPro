#!/bin/bash
ve="\033[1;32m";am="\033[1;33m";ver="\033[1;31m";az="\033[1;36m";f="\033[0m"
barra="\033[0m\e[34m======================================================\033[1;37m"

mkdir /etc/adm-lite > /dev/null 2>&1
link_bin="https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/blob/master/Install/painel.zip"
[[ ! -e /etc/adm-lite/painel.zip ]] && wget -O /etc/adm-lite/painel.zip ${link_bin} > /dev/null 2>&1 && chmod +x /etc/adm-lite/painel.zip
link_bin="https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/blob/master/Install/dados.zip"
[[ ! -e /etc/adm-lite/dados.zip ]] && wget -O /etc/adm-lite/dados.zip ${link_bin} > /dev/null 2>&1 && chmod +x /etc/adm-lite/dados.zip
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

meu_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && ip="$MEU_IP2" || ip="$MEU_IP"
}

echo -e " \033[1;32m $(fun_trans "PAINEL DE UPLOAD DE EHI") [NEW-ADM-PLUS]"
echo -e "$barra"
echo -e " \033[1;33m $(fun_trans "Esta Herramienta crea un painel no qual você deve ")"
echo -e " \033[1;33m $(fun_trans "fazer upload de servidores para download de outros usuários.")"
echo -e "$barra"
apt-get install figlet -y > /dev/null 2>&1
apt-get install cowsay -y > /dev/null 2>&1
meu_ip
echo -e "${az}"
figlet ADM-Ultimate-Plus | lolcat
echo -e "${f}"
sleep 2
echo
echo -e "${ver}            +++++ $(fun_trans "ATENCIÓN") +++++${am}     
$(fun_trans "TODAS AS SENHA A SEGUIR COLOQUE SEMPRE LA MISMA")${f}"
read -p "$(fun_trans "Enter, Para Prosseguir")!"
apt-get install php5 libapache2-mod-php5 php5-mcrypt -y
apt-get install mysql-server php5-mysql -y
mysql_install_db
echo ""
echo -e "${am}$(fun_trans "Sempre que solicitado")${ver}[Y/N]${am}$(fun_trans "escolha a opÃ§Ã£o")${ver}Y${am} e de ${ve}OK.${am} $(fun_trans "para tudo que pedir").
...
${am}O $(fun_trans "proximo procedimento de instalaÃ§ao vai te pedir uma senha")
$(fun_trans "ai vcs digita a senha que digitou antes e reconfirma ela ai depois do ir apertando") ${ver}Y${f}"
read -p "$(fun_trans "Enter, Para Prosseguir")!"
mysql_secure_installation
echo -e "${az}$(fun_trans "ESPERE LA INSTALACIÓN")${f}"
sleep 2
apt-get install phpmyadmin -y
php5enmod mcrypt
service apache2 restart
echo ""
stty -echo
tput setaf 7 ; tput bold ; read -p "$(fun_trans "Digita la misma contraseña") (MySQL Password): " var7 ; tput sgr0
echo ""
stty echo ; echo
mysql -h localhost -u root -p$var7 -e "$(fun_trans "CREATE DATABASE adm")"
echo -e "${ver}$(fun_trans "ATENÃ‡ÃƒO - LOGIN ASEGUIR ES PERSONAL NO COMPARTAS") ${f}"
echo ""
echo -e "${am}$(fun_trans "Agora vamos colocar um LOGIN e SENHA de acesso a pagina de upload")${ve}"
	read -p "Login: " var2
	read -p "Senha: " var3
	echo -ne "${f}"

cd /var/www/
   rm -rf index.html > /dev/null 2>&1
   cp /etc/adm-lite/painel.zip /var/www/
   unzip painel.zip > /dev/null 2>&1
   rm -rf painel.zip > /dev/null 2>&1
   chmod -R 777 /var/www/adm > /dev/null 2>&1
sed -i "s;123;$var7;g" /var/www/adm/system/seguranca.php > /dev/null 2>&1

cd /var/www/html/
   rm -rf index.html > /dev/null 2>&1
   cp /etc/adm-lite/painel.zip /var/www/html/
   unzip painel.zip > /dev/null 2>&1
   rm -rf painel.zip > /dev/null 2>&1 
   chmod -R 777 /var/www/html/adm > /dev/null 2>&1
sed -i "s;123;$var7;g" /var/www/html/adm/system/seguranca.php > /dev/null 2>&1

[[ ! -d /var/www/temp ]] && mkdir /var/www/temp
cd /var/www/temp && cp /etc/adm-lite/dados.zip /var/www/temp/
unzip dados.zip > /dev/null 2>&1

sed -i "s;adm123;$var2;g" ./banco_de_dados.sql > /dev/null 2>&1
sed -i "s;adm4321;$var3;g" ./banco_de_dados.sql > /dev/null 2>&1

mysql -h localhost -u root -p$var7 adm < banco_de_dados.sql > /dev/null 2>&1
rm -rf /var/www/temp

echo -e "${am}$(fun_trans "PAINEL DE UPLOAD DE EHI INSTALADO PARA ENTRAR NO SEU PAINEL ACESSE")
${az}-------------------------------------------------------------------
${ver}Url: ${ve}$ip:81/login.php
${am}Login: ${ve}$var2
${am}Senha: ${ve}$var3
${am}LINK PAGINA INICIAL ${ve}( $ip:81 )
${az}-------------------------------------------------------------------${f}"
echo -e "${am}"
read -p "$(fun_trans "Aperte ENTER, Para continuar")" naoa
sleep 2
echo -e "${f}"
exit
rm -rf /etc/adm-lite > /dev/null 2>&1
