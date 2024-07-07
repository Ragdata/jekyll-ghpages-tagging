#!/usr/bin/env bash
# shellcheck disable=SC2317
####################################################################
# entrypoint.sh
####################################################################
# Jekyll GitHub-Pages Tagging Docker Action Entrypoint
#
# File:         entrypoint.sh
# Author:       Ragdata
# Date:         04/07/2024
# License:      MIT License
# Copyright:    Copyright © 2024 Darren (Ragdata) Poulton
####################################################################

set -eEuo pipefail

shopt -s inherit_errexit

IFS=$'\n\t'	# set unofficial strict mode @see: http://redsymbol.net/articles/unofficial-bash-strict-mode/

####################################################################
# FUNCTIONS
####################################################################
re::errorHandler()
{
	local -n lineNo="${1:-LINENO}"
	local -n bashLineNo="${2:-BASH_LINENO}"
	local lastCommand="${3:-BASH_COMMAND}"
	local code="${4:-0}"

	local lastCommandHeight

	[[ "$code" -eq 0 ]] && return 0

	lastCommandHeight="$(wc -l <<<"${lastCommand}")"

	local -a outputArray=()

	outputArray+=(
		'---'
		"Line History: [${lineNo} ${bashLineNo[*]}]"
		"Function Trace: [${FUNCNAME[*]}]"
		"Exit Code: ${code}"
	)

	[[ "${#BASH_SOURCE[@]}" -gt 1 ]] && {
		outputArray+=('source_trace:')
		for item in "${BASH_SOURCE[@]}"; do
			outputArray+=(" - ${item}")
		done
	} || outputArray+=("source_trace: [${BASH_SOURCE[*]}]")

	[[ "${lastCommandHeight}" -gt 1 ]] && {
		outputArray+=('last_command: ->' "${lastCommand}")
	} || outputArray+=("last_command: ${lastCommand}")

	outputArray+=('---')

	printf '%s\n' "${outputArray[@]}" >&2

	exit "$code"
}
####################################################################
# MAIN
####################################################################
trap 're::errorHandler "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR

declare -a POST_TAGS
declare -a TAGS

tagsAdded=0
tagsRemoved=0
feedsAdded=0

commit_msg="modified tags &/or feeds

Automated using $GITHUB_ACTION in $GITHUB_WORKFLOW"

#-------------------------------------------------------------------
# Process Posts
#-------------------------------------------------------------------
[[ ${INPUT_POSTS_DIR:0:2} == "./" ]] && INPUT_POSTS_DIR="${INPUT_POSTS_DIR:2}"
[[ ${INPUT_POSTS_DIR:0:1} == "/" ]] && INPUT_POSTS_DIR="${INPUT_POSTS_DIR:1}"

if [ ! -d "$INPUT_POSTS_DIR" ]; then echo "::error::INPUT_POSTS_DIR '$INPUT_POSTS_DIR' not found"; exit 1; fi

for file in "$INPUT_POSTS_DIR"/*; do
	# extract 'tags' line from file
	line=$(grep -Ei '^tags: ?\[.+\]$' "$file")
	# remove whitespace
	line="${line//, /,}"
	# lowercase
	line="${line,,}"
	# extract tags from line
	[[ $line =~ ^.*\[(.*)\]$ ]]
	# split tags and store
	IFS=, read -ra POST_TAGS <<< "${BASH_REMATCH[1]}"
	# merge POST_TAGS with TAGS
	mapfile -t TAGS < <(printf '%s\n' "${POST_TAGS[@]}")
done

#-------------------------------------------------------------------
# Process Tags & Feeds
#-------------------------------------------------------------------
[[ ${INPUT_TAGS_DIR:0:1} == "/" ]] && INPUT_TAGS_DIR="${INPUT_TAGS_DIR:1}"
if [ ! -d "$INPUT_TAGS_DIR" ]; then mkdir -p "$INPUT_TAGS_DIR" || { echo "::error::Unable to create directory '$INPUT_TAGS_DIR'"; exit 1; } fi

if [[ -n "$INPUT_FEEDS_DIR" ]]; then
	[[ ${INPUT_FEEDS_DIR:0:1} == "/" ]] && INPUT_FEEDS_DIR="${INPUT_FEEDS_DIR:1}"
	if [ ! -d "$INPUT_FEEDS_DIR" ]; then mkdir -p "$INPUT_FEEDS_DIR" || { echo "::error::Unable to create directory '$INPUT_FEEDS_DIR'"; exit 1; }; fi
fi

for tag in "${TAGS[@]}"; do
	# build filename
	tagfile="$INPUT_TAGS_DIR/$tag.md"
	# write tag file if not exists
	if [ ! -e "$tagfile" ]; then
		echo "::debug::Writing to file '$tagfile'"
		# write tag file
		printf -- "---\nlayout: %s\ntag-name: %s\n---\n" "$INPUT_TAGS_LAYOUT" "$tag" > "$tagfile"
		chmod 0644 "$tagfile"
		((tagsAdded+=1))
	fi
	if [ -n "$INPUT_FEEDS_DIR" ]; then
		feedFile="$INPUT_FEEDS_DIR/$tag.xml"
		if [ ! -e "$feedFile" ]; then
			echo "::debug::Writing to file '$feedFile'"
			# write feed file
			printf -- "---\nlayout: %s\ntag-name: %s\n---\n" "$INPUT_FEEDS_LAYOUT" "$tag" > "$feedFile"
			chmod 0644 "$feedFile"
			((feedsAdded+=1))
		fi
	fi
done

#-------------------------------------------------------------------
# Prune Tags
#-------------------------------------------------------------------
if [ "$INPUT_PRUNE_TAGS" = true ]; then
	for file in "$INPUT_TAGS_DIR"/*; do
		# get filename
		filename="${file##*/}"
		# get tagName
		tagName=${filename%.*}
		value="\<${tagName}\>"
		# shellcheck disable=SC2199
		if [[ ! ${TAGS[@]} =~ $value ]]; then
			echo "::debug::Removing Tag file '$file'"
			rm -f "$file"
			if [ -n "$INPUT_FEEDS_DIR" ]; then
				# get feedName
				feedName="$INPUT_FEEDS_DIR/$tagName.xml"
				echo "::debug::Removing Feed file '$feedName'"
				[ -f "$feedName" ] && rm -f "$feedName"
			fi
			((tagsRemoved+=1))
		fi
	done
fi

#-------------------------------------------------------------------
# Commit New Files to Repo
#-------------------------------------------------------------------
if (("$tagsAdded" > 0)) || (("$feedsAdded" > 0)) || (("$tagsRemoved" > 0)); then
	echo "::debug::Committing Modified Files to Git"
	git config --global --add safe.directory "$GITHUB_WORKSPACE"
	git config user.email "$GITHUB_ACTOR_ID+$GITHUB_ACTOR@users.noreply.github.com"
	git config user.name "$GITHUB_ACTOR"
	git add -A
	git commit -m "$commit_msg"
	git push
fi

#-------------------------------------------------------------------
# Write Job Summary
#-------------------------------------------------------------------
summaryTable="
| Function	   | Result		  |
| ------------ | :----------: |
| Tags Added   | $tagsAdded	  |
| Feeds Added  | $feedsAdded  |
| Tags Removed | $tagsRemoved |
"

cat << EOF >> "$GITHUB_STEP_SUMMARY"
### :gear: jekyll-ghpages-tagging Action Summary
$summaryTable
EOF

exit 0
