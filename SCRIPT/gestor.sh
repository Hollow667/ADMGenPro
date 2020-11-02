#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" [5]="\033[1;33m" )
barra="\033[0m\e[34m=========================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
fun_trans () { 
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=pt
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
 retorno="$(source trans -e google -b pt:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 if [[ $retorno = "" ]];then
 retorno="$(source trans -e bing -b pt:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 fi
 if [[ $retorno = "" ]];then 
 retorno="$(source trans -e yandex -b pt:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 fi
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}
update_pak () {
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -q > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get upgrade"
apt-get upgrade -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}
reiniciar_ser () {
echo -ne " \033[1;31m[ ! ] Services stunnel4 restart"
service stunnel4 restart > /dev/null 2>&1
[[ -e /etc/init.d/stunnel4 ]] && /etc/init.d/stunnel4 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid restart"
service squid restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid3 restart"
service squid3 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services apache2 restart"
service apache2 restart > /dev/null 2>&1
[[ -e /etc/init.d/apache2 ]] && /etc/init.d/apache2 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services openvpn restart"
service openvpn restart > /dev/null 2>&1
[[ -e /etc/init.d/openvpn ]] && /etc/init.d/openvpn restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services dropbear restart"
service dropbear restart > /dev/null 2>&1
[[ -e /etc/init.d/dropbear ]] && /etc/init.d/dropbear restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services ssh restart"
service ssh restart > /dev/null 2>&1
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services fail2ban restart"
( 
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart
fail2ban-client -x stop && fail2ban-client -x start
) > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}
reiniciar_vps () {
echo -ne " \033[1;31m[ ! ] Sudo Reboot"
sleep 3s
echo -e "\033[1;32m [OK]"
(
sudo reboot
) > /dev/null 2>&1
echo -e "$barra"
return
}
host_name () {
unset name
while [[ ${name} = "" ]]; do
echo -ne "\033[1;37m $(fun_trans "Digite un nombre de host"): 》" && read name
tput cuu1 && tput dl1
done
hostnamectl set-hostname $name 
if [ $(hostnamectl status | head -1  | awk '{print $3}') = "${name}" ]; then 
echo -e "\033[1;32m $(fun_trans "Nombre de host alterado corretamente")!, $(fun_trans "Reiniciar VPS")"
else
echo -e "\033[1;31m $(fun_trans "Nombre de host VPS no modificado")!"
fi
echo -e "$barra"
return
}
act_hora () {
echo -ne " \033[1;31m[ ! ] timedatectl"
timedatectl > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones"
timedatectl list-timezones > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones  | grep Santiago"
timedatectl list-timezones  | grep Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl set-timezone America/Santiago"
timedatectl set-timezone America/Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}
cambiopass () {
echo -e "${cor[5]} $(fun_trans "Esta herramienta cambia la contraseña de su servidor vps")"
echo -e "${cor[5]} $(fun_trans "Esta contraseña es utilizada como usuario") root"
echo -e "$barra"
echo -e "${cor[0]} $(fun_trans "Escriba su nueva contraseña")"
echo -e "$barra"
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
echo -e "$barra"
echo -e "${cor[0]} $(fun_trans "Contraseña cambiada con exito!")"
echo -e "${cor[0]} $(fun_trans "Su contraseña ahora es"): ${cor[2]}$pass\n${barra}"
return
}

UNLOCK () {
sudo apt-get install libpam-cracklib -y > /dev/null 2>&1
wget https://raw.githubusercontent.com/VPS-MX/VPS-MX-8.0/master/ArchivosUtilitarios/common-password -O /etc/pam.d/common-password > /dev/null 2>&1
    chmod +x /etc/pam.d/common-password
msg -bar2
echo -e "${cor[3]}Pass Alfanumerico Desactivado con EXITO"
#}
echo -e "${cor[3]}  Desactivar contraseñas Alfanumericas en VULTR"
echo -e "\033[1;36m Se podra usar cualquier pass de 6 digitos"
msg -bar2
read -p " [ s | n ]: " UNLOCK   
[[ "$UNLOCK" = "s" || "$UNLOCK" = "S" ]] && UNLOCK
msg -bar2
}

