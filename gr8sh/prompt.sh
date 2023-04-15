#!/bin/bash

##
##
##  =======================
##  WARNING!!
##  DO NOT EDIT THIS FILE!!
##  =======================
##
##  This file was generated by an installation script.
##  It might be overwritten without warning at any time
##  and you will lose all your changes.
##
##  Visit for instructions and more information:
##  https://github.com/andresgongora/synth-shell/
##
##



#!/bin/bash
##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2020, Andres Gongora <mail@andresgongora.com>.     |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+
##
##	DESCRIPTION
##	===========
##
##	Script to colorize terminal text.
##	It works in either of two ways, either by providing the formatting
##	sequences that should be added to the text, or by directly wrapping
##	the text with the desired control sequences
##
##
##
##
##
##	USAGE
##	=====
##
##	Formating a text directly:
##		FORMATTED_TEXT=$(formatText "Hi!" -c red -b 13 -e bold)
##		echo -e "$FORMATTED_TEXT"
##
##	Getting the control sequences:
##		FORMAT=$(getFormatCode -c blue -b yellow -e bold -e blink)
##		NONE=$(getFormatCode -e none)
##		echo -e $FORMAT"Hello"$NONE
##
##	Options (More than one code may be specified)
##	-c	color name or 256bit code for font face
##	-b	background color name or 256bit code
##	-e	effect name (e.g. bold, blink, etc.)
##
##
##
##
##
##	BASH TEXT FORMATING
##	===================
##
##	Colors and text formatting can be achieved by preceding the text
##	with an escape sequence. An escape sequence starts with an <ESC>
##	character (commonly \e[), followed by one or more formatting codes
##	(its possible) to apply more that one color/effect at a time),
##	and finished by a lower case m. For example, the formatting code 1
##	tells the terminal to print the text bold face. This is acchieved as:
##		\e[1m Hello World!
##
##	But if nothing else is specified, then eveything that may be printed
##	after 'Hello world!' will be bold face as well. The code 0 is thus
##	meant to remove all formating from the text and return to normal:
##		\e[1m Hello World! \e[0m
##
##	It's also possible to paint the text in color (codes 30 to 37 and
##	codes 90 to 97), or its background (codes 40 to 47 and 100 to 107).
##	Red has code 31:
##		\e[31m Hello World! \e[0m
##
##	More than one code can be applied at a time. Codes are separated by
##	semicolons. For example, code 31 paints the text in red. Thus,
##	the following would print in red bold face:
##		\e[1;31m Hello World! \e[0m
##
##	Some formatting sequences are, in fact, comprised of two codes
##	that must go together. For example, the code 38;5; tells the terminal
##	that the next code (after the semicolon) should be interpreted as
##	a 256 bit formatting color. So, for example, the code 82 is a light
##	green. We can paint the text using this code as follows, plus bold
##	face as follows - but notice that not all terminal support 256 colors:##
##		\e[1;38;5;82m Hello World! \e[0m
##
##	For a detailed list of all codes, this site has an excellent guide:
##	https://misc.flogisoft.com/bash/tip_colors_and_formatting
##
##
##
##
##
##	TODO: When requesting an 8 bit colorcode, detect if terminal supports
##	256 bits, and return appropriate code instead
##
##	TODO: Improve this description/manual text
##
##	TODO: Currently, if only one parameter is passed, its treated as a
##	color. Addsupport to also detect whether its an effect code.
##		Now: getFormatCode blue == getFormatCode -c blue
##		Add: getFormatCode bold == getFormatCode -e bold
##
##	TODO: Clean up this script. Prevent functions like "get8bitCode()"
##	to be accessible from outside. These are only a "helper" function
##	that should only be available to this script
##
##==============================================================================
##	CODE PARSERS
##==============================================================================
##------------------------------------------------------------------------------
##
get8bitCode()
{
	CODE=$1
	case $CODE in
		default)
			echo 9
			;;
		none)
			echo 9
			;;
		black)
			echo 0
			;;
		red)
			echo 1
			;;
		green)
			echo 2
			;;
		yellow)
			echo 3
			;;
		blue)
			echo 4
			;;
		magenta|purple|pink)
			echo 5
			;;
		cyan)
			echo 6
			;;
		light-gray)
			echo 7
			;;
		dark-gray)
			echo 60
			;;
		light-red)
			echo 61
			;;
		light-green)
			echo 62
			;;
		light-yellow)
			echo 63
			;;
		light-blue)
			echo 64
			;;
		light-magenta|light-purple)
			echo 65
			;;
		light-cyan)
			echo 66
			;;
		white)
			echo 67
			;;
		*)
			echo 0
	esac
}
##------------------------------------------------------------------------------
##
getColorCode()
{
	COLOR=$1
	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "38;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 30))
		echo $COLORCODE
	fi
}
##------------------------------------------------------------------------------
##
getBackgroundCode()
{
	COLOR=$1
	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "48;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 40))
		echo $COLORCODE
	fi
}
##------------------------------------------------------------------------------
##
getEffectCode()
{
	EFFECT=$1
	NONE=0
	case $EFFECT in
	none)
		echo $NONE
		;;
	default)
		echo $NONE
		;;
	bold)
		echo 1
		;;
	bright)
		echo 1
		;;
	dim)
		echo 2
		;;
	underline)
		echo 4
		;;
	blink)
		echo 5
		;;
	reverse)
		echo 7
		;;
	hidden)
		echo 8
		;;
	strikeout)
		echo 9
		;;
	*)
		echo $NONE
	esac
}
##------------------------------------------------------------------------------
##
getFormattingSequence()
{
	START='\e[0;'
	MIDLE=$1
	END='m'
	echo -n "$START$MIDLE$END"
}
##==============================================================================
##	AUX
##==============================================================================
applyCodeToText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	TEXT=$1
	CODE=$2
	echo -n "$CODE$TEXT$RESET"
}
##==============================================================================
##	MAIN FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##
getFormatCode()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "$RESET"
	## 1 ARGUMENT -> ASSUME TEXT COLOR
	elif [ "$#" -eq 1 ]; then
		TEXT_COLOR=$(getFormattingSequence $(getColorCode $1))
		echo -n "$TEXT_COLOR"
	## ARGUMENTS PROVIDED
	else
		FORMAT=""
		while [ "$1" != "" ]; do
			## PROCESS ARGUMENTS
			TYPE=$1
			ARGUMENT=$2
			case $TYPE in
			-c)
				CODE=$(getColorCode $ARGUMENT)
				;;
			-b)
				CODE=$(getBackgroundCode $ARGUMENT)
				;;
			-e)
				CODE=$(getEffectCode $ARGUMENT)
				;;
			*)
				CODE=""
			esac
			## ADD CODE SEPARATOR IF NEEDED
			if [ "$FORMAT" != "" ]; then
				FORMAT="$FORMAT;"
			fi
			## APPEND CODE
			FORMAT="$FORMAT$CODE"
			# Remove arguments from stack
			shift
			shift
		done
		## APPLY FORMAT TO TEXT
		FORMAT_CODE=$(getFormattingSequence $FORMAT)
		echo -n "${FORMAT_CODE}"
	fi
}
##------------------------------------------------------------------------------
##
formatText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "${RESET}"
	## ONLY A STRING PROVIDED -> Append reset sequence
	elif [ "$#" -eq 1 ]; then
		TEXT=$1
		echo -n "${TEXT}${RESET}"
	## ARGUMENTS PROVIDED
	else
		TEXT=$1
		FORMAT_CODE=$(getFormatCode "${@:2}")
		applyCodeToText "$TEXT" "$FORMAT_CODE"
	fi
}
##------------------------------------------------------------------------------
##
removeColorCodes()
{
	printf "$1" | sed 's/\x1b\[[0-9;]*m//g'
}
##==============================================================================
##	DEBUG
##==============================================================================
#formatText "$@"
#FORMATTED_TEXT=$(formatText "HELLO WORLD!!" -c red -b 13 -e bold -e blink -e strikeout)
#echo -e "$FORMATTED_TEXT"
#FORMAT=$(getFormatCode -c blue -b yellow)
#NONE=$(getFormatCode -e none)
#echo -e $FORMAT"Hello"$NONE
#!/bin/bash
##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2020, Andres Gongora <mail@andresgongora.com>.     |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+
##
##	DESCRIPTION
##
##	This script takes a path name and shortens it.
##	- home is replaced by ~
##	- last folder in apth is never truncated
##
##
##	REFERENCES
##
##	Original source: WOLFMAN'S color bash promt
##	https://wiki.chakralinux.org/index.php?title=Color_Bash_Prompt#Wolfman.27s
##
##==============================================================================
##	FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##
shortenPath()
{
	## GET PARAMETERS
	local path=$1
	local max_length=$2
	local default_max_length=25
	local trunc_symbol=".."
	if   [ -z "$path" ]; then
		echo ""
		exit
	elif [ -z "$max_length" ]; then
		local max_length=$default_max_length
	fi
	## CLEANUP PATH
	## Replace HOME with ~ for the current user, similar to sed.
	local path=${path/#$HOME/\~}
	## TRUNCATE DIR IF NEEDED
	## - Get curred directory (last folder in path)
	## - Get max length, as the greater of etiher the (desired) max lenght
	##   and the length of the current dir. Dir never gets truncated.
	## - If path length > max_length 
	##	- Truncate the path to max_length
	##	- Clean off path fragments before first '/' (included)
	##	- Append "trunc_symbol", '/', and the clean path
	local dir=${path##*/}
	local dir_length=${#dir}
	local path_length=${#path}
	local print_length=$(( ( max_length < dir_length ) ? dir_length : max_length ))
	if [ $path_length -gt $print_length ]; then
		local offset=$(( $path_length - $print_length ))
		local truncated_path=${path:$offset}
		local clean_path=${truncated_path#*/}
		local short_path=${trunc_symbol}/${clean_path}
	else
		local short_path=$path
	fi
	## RETURN FINAL PATH
	echo $short_path
}
##==============================================================================
## COLORS
##
## Control the color and format scheme of the bash prompt.
## The prompt is divided into segments, listed below starting from the left:
## -  USER: shows the user's name.
## -  HOST: shows the host's name.
## -   PWD: shows the current directory.
## -   GIT: if inside a git repository, shows the name of current branch.
## - PYENV: if inside a Python Virtual environment.
## -    TF: if inside a Terraform Workspace.
## - CLOCK: shows current time in H:M format.
## - INPUT: actual bash input.
##
## Valid color options:
## - white black light-gray dark-gray
##   red green yellow blue cyan purple
##   light-red light-green light-yellow light-blue light-cyan light-purple
## - Values in the range [0-255] for 256 bit colors. To check all number-color
##   pairs for your terminal, you may run the following snippet by HaleTom:
##     curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash
##   or search something like "bash 256 color codes" on the internet.
##
##==============================================================================
format="USER HOST PWD GIT PYENV TF"
font_color_user="white"
background_user="blue"
texteffect_user="bold"
font_color_host="white"
background_host="light-blue"
texteffect_host="bold"
font_color_pwd="dark-gray"
background_pwd="white"
texteffect_pwd="bold"
font_color_git="light-gray"
background_git="dark-gray"
texteffect_git="bold"
font_color_pyenv="white"
background_pyenv="blue"
texteffect_pyenv="bold"
font_color_tf="purple"
background_tf="light-purple"
texteffect_tf="bold"
font_color_clock="white"
background_clock="light-blue"
texteffect_clock="bold"
font_color_input="45"
background_input="none"
texteffect_input="bold"
##==============================================================================
## BEHAVIOR
##==============================================================================
separator_char='\uE0B0'         # Separation character, '\uE0B0'=triangle
separator_padding_left=''       #
separator_padding_right=''      #
prompt_horizontal_padding=''    #
prompt_final_padding=''         #
segment_padding=' '             #
enable_vertical_padding=true    # Add extra new line over prompt
max_pwd_char="20"
##==============================================================================
## GIT
##==============================================================================
git_symbol_synced=''
git_symbol_unpushed=' ▲'
git_symbol_unpulled=' ▼'
git_symbol_unpushedunpulled=' ●'
git_symbol_dirty=' □'
git_symbol_dirty_unpushed=' △'
git_symbol_dirty_unpulled=' ▽'
git_symbol_dirty_unpushedunpulled=' ○'
#!/bin/bash
##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2018-2020, Andres Gongora <mail@andresgongora.com>.     |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+
##
##	DESCRIPTION
##
##	This script updates your "PS1" environment variable to display colors.
##	Additionally, it also shortens the name of your current path to a
##	maximum 25 characters, which is quite useful when working in deeply
##	nested folders.
##
##
##
##	REFFERENCES
##
##	* http://tldp.org/HOWTO/Bash-Prompt-HOWTO/index.html
##
##
##==============================================================================
##	EXTERNAL DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd "$(dirname "${BASH_SOURCE[0]}")"&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d="$PWD"&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}
prompter()
{
##==============================================================================
##	FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##	getGitInfo
##	Returns current git branch for current directory, if (and only if)
##	the current directory is part of a git repository, and git is installed.
##
##	In addition, it adds a symbol to indicate the state of the repository.
##	By default, these symbols and their meaning are (set globally):
##
##		UPSTREAM	NO CHANGE		DIRTY
##		up to date	SSP_GIT_SYNCED		SSP_GIT_DIRTY
##		ahead		SSP_GIT_AHEAD		SSP_GIT_DIRTY_AHEAD
##		behind		SSP_GIT_BEHIND		SSP_GIT_DIRTY_BEHIND
##		diverged	SSP_GIT_DIVERGED	SSP_GIT_DIRTY_DIVERGED
##
##	Returns an empty string otherwise.
##
##	Inspired by twolfson's sexy-bash-prompt:
##	https://github.com/twolfson/sexy-bash-prompt
##
getGitBranch()
{
	if ( which git > /dev/null 2>&1 ); then
		## CHECK IF IN A GIT REPOSITORY, OTHERWISE SKIP
		local branch=$(git branch 2> /dev/null |\
		             sed -n '/^[^*]/d;s/*\s*\(.*\)/\1/p')
		if [[ -n "$branch" ]]; then
			## GET GIT STATUS
			## This information contains whether the current branch is
			## ahead, behind or diverged (ahead & behind), as well as
			## whether any file has been modified locally (is dirty).
			## --porcelain: script friendly output.
			## -b:          show branch tracking info.
			## -u no:       do not list untracked/dirty files
			## From the first line we get whether we are synced, and if
			## there are more lines, then we know it is dirty.
			## NOTE: this requires that you fetch your repository,
			##       otherwise your information is outdated.
			local is_dirty=false &&\
				       [[ -n "$(git status --porcelain)" ]] &&\
				       is_dirty=true
			local is_ahead=false &&\
				       [[ "$(git status --porcelain -u no -b)" == *"ahead"* ]] &&\
				       is_ahead=true
			local is_behind=false &&\
				        [[ "$(git status --porcelain -u no -b)" == *"behind"* ]] &&\
				        is_behind=true
			## SELECT SYMBOL
			if   $is_dirty && $is_ahead && $is_behind; then
				local symbol=$SSP_GIT_DIRTY_DIVERGED
			elif $is_dirty && $is_ahead; then
				local symbol=$SSP_GIT_DIRTY_AHEAD
			elif $is_dirty && $is_behind; then
				local symbol=$SSP_GIT_DIRTY_BEHIND
			elif $is_dirty; then
				local symbol=$SSP_GIT_DIRTY
			elif $is_ahead && $is_behind; then
				local symbol=$SSP_GIT_DIVERGED
			elif $is_ahead; then
				local symbol=$SSP_GIT_AHEAD
			elif $is_behind; then
				local symbol=$SSP_GIT_BEHIND
			else
				local symbol=$SSP_GIT_SYNCED
			fi
			## RETURN STRING
			echo "$branch$symbol"
		fi
	fi
	## DEFAULT
	echo ""
}
getTerraform()
{
	## Check if we are in a terraform directory
	if [ -d .terraform ]; then
		## Check if the terraform binary is in the path
		if ( which terraform > /dev/null 2>&1 ); then
			## Get the terraform workspace
			local tf="$(terraform workspace show 2> /dev/null | tr -d '\n')"
			echo "$tf"
		fi
	fi
}
getPyenv()
{
	local pyenv="No env"
	## Conda environment
	if [ -n "$CONDA_DEFAULT_ENV" ]; then
		echo -e "🐍 $CONDA_DEFAULT_ENV"
	## Python virtual environment
	elif [ -n "$VIRTUAL_ENV" ]; then
		local pyenv=$(basename ${VIRTUAL_ENV})
	fi

	echo -e "🐍 $pyenv"
}
printSegment()
{
	## GET PARAMETERS
	local text=$1
	local font_color=$2
	local background_color=$3
	local next_background_color=$4
	local font_effect=$5
	## COMPUTE COLOR FORMAT CODES
	local no_color="\[$(getFormatCode -e reset)\]"
	local text_format="\[$(getFormatCode -c $font_color -b $background_color -e $font_effect)\]"
	local separator_format="\[$(getFormatCode -c $background_color -b $next_background_color)\]"
	## GENERATE TEXT
	printf "${text_format}${segment_padding}${text}${segment_padding}${separator_padding_left}${separator_format}${separator_char}${separator_padding_right}${no_color}"
}
get_colors_for_element()
{
	case $1 in
		"USER")  echo "${SSP_COLORS_USER[@]}" ;;
		"HOST")  echo "${SSP_COLORS_HOST[@]}" ;;
		"PWD")   echo "${SSP_COLORS_PWD[@]}"  ;;
		"GIT")   echo "${SSP_COLORS_GIT[@]}"  ;;
		"PYENV") echo "${SSP_COLORS_PYENV[@]}";;
		"TF")    echo "${SSP_COLORS_TF[@]}"   ;;
		"CLOCK") echo "${SSP_COLORS_CLOCK[@]}";;
		"INPUT") echo "${SSP_COLORS_INPUT[@]}";;
		*)
	esac
}
combine_elements()
{
	local first=$1
	local second=$2
	local colors_first=($(get_colors_for_element $first))
	local colors_second=($(get_colors_for_element $second))
	case $first in
		"USER")  local text="$user :: " ;;
		"HOST")  local text="$host @ " ;;
		"PWD")   local text="$path" ;;
		"GIT")   local text=" שׂ $git_branch " ;;
		"PYENV") local text="[ $pyenv ] " ;;
		"TF")    local text="$tf" ;;
		"CLOCK") local text="$clock" ;;
		"INPUT") local text="" ;;
		*)       local text="" ;;
	esac
	local text_color=${colors_first[0]}
	local bg_color=${colors_first[1]}
	local next_bg_color=${colors_second[1]}
	local text_effect=${colors_first[2]}
	printSegment "$text" "$text_color" "$bg_color" "$next_bg_color" "$text_effect"
}
##==============================================================================
##	HOOK
##==============================================================================
prompt_command_hook()
{
	## GET PARAMETERS
	## This might be a bit redundant, but it makes it easier to maintain
	local elements=(${SSP_ELEMENTS[@]})
	local user=$USER
	local host=$HOSTNAME
	local path="$(shortenPath "$PWD" $SSP_MAX_PWD_CHAR)"
	local git_branch="$(getGitBranch)"
	local pyenv="$(getPyenv)"
	local tf="$(getTerraform)"
	local clock="$(date +"%H:%M")"
	## ADAPT DYNAMICALLY ELEMENTS TO BE SHOWN
	## Check if elements such as GIT and the Python environment should be
	## shown and adapt the variables as needed. This usually implies removing
	## the appropriate field from the "elements" array if the user set them
	if [ -z "$git_branch" ]; then
		elements=( ${elements[@]/"GIT"} ) # Remove GIT from elements to be shown
	fi
	if [ -z "$pyenv" ]; then
		elements=( ${elements[@]/"PYENV"} ) # Remove PYENV from elements to be shown
	fi
	if [ -z "$tf" ]; then
		elements=( ${elements[@]/"TF"} ) # Remove TF from elements to be shown
	fi
	## WINDOW TITLE
	## Prevent messed up terminal-window titles, must be set in the PS1 variable
	case $TERM in
	xterm*|rxvt*)
		SSP_PWD="$path"
		local titlebar="\[\033]0;\${USER}@\${HOSTNAME}: \${SSP_PWD}\007\]"
		;;
	*)
		local titlebar=""
		;;
	esac
	## CONSTRUCT PROMPT ITERATIVELY
	## Iterate through all elements to be shown and combine them. Stop once only
	## 1 element is left, which should be the "INPUT" element; then apply the
	## INPUT formatting.
	## Notice that this reuses the PS1 variables over and over again, and appends
	## all extra formatting elements to the end of it.
	PS1="${titlebar}${SSP_VERTICAL_PADDING}"
	while [ "${#elements[@]}" -gt 1 ]; do
		local current=${elements[0]}
		local next=${elements[1]}
		local elements=("${elements[@]:1}") #remove the 1st element
		PS1="$PS1$(combine_elements $current $next)"
	done
	local input_colors=($(get_colors_for_element ${elements[0]}))
	local input_color=${input_colors[0]}
	local input_bg=${input_colors[1]}
	local input_effect=${input_colors[2]}
	local input_format="\[$(getFormatCode -c $input_color -b $input_bg -e $input_effect)\]"
	PS1="$PS1 $input_format\n>>> "
	## Once this point is reached, PS1 is formatted and set. The terminal session
	## will then use that variable to prompt the user :)
}
##==============================================================================
##	MAIN
##==============================================================================
	## LOAD USER CONFIGURATION
	local user_config_file="$HOME/.config/gr8sh/prompt.config"
	if   [ -f $user_config_file ]; then
		source $user_config_file
	fi
	## PADDING
	if $enable_vertical_padding; then
		local vertical_padding="\n"
	else
		local vertical_padding=""
	fi
    ## CONFIG FOR "prompt_command_hook()"
	SSP_ELEMENTS=($format "INPUT") # Append INPUT to elements that have to be shown
	SSP_COLORS_USER=($font_color_user $background_user $texteffect_user)
	SSP_COLORS_HOST=($font_color_host $background_host $texteffect_host)
	SSP_COLORS_PWD=($font_color_pwd $background_pwd $texteffect_pwd)
	SSP_COLORS_GIT=($font_color_git $background_git $texteffect_git)
	SSP_COLORS_PYENV=($font_color_pyenv $background_pyenv $texteffect_pyenv)
	SSP_COLORS_TF=($font_color_tf $background_tf $texteffect_tf)
	SSP_COLORS_CLOCK=($font_color_clock $background_clock $texteffect_clock)
	SSP_COLORS_INPUT=($font_color_input $background_input $texteffect_input)
	SSP_VERTICAL_PADDING=$vertical_padding
	SSP_MAX_PWD_CHAR=${max_pwd_char:-20}
	SSP_GIT_SYNCED=$git_symbol_synced
	SSP_GIT_AHEAD=$git_symbol_unpushed
	SSP_GIT_BEHIND=$git_symbol_unpulled
	SSP_GIT_DIVERGED=$git_symbol_unpushedunpulled
	SSP_GIT_DIRTY=$git_symbol_dirty
	SSP_GIT_DIRTY_AHEAD=$git_symbol_dirty_unpushed
	SSP_GIT_DIRTY_BEHIND=$git_symbol_dirty_unpulled
	SSP_GIT_DIRTY_DIVERGED=$git_symbol_dirty_unpushedunpulled
	## For terminal line coloring, leaving the rest standard
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG
	## ADD HOOK TO UPDATE PS1 AFTER EACH COMMAND
	## Bash provides an environment variable called PROMPT_COMMAND.
	## The contents of this variable are executed as a regular Bash command
	## just before Bash displays a prompt.
	## We want it to call our own command to truncate PWD and store it in NEW_PWD
	PROMPT_COMMAND=prompt_command_hook
}
getNameOS()
{
	if   [ -f /etc/os-release ]; then
		local os_name=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /etc/os-release)
	elif [ -f /usr/lib/os-release ]; then
		local os_name=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /usr/lib/os-release)
	else
		local os_name=$(uname -sr)
	fi
	printf "$os_name"
}
getNameKernel()
{
	local kernel=$(uname -r)
	printf "$kernel"
}
getDate()
{
	local sys_date=$(date +"%d.%m.%Y")
	printf "$sys_date"
}
getUptime() 
{
	local seconds=`sed 's/\..*$//' /proc/uptime`
	local hours=$(( $seconds/3600 ))
	local minutes=$(( ( $seconds % 3600) / 60 ))
	local minutes_suffix="mins"
	local hours_suffix="hours"
	if [ $minutes -eq 1 ]; then minutes_suffix="min"; fi
	if [ $hours -eq 1 ];   then hours_suffix="hour";  fi
	echo "$hours $hours_suffix $minutes $minutes_suffix"
}
getNameCPU()
{
	## Get first instance of "model name" in /proc/cpuinfo, pipe into 'sed'
	## s/model name\s*:\s*//  remove "model name : " and accompanying spaces
	## s/\s*@.*//             remove anything from "@" onwards
	## s/(R)//                remove "(R)"
	## s/(TM)//               remove "(TM)"
	## s/CPU//                remove "CPU"
	## s/\s\s\+/ /            clean up double spaces (replace by single space)
	## p                      print final output
	local cpu=$(grep -m 1 "model name" /proc/cpuinfo |\
	            sed -n 's/model name\s*:\s*//;
	                    s/\s*@.*//;
	                    s/(R)//;
	                    s/(TM)//;
	                    s/CPU//;
	                    s/\s\s\+/ /;
	                    p')
	printf "$cpu"
}
printInfoGPU()
{
	# DETECT GPU(s)set
	local gpu_ids=($(lspci 2>/dev/null | grep ' VGA ' | cut -d" " -f 1))
	# FOR ALL DETECTED IDs
	# Get the GPU name, but trim all buzzwords away
	for id in "${gpu_ids[@]}"; do
		local gpu=$(lspci -v -s "$id" 2>/dev/null |\
		            head -n 1 |\
		            sed 's/^.*: //g;s/(.*$//g;
		                 s/Generation Core Processor Family Integrated Graphics Controller /gen IGC/g;
		                 s/Corporation//g;
		                 s/Core Processor//g;
		                 s/Series//g;
		                 s/Chipset//g;
		                 s/Graphics//g;
		                 s/processor//g;
		                 s/Controller//g;
		                 s/Family//g;
		                 s/Inc.//g;
		                 s/,//g;
		                 s/Technology//g;
		                 s/Mobility/M/g;
		                 s/Advanced Micro Devices/AMD/g;
		                 s/\[AMD\/ATI\]/ATI/g;
		                 s/Integrated Graphics Controller/HD Graphics/g;
		                 s/Integrated Controller/IC/g;
                         s/Matrox Electronics Systems Ltd. //g;
		                 s/  */ /g'
		           )
		# If GPU name still to long, remove anything between []
		if [ "${#gpu}" -gt 30 ]; then
			local gpu=$(printf "$gpu" | sed 's/\[.*\]//g' )
		fi
		echo "GPU" "$gpu"
	done
}
#echo ""
#echo "$(getNameOS) using $(getNameKernel)"
#echo "$(getDate) | Uptime: $(getUptime)"
#echo "CPU $(getNameCPU)| $(printInfoGPU)"
## CALL SCRIPT FUNCTION
## - CHECK IF SCRIPT IS _NOT_ BEING SOURCED
## - CHECK IF COLOR SUPPORTED
##     - Check if compliant with Ecma-48 (ISO/IEC-6429)
##	   - Call script
## - Unset script
## If not running interactively, don't do anything
if [ -n "$( echo $- | grep i )" ]; then
	if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
		echo -e "Do not run this script, it will do nothing.\nPlease source it instead by running:\n"
		echo -e "\t. ${BASH_SOURCE[0]}\n"
	elif [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		prompter
	fi
	unset prompter
	unset include
fi

