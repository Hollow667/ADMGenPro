#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}error：${plain} Este script debe ejecutarse como usuario root！\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}No se detectó una versión del sistema, comuníquese con el autor del script！${plain}\n" && exit 1
fi

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ] ; then
    echo "Este software no es compatible con sistemas de 32 bits.(x86)，Utilice un sistema de 64 bits(x86_64)，Si la detección es incorrecta，Por favor contacte al autor"
    exit -1
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}por favor use CentOS 7 O un sistema superior！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}por favor use Ubuntu 16 O un sistema superior！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}por favor use Debian 8 O un sistema superior！${plain}\n" && exit 1
    fi
fi

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [默认$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install wget curl tar unzip -y
    else
        apt install wget curl tar unzip -y
    fi
}

uninstall_old_v2ray() {
    if [[ -f /usr/bin/v2ray/v2ray ]]; then
        confirm "Se detectó una versión anterior v2ray，Ya sea para desinstalar，Será borrado /usr/bin/v2ray/ 与 /etc/systemd/system/v2ray.service" "Y"
        if [[ $? != 0 ]]; then
            echo "No se puede instalar v2-ui sin desinstalar v2-ui"
            exit 1
        fi
        echo -e "${green}Desinstalar la versión anterior v2ray${plain}"
        systemctl stop v2ray
        rm /usr/bin/v2ray/ -rf
        rm /etc/systemd/system/v2ray.service -f
        systemctl daemon-reload
    fi
    if [[ -f /usr/local/bin/v2ray ]]; then
        confirm "Se detecta V2ray instalado de otras formas，Ya sea para desinstalar，v2-ui Viene con kernel oficial v2ray，Para evitar conflictos con su puerto，Recomendado para desinstalar" "Y"
        if [[ $? != 0 ]]; then
            echo -e "${red}Elegiste no desinstalar，Asegúrese de que usted mismo instale otros scripts v2ray versus v2-ui ${green}El kernel oficial v2ray que viene con él${red}Sin conflicto de puertos${plain}"
        else
            echo -e "${green}Comience a desinstalar otras instalaciones v2ray${plain}"
            systemctl stop v2ray
            bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
            systemctl daemon-reload
        fi
    fi
}

