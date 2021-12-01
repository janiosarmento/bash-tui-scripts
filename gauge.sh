#!/usr/bin/env bash
# shellcheck disable=SC2154

#########
#
_GAUGE_VERSION="20211130.2321"
#
#############################################

source /scripts/lib/colors.sh
source /scripts/lib/strings.sh

gauge() {
	local Total=$1
	local Parcial=$2
	local Transcorrido=${3-none}
	local LarguraMax=100
	local Gauge=' '
	local nbsp=$'\u00A0'
	local Largura Temp width Porcento ladoEsquerdo inteiro fracao ladoDireito impressao
	local Estimado tempoRestante

	width=$(tput cols)

	if ((Total < Parcial)); then
		# Se o total for menor que o parcial, então troca os valores
		Temp=${Total} ; Total=${Parcial} ; Parcial=${Temp}
	fi

	Largura=$((width - 15))
	((Largura > LarguraMax)) && Largura=${LarguraMax}

	Porcento=$(echo "scale=13;100 * ${Parcial} / ${Total}" | bc ) # Percentual em forma de fracionário
	ladoEsquerdo=$(echo "scale=4;${Largura} * ${Porcento} / 100" | bc)
	ladoEsquerdo="0${ladoEsquerdo}000" # Adiciona zeros à esquerda e à direita para manter a largura exata
	inteiro=$( echo "${ladoEsquerdo}" | cut -d '.' -f 1 )
	inteiro=$( echo "${inteiro} * 1" | bc )
	fracao=$(  echo "${ladoEsquerdo}" | cut -d '.' -f 2 )
	fracao=$(  echo "scale=0; (${Porcento} - ${inteiro}) * 1000" | bc )
	fracao=${fracao%.*}
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

	Gauge="${Color_Off}$(printf "%3s" "${inteiro}")% ${Blue}${On_White}${impressao}$( repeatString "${nbsp}" "${ladoDireito}" )${Color_Off}"
	echo -ne "${Gauge}\r"

	if [[ "${Transcorrido}" != "none" ]]; then
		Estimado=$( echo "${Transcorrido} * 100 / ${Porcento}" | bc -l	)
		tempoRestante=$( echo "scale=0; ${Estimado} - ${Transcorrido}" | bc -l )
		Transcorrido=$(secs_to_human "${Transcorrido}")
		Estimado=$(secs_to_human "${Estimado}")
		tempoRestante=$(secs_to_human "${tempoRestante}")
		Gauge="     ${Yellow}Transcorrido: ${Color_Off} ${Transcorrido}"
		Gauge+="    ${Yellow}Estimado:${Color_Off} ${Estimado}"
		Gauge+="    ${Yellow}Restante:${Color_Off} ${tempoRestante}${Clear_EOL}"
		echo ""
		echo -ne "${Gauge}\r"
	fi
}
