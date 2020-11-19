#!/bin/bash
#19/12/2019
rm -rf /etc/adm
mkdir /etc/adm
mkdir /etc/adm/usuarios

declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
# FUN TRANS
fun_trans () { 
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=es
[[ $LINGUAGE = "es" ]] && echo "$@" && return
[[ ! -e /usr/bin/trans ]] && wget -O /usr/bin/trans https://www.dropbox.com/s/l6iqf5xjtjmpdx5/trans?dl=0 &> /dev/null
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
#ENGINES=(aspell google deepl bing spell hunspell apertium yandex)
#NUM="$(($RANDOM%${#ENGINES[@]}))"
retorno="$(source trans -e bing -b es:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}
tmpusr () {
time="$1"
timer=$(( $time * 60 ))
timer2="'$timer's"
echo "#!/bin/bash
sleep $timer2
kill"' $(ps -u '"$2 |awk '{print"' $1'"}') 1> /dev/null 2> /dev/null
userdel --force $2
rm -rf /tmp/$2
exit" > /tmp/$2
}
#Sistema de Puertos
puertos_ssh () {
msg -bar
echo -e "\033[1;36m $(fun_trans "PUERTOS ACTIVOS")"
msg -bar2
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
echo -e "\033[1;33m ➾ \e[1;31m $svcs :\033[1;33m ➢ \e[1;32m $porta   "
done
}
tmpusr2 () {
time="$1"
timer=$(( $time * 60 ))
timer2="'$timer's"
echo "#!/bin/bash
sleep $timer2
kill=$(dropb | grep "$2" | awk '{print $2}')
kill $kill
userdel --force $2
rm -rf /tmp/$2
exit" > /tmp/$2
}

echo -e "\033[1;96m $(fun_trans "CREAR USUARIO TEMPORAL POR") ($(fun_trans "Minutos")) [NEW-ADM-PLUS]\n\033[1;97m$(fun_trans "Los Usuarios que crees en esta sección se eliminaran\nautomaticamete pasando el tiempo designado")\033[0m"
msg -bar

echo -e "\033[1;91m[1]-\033[1;97mNombre del usuario: \033[0;37m"; read -p "Nombre: 》" name
if [[ -z $name ]]
then
echo "$(fun_trans "No a digitado el Nuevo Usuario")"
exit
fi
if cat /etc/passwd |grep $name: |grep -vi [a-z]$name |grep -v [0-9]$name > /dev/null
then
echo -e "\033[1;31mUsuario $name ya existe\033[0m"
exit
fi
echo -e "\033[1;91m[2]-\033[1;97m$(fun_trans "Contraseña para usuario") $name: \033[0;37m"; read -p "Contraseña: 》" pass
echo -e "\033[1;91m[3]-\033[1;97m$(fun_trans "Tiempo de Duración En Minutos"): \033[0;37m"; read -p "Duración: 》" tmp
if [ "$tmp" = "" ]; then
tmp="30"
echo -e "\033[1;32m$(fun_trans "Fue Definido 30 minutos Por Defecto")!\033[0m"
msg -bar
sleep 2s
fi
useradd -M -s /bin/false $name
(echo $pass; echo $pass)|passwd $name 2>/dev/null
touch /tmp/$name
tmpusr $tmp $name
chmod 777 /tmp/$name
touch /tmp/cmd
chmod 777 /tmp/cmd
echo "nohup /tmp/$name & >/dev/null" > /tmp/cmd
/tmp/cmd 2>/dev/null 1>/dev/null
rm -rf /tmp/cmd
touch /etc/adm/usuarios/$name
echo "senha: $pass" >> /etc/adm/usuarios/$name
echo "data: ($tmp)Minutos" >> /etc/adm/usuarios/$name
msg -bar2
echo -e "\033[1;93m$(fun_trans "USUARIO TEMPORAL POR") [$(fun_trans "MINUTOS")] $(fun_trans "CREADO CON ÉXITO")!! \033[0m"
msg -bar2
echo -e "\033[1;36m⇛ $(fun_trans "IP del Servidor"): \033[0m$(meu_ip) " 
echo -e "\033[1;36m⇛ $(fun_trans "Usuario"): \033[0m$name"
echo -e "\033[1;36m⇛ $(fun_trans "Contraseña"): \033[0m$pass"
echo -e "\033[1;36m⇛ $(fun_trans "Minutos de Duración"): \033[0m$tmp"
echo -e "\033[1;36m⇛ $(fun_trans "SSH Creado Con"): \033[0mNEW-ADM-PlUS"
puertos_ssh
msg -bar2
exit
fi