install_v2ray() {
    uninstall_old_v2ray
    echo -e "${green}Comience a instalar o actualizar v2ray${plain}"
    bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
    if [[ $? -ne 0 ]]; then
        echo -e "${red}Error de instalación o actualización v2ray，Comprueba el mensaje de error.${plain}"
        echo -e "${yellow}La mayoría de las razones pueden deberse a la imposibilidad de descargar el paquete de instalación de v2ray en el área donde se encuentra su servidor actual. Esto es más común en máquinas domésticas. La solución es instalar manualmente v2ray. Por la razón específica, consulte el mensaje de error anterior.${plain}"
        exit 1
    fi
    echo "
[Unit]
Description=V2Ray Service
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
Environment=V2RAY_LOCATION_ASSET=/usr/local/share/v2ray/
ExecStart=/usr/local/bin/v2ray -confdir /usr/local/etc/v2ray/
Restart=on-failure

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/v2ray.service
    if [[ ! -f /usr/local/etc/v2ray/00_log.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/00_log.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/01_api.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/01_api.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/02_dns.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/02_dns.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/03_routing.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/03_routing.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/04_policy.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/04_policy.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/05_inbounds.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/05_inbounds.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/06_outbounds.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/06_outbounds.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/07_transport.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/07_transport.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/08_stats.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/08_stats.json
    fi
    if [[ ! -f /usr/local/etc/v2ray/09_reverse.json ]]; then
        echo "{}" > /usr/local/etc/v2ray/09_reverse.json
    fi
    systemctl daemon-reload
    systemctl enable v2ray
    systemctl start v2ray
}

close_firewall() {
    if [[ x"${release}" == x"centos" ]]; then
        systemctl stop firewalld
        systemctl disable firewalld
    elif [[ x"${release}" == x"ubuntu" ]]; then
        ufw disable
#    elif [[ x"${release}" == x"debian" ]]; then
#        iptables -P INPUT ACCEPT
#        iptables -P OUTPUT ACCEPT
#        iptables -P FORWARD ACCEPT
#        iptables -F
    fi
}

install_v2-ui() {
    systemctl stop v2-ui
    cd /usr/local/
    if [[ -e /usr/local/v2-ui/ ]]; then
        rm /usr/local/v2-ui/ -rf
    fi

    if  [ $# == 0 ] ;then
        last_version=$(curl -Ls "https://api.github.com/repos/sprov065/v2-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}No se pudo detectar la versión de v2-ui，Puede estar más allá del límite de la API de Github，Por favor, inténtelo de nuevo más tarde，O especifique manualmente la versión v2-ui para instalar${plain}"
            exit 1
        fi
        echo -e "Se detectó la última versión de v2-ui：${last_version}，iniciar la instalación"
        wget -N --no-check-certificate -O /usr/local/v2-ui-linux.tar.gz https://github.com/sprov065/v2-ui/releases/download/${last_version}/v2-ui-linux.tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Error al descargar v2-ui，Asegúrese de que su servidor pueda descargar archivos Github${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/sprov065/v2-ui/releases/download/${last_version}/v2-ui-linux.tar.gz"
        echo -e "iniciar la instalación v2-ui v$1"
        wget -N --no-check-certificate -O /usr/local/v2-ui-linux.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}descargar v2-ui v$1 fracaso，Asegúrese de que esta versión exista${plain}"
            exit 1
        fi
    fi

    tar zxvf v2-ui-linux.tar.gz
    rm v2-ui-linux.tar.gz -f
    cd v2-ui
    chmod +x v2-ui bin/v2ray-v2-ui bin/v2ctl
    cp -f v2-ui.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable v2-ui
    systemctl start v2-ui
    echo -e "${green}v2-ui v${last_version}${plain} La instalación se ha completado，El panel está activado，"
    echo -e ""
    echo -e "Si es una instalación nueva，El puerto web predeterminado es ${green}65432${plain}，El nombre de usuario y la contraseña son ambos predeterminados ${green}admin${plain}"
    echo -e "Asegúrese de que este puerto no esté ocupado por otros programas，${yellow}Y asegúrate que El puerto 65432 ha sido liberado${plain}"
    echo -e "Si quieres Modificar 65432 a otros puertos，Ingresar comando v2-ui para modificar，También asegúrese de que el puerto que modifica también esté permitido"
    echo -e ""
    echo -e "Si es para actualizar el panel，acceda al panel como lo hizo antes"
    echo -e ""
    curl -o /usr/bin/v2-ui -Ls https://raw.githubusercontent.com/sprov065/v2-ui/master/v2-ui.sh
    chmod +x /usr/bin/v2-ui
    echo -e "v2-ui Cómo usar scripts de administración: "
    echo -e "Lista de comandos Panel v2ray: "
    echo -e "----------------------------------------------"
    echo -e "v2-ui              - Mostrar menú de gestión (Más funciones)"
    echo -e "v2-ui start        - Poner en marcha panel v2-ui"
    echo -e "v2-ui stop         - Detener panel v2-ui"
    echo -e "v2-ui restart      - Reiniciar panel v2-ui"
    echo -e "v2-ui status       - Ver estado v2-ui"
    echo -e "v2-ui enable       - Preparar Autoinicio de v2-ui"
    echo -e "v2-ui disable      - Cancelar Autoinicio de v2-ui"
    echo -e "v2-ui log          - Ver Registro de v2-ui"
    echo -e "v2-ui update       - Actualizar Panel v2-ui"
    echo -e "v2-ui install      - Instalar Panel v2-ui"
    echo -e "v2-ui uninstall    - Desinstalar Panel v2-ui"
    echo -e "----------------------------------------------"
}

echo -e "${green}iniciando la instalación${plain}"
install_base
uninstall_old_v2ray
close_firewall
install_v2-ui $1
