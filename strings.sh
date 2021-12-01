#!/usr/bin/env bash

#########
#
_STRINGS_VERSION="20211130.2319"
#
#############################################

# dehumanise: converts a "humanised" string into a number
dehumanise() {
	local v

	for v in "${@:-$(</dev/stdin)}"; do
		echo "$v" | awk \
			'BEGIN{IGNORECASE = 1}
			function printpower(n,b,p) {printf "%u\n", n*b^p; next}
			/[0-9]$/{print $1;next};
			/K(iB)?$/{printpower($1,  2, 10)};
			/M(iB)?$/{printpower($1,  2, 20)};
			/G(iB)?$/{printpower($1,  2, 30)};
			/T(iB)?$/{printpower($1,  2, 40)};
			/KB$/{    printpower($1, 10,  3)};
			/MB$/{    printpower($1, 10,  6)};
			/GB$/{    printpower($1, 10,  9)};
			/TB$/{    printpower($1, 10, 12)}'
	done
}

# outputs a random emoji
echo_emoji() {
	emojis=("😀" "😎" "👍" "🍺" "🎉")
	echo "${emojis[$((RANDOM % ${#emojis[@]}))]}"
}

# true(0)|false(1)    endsWith ( fileName, expression )
# Returns whether or not the {fileName} ends with the {expression}
endsWith() {
	grep -q "$2""$" <<<"$1"
}

# emptyString|extension    getFileExtension ( fileName )
# return the extension of the {fileName} string, or an empty string if there is none
getFileExtension() {
	if grep -q '\.' <<<"$1"; then
		echo "${1##*.}"
	else
		echo ""
	fi
}

isEmptyString() {
	local -r string="${1}"

	[[ "$(trimString "${string}")" = '' ]] && return 0
	return 1
}

isValidIP() {
	local ip=$1
	local stat=1

	if [[ "${ip}" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
		stat=0
	fi
	return ${stat}
}

randomInteger() {
	shuf -i "$1"-"$2" | head -1
}

randomPassword() {
	# default value for $SIZE: $1 or 25
	local SIZE=${1:-25}
	tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w "${SIZE}" | head -n 1
}

randomString() {
	randomPassword "${@}"
}

removeEmptyLines() {
	local -r content="${1}"

	echo -e "${content}" | sed '/^\s*$/d'
}

repeatString() {
	local -r string="${1}"
	local -r numberToRepeat="${2}"

	if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]; then
		local -r result="$(printf "%${numberToRepeat}s")"
		echo -e "${result// /${string}}"
	fi
}

# replacedString    replace ( what, byWhat, sourceString )
# note: % symbol are not replaced, unless prefixed with a slash (\%)
replace() {
	echo "${3/$1/$2}"
}

secs_to_human() {
	T=$1
	T=${T%.*}
	D=$((T / 60 / 60 / 24))
	H=$((T / 60 / 60 % 24))
	M=$((T / 60 % 60))
	S=$((T % 60))

	if [[ ${D} != 0 ]]; then
		printf '%dd %02d:%02d:%02d' $D $H $M $S
	else
		printf '%02d:%02d:%02d' $H $M $S
	fi

}
# number    strlen ( string )
# Returns the length of {string}
strlen() {
	echo ${#1}
}

# string    substr ( string, offset )
# string    substr ( string, offset, length )
# Returns the substring of {string} starting from index {offset} (first char is at 0).
# If length is not given, the substring will end at the end of the string
# If length is given, the substring will end when {length} characters are consumed.
# {offset} can be negative.
substr() {
	if [ -n "$3" ]; then
		echo "${1:$2:$3}"
	else
		echo "${1:$2}"
	fi
}

# converts a string to lowercase
toLower() {
	echo "${1,,}"
}

# converts a string to uppercase
toUpper() {
	echo "${1^^}"
}

trimString() {
	local -r string="${1}"

	# shellcheck disable=SC2001
	sed 's,^[[:blank:]]*,,' <<<"${string}" | sed 's,[[:blank:]]*$,,'
}
