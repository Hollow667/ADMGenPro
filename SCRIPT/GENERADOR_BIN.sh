#!/bin/bash
# Bin _ Gen #OFC
link_bin="https://raw.githubusercontent.com/ThonyDroidYT/ADM-Ultimate-Plus/master/Install/ADM-CCGen+.py"
[[ ! -e /usr/bin/ADM-CCGen+.py ]] && wget -O /usr/bin/ADM-CCGen+.py ${link_bin} > &>/dev/null && chmod +x /usr/bin/ADM-CCGen+.py
msg -ama "$(fun_trans "GERADOR DE BINS ADM+ OFICIAL")"
msg -bar
msg -ne "$(fun_trans "Digite un bin"): 》" && read UsrBin
while [[ ${#UsrBin} -lt 16 ]]; do
UsrBin+="x"
done
msg -ne "$(fun_trans "Cuantos Bins Quieres Generar"): 》" && read GerBin
[[ $GerBin != +([0-9]) ]] && GerBin=10
[[ -z $GerBin ]] && GerBin=10
msg -bar
python /usr/bin/ADM-CCGen+.py -b ${UsrBin} -u ${GerBin} -d -c
msg -bar
