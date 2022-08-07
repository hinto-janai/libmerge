# libmerge
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janaiyo>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#git <libmerge/merge.sh/a217971>

merge() {
	# init local variables.
	local LIBMERGE_OLD LIBMERGE_NEW LIBMERGE_TMP LIBMERGE_CMD IFS=$'\n' i || return 1

	# incorrect amount of arguments
	case $# in
		2|3) :;;
		*) return 2
	esac

	# check if file
	[[ -f "$1" ]] || return 3
	[[ -f "$2" ]] || return 4

	# check for read permission
	[[ -r "$1" ]] || return 5
	[[ -r "$2" ]] || return 6

	# get old file (a) in memory
	mapfile LIBMERGE_OLD < "$1" || return 7

	# get new file (b) into memory
	# there's 3 other ways to do this:
	#     - b=(cat b)
	#     - while read b; do ... done < b
	#     - b=$(<b)
	#
	# all three of these are quite
	# slow. for some reason, mapfile
	# is insanely fast at reading files,
	# around 32x~ faster. it does turn
	# it into an array which uses more
	# memory, but it's well worth it
	mapfile LIBMERGE_NEW < "$2" || return 8
	# turn new file array into normal string variable
	LIBMERGE_NEW=$(printf "%s" "${LIBMERGE_NEW[@]}") || return 8

	# check for empty variables
	[[ $LIBMERGE_OLD ]] || return 9
	[[ $LIBMERGE_NEW ]] || return 10

	# INTERACTIVE USE: shows diff
	if [[ $3 = "--diff" || $3 = "-d" ]]; then

		# print differences between
		# the old and the new.
		for i in ${LIBMERGE_OLD[@]}; do
			if printf "%s\n" "$LIBMERGE_NEW" | grep --quiet "^${i/=*/=}.*$"; then
			# import: value from old is imported into new
				LIBMERGE_NEW="$(printf "%s\n" "$LIBMERGE_NEW" | sed "s|^${i/=*/=}.*$|$i|g")" || return 12
				printf "\e[0;94m~ %s\n" "$i"

			# else, deprecated: in old, not in new
			else
				printf "\e[0;91m- %s\n" "$i"
			fi
		done
		# additions in new that weren't found in old
		if LIBMERGE_DIFF=$(printf "%s\n" "$LIBMERGE_NEW" | grep -vxf "$1"); then
			printf "\e[0;92m+ %s\n" $LIBMERGE_DIFF
		fi

	# FUNCTION USE: just final output
	else
		# create a single loooong
		# find/replace argument for sed
		# instead of invoking it every loop
		for i in ${LIBMERGE_OLD[@]}; do
			LIBMERGE_SED_CMD="s|^${i/=*/=}.*$|$i|g; $LIBMERGE_SED_CMD"
		done
		# invoke sed once, with the long argument we just created
		printf "%s\n" "$LIBMERGE_NEW" | sed "$LIBMERGE_SED_CMD" || return 12
	fi

	# turn off color
	printf "\e[0m"
}