rootpass () {
echo -e "${cor[5]} $(fun_trans "Esta herramienta cambia a usuario root las vps de ")"
echo -e "${cor[5]} $(fun_trans "Googlecloud y Amazon esta configuracion solo")"
echo -e "${cor[5]} $(fun_trans "funcionan en Googlecloud y Amazon Puede causar")"
echo -e "${cor[5]} $(fun_trans "error en otras VPS agenas a Googlecloud y Amazon ")"
echo -e "$barra"
echo -e " $(fun_trans "Desea Seguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || exit 1
echo -e "$barra"
#Inicia Procedimentos
#Parametros iniciais
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
echo -e "${cor[5]} $(fun_trans "Esta contraseña sera utilizada como usuario") root"
echo -e "$barra"
echo -e "${cor[0]} $(fun_trans "Escriba su nueva contraseña")"
echo -e "$barra"
read  -p " Nueva Contraseña: 》" pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
echo -e "$barra"
echo -e "${cor[0]} $(fun_trans "Contraseña ha sido cambiada con exito!")"
echo -e "${cor[0]} $(fun_trans "Su Contraseña ahora es"): ${cor[2]}$pass\n${barra}"
echo -e "${cor[5]} $(fun_trans "Configuraciones agregadas")"
echo -e "${cor[5]} $(fun_trans "La vps esta totalmente configurada")"
echo -e "$barra"
service ssh restart > /dev/null 2>&1
return
}
gestor_fun () {
echo -e " ${cor[3]} $(fun_trans "Administrador VPS") ${cor[2]}[NEW-ADM-PLUS]"
echo -e "$barra"
while true; do
echo -e "${cor[2]} [1] ${cor[4]}> ${cor[3]}$(fun_trans "Actualizar Paquetes")"
echo -e "${cor[2]} [2] ${cor[4]}> ${cor[3]}$(fun_trans "Alterar Direccion IP del VPS")"
echo -e "${cor[2]} [3] ${cor[4]}> ${cor[3]}$(fun_trans "Reiniciar los Servicios")"
echo -e "${cor[2]} [4] ${cor[4]}> ${cor[3]}$(fun_trans "Reiniciar VPS")"
echo -e "${cor[2]} [5] ${cor[4]}> ${cor[3]}$(fun_trans "Cambiar Hora America-Santiago")"
echo -e "${cor[2]} [6] ${cor[4]}> ${cor[3]}$(fun_trans "Cambiar Contraseña ROOT del VPS")"
echo -e "${cor[2]} [7] ${cor[4]}> ${cor[3]}$(fun_trans "Permiso ROOT para Googlecloud y Amazon")"
echo -e "${cor[2]} [8] ${cor[4]}> ${cor[3]}$(fun_trans "LIBERAR VPS VULTR PARA CREAR USUARIOS")"
echo -e "${cor[2]} [0] > ${cor[0]}$(fun_trans "Regresar")\n${barra}"
while [[ ${opx} != @(0|[1-8]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite una Opción"): 》 \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	update_pak
	break;;
	2)
	host_name
	break;;
	3)
	reiniciar_ser
	break;;
	4)
	reiniciar_vps
	break;;
	5)
	act_hora
	break;;
        6)
	cambiopass
	break;;
        7)
	rootpass
	break;;
        8)
	UNLOCK
	break;;
        9)
	wget -O /bin/pan_cracklib.sh https://raw.githubusercontent.com/ThonyDroidYT/Herramientas/main/Unlock-Vultr.sh > /dev/null 2>&1; chmod +x /bin/Unlock-Vultr.sh; Unlock-Vultr.sh
	break;;
esac
done
}
gestor_fun
