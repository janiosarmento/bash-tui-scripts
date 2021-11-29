#!/usr/bin/env bash

#########
#
_SPINNER_VERSION="20211127.1937"
#
#############################################

# Manha para checar se uma variável foi setada:
# https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
#
# JSON de spinners:
# https://raw.githubusercontent.com/sindresorhus/cli-spinners/master/spinners.json

[ -z ${Color_Off+x} ] && source /scripts/lib/colors.sh > /dev/null 2>&1

# usage:
# (a_long_running_task) &
# spinner $! "message"
spinner() {
	local pid=$1
	local infotext=${2:-'Processando'}
	local tipo=${3:-'dots'}
	local -i i=0

	local arqJson='/scripts/lib/spinners.json'
	local tempFile
	local delay
	local -a spinstr
	local -i spinnerLength

	delay="$( jq -r ".${tipo}.interval" < ${arqJson} )"
	delay=$( bc -l <<< "${delay} / 1000" ) # Converte para segundos
	delay="${delay/0./.}" # Remove o zero inicial
	delay="${delay: 0: 3}" # Remove os zeros excessivos à direita

	tempFile=$(mktemp)
	jq -r ".${tipo}.frames[]" < ${arqJson} > "${tempFile}"
	readarray -t spinstr < "${tempFile}"
	rm -f "${tempFile}"
	spinnerLength=${#spinstr[@]}

	tput civis
	# shellcheck disable=SC2143
	while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
		local temp=${spinstr[${i}]}
		printf "  ${Cyan}${temp}${Color_Off} ${infotext} ${ClearEOL}\r"
		sleep "${delay}"
		((i++))
		((i == spinnerLength)) && i=0
	done
	printf "  ${Green}✔${Color_Off} ${infotext}${ClearEOL}\n"
	tput cnorm
}
