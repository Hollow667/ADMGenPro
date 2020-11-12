#!/bin/bash
#10/10/2020
#Hecho By: @Thony_DroidYT

#fonts color
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[1;32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[1;34m\033[01m$1\033[0m"
}
cyan(){
    echo -e "\033[1;36m\033[01m$1\033[0m"
}
cian='\033[1;36m'
verde='\033[1;32m'
rojo='\033[1;31m'
sincor='\033[0m'

#copy from Qiushui Yibing ss scripts
if [[ -f /etc/redhat-release ]]; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
fi

function install_trojan(){
CHECK=$(grep SELINUX= /etc/selinux/config | grep -v "#")
if [ "$CHECK" == "SELINUX=enforcing" ]; then
    blue "======================================================================="
    red "Se detecta que SELinux está encendido，Para evitar que no se solicite un certificado，Primero reinicie el VPS，Ejecute este script nuevamente"
    blue "======================================================================="
    read -p "Ya sea para reiniciar ahora ? Por favor escribe [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
	    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
            setenforce 0
	    echo -e "Reiniciando VPS..."
	    reboot
	fi
    exit
fi
if [ "$CHECK" == "SELINUX=permissive" ]; then
    blue "======================================================================="
    red "SELinux se detecta como permisivo，Para evitar que no se solicite un certificado，Primero reinicie el VPS，Ejecute este script nuevamente"
    blue "======================================================================="
    read -p "Ya sea para reiniciar ahora ? Por favor escribe [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
	    sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
            setenforce 0
	    echo -e "Reiniciando VPS..."
	    reboot
	fi
    exit
fi
if [ "$release" == "centos" ]; then
    if  [ -n "$(grep ' 6\.' /etc/redhat-release)" ] ;then
    blue "================================="
    red "El sistema actual no es compatible"
    blue "================================="
    exit
    fi
    if  [ -n "$(grep ' 5\.' /etc/redhat-release)" ] ;then
    blue "================================="
    red "El sistema actual no es compatible"
    blue "================================="
    exit
    fi
    systemctl stop firewalld
    systemctl disable firewalld
    rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
elif [ "$release" == "ubuntu" ]; then
    if  [ -n "$(grep ' 14\.' /etc/os-release)" ] ;then
    blue "================================="
    red "El sistema actual no es compatible"
    blue "================================="
    exit
    fi
    if  [ -n "$(grep ' 12\.' /etc/os-release)" ] ;then
    blue "================================="
    red "El sistema actual no es compatible"
    blue "================================="
    exit
    fi
    systemctl stop ufw
    systemctl disable ufw
    apt-get update
fi
$systemPackage -y install  nginx wget unzip zip curl tar >/dev/null 2>&1
systemctl enable nginx.service
blue "================================================"
red "Ingrese el nombre de dominio vinculado a este VPS"
blue "================================================"
# read your_domain
read -p "Dominio: 》" your_domain
real_addr=`ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
local_addr=`curl ipv4.icanhazip.com`
if [ $real_addr == $local_addr ] ; then
	blue "============================================================================="
	cyan "   La resolución del nombre de dominio es normal, comience a instalar trojan"
	blue "============================================================================="
	sleep 1s
cat > /etc/nginx/nginx.conf <<-EOF
user  root;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    keepalive_timeout  120;
    client_max_body_size 20m;
    #gzip  on;
    server {
        listen       80;
        server_name  $your_domain;
        root /usr/share/nginx/html;
        index index.php index.html index.htm;
    }
}
EOF
	# Configurar estación de camuflaje
	rm -rf /usr/share/nginx/html/*
	cd /usr/share/nginx/html/
	wget https://github.com/V2RaySSR/Trojan/raw/master/web.zip
    	unzip web.zip
	systemctl restart nginx.service
	#Solicitar certificado https
	mkdir /usr/src/trojan-cert
	curl https://get.acme.sh | sh
	~/.acme.sh/acme.sh  --issue  -d $your_domain  --webroot /usr/share/nginx/html/
    	~/.acme.sh/acme.sh  --installcert  -d  $your_domain   \
        --key-file   /usr/src/trojan-cert/private.key \
        --fullchain-file /usr/src/trojan-cert/fullchain.cer \
        --reloadcmd  "systemctl force-reload  nginx.service"
	if test -s /usr/src/trojan-cert/fullchain.cer; then
        cd /usr/src
	#wget https://github.com/trojan-gfw/trojan/releases/download/v1.13.0/trojan-1.13.0-linux-amd64.tar.xz
	wget https://github.com/trojan-gfw/trojan/releases/download/v1.14.0/trojan-1.14.0-linux-amd64.tar.xz
	tar xf trojan-1.*
	#Descargar cliente trojan
	wget https://github.com/atrandys/trojan/raw/master/trojan-cli.zip
	unzip trojan-cli.zip
	cp /usr/src/trojan-cert/fullchain.cer /usr/src/trojan-cli/fullchain.cer
	trojan_passwd=$(cat /dev/urandom | head -1 | md5sum | head -c 8)
	cat > /usr/src/trojan-cli/config.json <<-EOF
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "$your_domain",
    "remote_port": 443,
    "password": [
        "$trojan_passwd"
    ],
    "log_level": 1,
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "fullchain.cer",
        "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
	"sni": "",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "curves": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "fast_open": false,
        "fast_open_qlen": 20
    }
}
EOF
	rm -rf /usr/src/trojan/server.conf
	cat > /usr/src/trojan/server.conf <<-EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$trojan_passwd"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "/usr/src/trojan-cert/fullchain.cer",
        "key": "/usr/src/trojan-cert/private.key",
        "key_password": "",
        "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
	"prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": ""
    }
}
EOF
	cd /usr/src/trojan-cli/
	zip -q -r trojan-cli.zip /usr/src/trojan-cli/
	trojan_path=$(cat /dev/urandom | head -1 | md5sum | head -c 16)
	mkdir /usr/share/nginx/html/${trojan_path}
	mv /usr/src/trojan-cli/trojan-cli.zip /usr/share/nginx/html/${trojan_path}/
	#Añadir script de inicio
	
cat > ${systempwd}trojan.service <<-EOF
[Unit]  
Description=trojan  
After=network.target  
   
[Service]  
Type=simple  
PIDFile=/usr/src/trojan/trojan/trojan.pid
ExecStart=/usr/src/trojan/trojan -c "/usr/src/trojan/server.conf"  
ExecReload=  
ExecStop=/usr/src/trojan/trojan  
PrivateTmp=true  
   
[Install]  
WantedBy=multi-user.target
EOF

	chmod +x ${systempwd}trojan.service
	systemctl start trojan.service
	systemctl enable trojan.service
	blue "=================================================================================================================="
	cyan "Trojan ha sido instalado，Utilice el enlace a continuación para descargar el cliente trojan，Este cliente ha configurado todos los parámetros"
	cyan "1、Copia el enlace de abajo，Abrir en el navegador，Descargar aplicacion"
	yellow "http://${your_domain}/$trojan_path/trojan-cli.zip"
	cyan "Registre la siguiente URL de la regla"
	yellow "http://${your_domain}/trojan.txt"
	cyan "2、Descomprime el paquete comprimido descargado, Abrir Carpeta，Abrir start.bat para abrir y ejecutar el cliente trojan"
	cyan "3、Abrir stop.bat para cerrar el cliente troyano"
	cyan "4、El cliente trojan debe utilizarse con complementos del navegador, como switchyomega, etc."
	cyan "Acceso  https://www.v2rayssr.com/trojan-1.html ‎ Descargar complementos y tutoriales del navegador"
	blue "=================================================================================================================="
	else
        blue "========================================================================"
	cyan "Sin resultados de solicitud de certificado https，Esta instalación falló"
	blue "========================================================================"
	fi
	
else
	blue "========================================================================================="
	cyan "La dirección de resolución del nombre de dominio no coincide con la dirección IP del VPS"
	cyan "Esta instalación falló，Asegúrese de que la resolución del nombre de dominio sea normal"
	blue "========================================================================================="
fi
}

function remove_trojan(){
    blue "=================================================="
    cyan "A punto de desinstalar trojan"
    cyan "Al mismo tiempo, se desinstalara nginx instalado"
    blue "=================================================="
    systemctl stop trojan
    systemctl disable trojan
    rm -f ${systempwd}trojan.service
    if [ "$release" == "centos" ]; then
        yum remove -y nginx
    else
        apt autoremove -y nginx
    fi
    rm -rf /usr/src/trojan*
    rm -rf /usr/share/nginx/html/*
    blue "==============="
    red "Trojan eliminado"
    blue "==============="
}

function bbr_boost_sh(){
    bash <(curl -L -s -k "https://raw.githubusercontent.com/ThonyDroidYT/Herramientas/main/tcpbr.sh")
  # bash <(curl -L -s -k "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh")
}

start_menu(){
    clear
   #blue " ======================================="
    blue " ========================================================="
    cyan "               Trojan Server \033[1;32m [NEW-ADM-PLUS]             "
    blue " ========================================================="
   #cyan " Secuencia de comandos automática de instalación de claves Trojan"
    red " Sistema：\033[1;36mCentos7+/Debian9+/Ubuntu16.04+"
    red " Hecho Por：\033[1;36m@Thony_DroidYT "
   #cyan " Sitio Web：www.v2rayssr.com（Prohibido el acceso doméstico)"
    red " Sitio Web：\033[1;36mhttps://bit.ly/thonyblog"
   #cyan " Integración de  aceleración BBRPLUS "
    red " YouTube：\033[1;32mTHONYDROID 2.0"
   #blue " ========================================================="
   #echo
    blue " ========================================================="
    green " [1] \033[1;31m> \033[1;36mInstalar Server Trojan"
    blue " ========================================================="
    green " [2] \033[1;31m> \033[1;36mInstalar Panel Web Trojan"
    blue " ========================================================="
    green " [3] \033[1;31m> \033[1;36mBBRPLUS 4 En 1 Aceleración VPS"
    blue " ========================================================="
    green " [4] \033[1;31m> \033[1;36mDesinstalación de claves Trojan"
    blue " ========================================================="
    green " [0] \033[1;31m> \033[1;36mSalir del Script"
    blue " ========================================================="
    echo
    read -p "Escoja Una Opción [0-3]: 》" num
    case "$num" in
    1)
    install_trojan
    ;;
    2)
    apt-get install curl -y
    clear
    bash <(curl -Ls https://raw.githubusercontent.com/ThonyDroidYT/Herramientas/main/TJWeb.sh)
    ;;
    3)
    bbr_boost_sh 
    ;;
    4)
    remove_trojan
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    red "Ingrese el número correcto"
    sleep 1s
    start_menu
    ;;
    esac
}
start_menu
