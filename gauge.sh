#!/usr/bin/env bash
# shellcheck disable=SC2154

#########
#
_GAUGE_VERSION="20211128.2048"
#
#############################################

if [ -z ${Color_Off+x} ]; then
	# Se a variável não foi setada, então:
	. /scripts/lib/colors.sh
fi

gauge() {
	local Total=$1
	local Parcial=$2
	local Largura
	local LarguraMax=100
	local Temp
	local Gauge=' '
	local width
	local nbsp=$'\u00A0'

	width=$(tput cols)

	if ((Total < Parcial)); then
		# Se o total for menor que o parcial, então troca os valores
		Temp=${Total} ; Total=${Parcial} ; Parcial=${Temp}
	fi

	Largura=$((width - 15))
	((Largura > LarguraMax)) && Largura=${LarguraMax}

	Porcento=$(echo "scale=3;100 * ${Parcial} / ${Total}" | bc ) # Percentual em forma de fracionário
	ladoEsquerdo=$(echo "scale=2;${Largura} * ${Porcento} / 100" | bc)
	ladoEsquerdo="0${ladoEsquerdo}000"
	inteiro=$( echo "${ladoEsquerdo}" | cut -d '.' -f 1 )
	inteiro=$( echo "${inteiro} * 1" | bc )
	fracao=$(  echo "${ladoEsquerdo}" | cut -d '.' -f 2 )
	fracao=$(  echo "scale=0;${fracao} / 100" | bc )
	ladoDireito=$(( Largura - inteiro - 1))

	impressao="$( repeatString "█" "${inteiro}" )"
	if (( fracao > 800)); then
		impressao+="▊"
	elif (( fracao > 675)); then
		impressao+="▋"
	elif (( fracao > 500)); then
		impressao+="▌"
	elif (( fracao > 375)); then
		impressao+="▍"
	elif (( fracao > 250)); then
		impressao+="▎"
	elif (( fracao > 125)); then
		impressao+="▏"
	fi
	Porcento=$(printf "%3s" "${inteiro}")

	Gauge="${Color_Off}${Porcento}% ${Blue}${On_White}${impressao}$( repeatString "${nbsp}" "${ladoDireito}" )${Color_Off}"
	echo -ne "${Gauge}\r"
}
