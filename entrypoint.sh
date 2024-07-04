#!/usr/bin/env bash
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

set -e

#echo "::group::Environment"
#env
#echo "::endgroup::"

declare -a POST_TAGS
declare -a TAGS

tags_added=0
tags_removed=0
feeds_added=0

[[ ${INPUT_POSTS_DIR:0:1} == "/" ]] && INPUT_POSTS_DIR="${INPUT_POSTS_DIR:1}"
if [ ! -d "$INPUT_POSTS_DIR" ]; then echo "::error::INPUT_POSTS_DIR '$INPUT_POSTS_DIR' not found"; exit 1; fi

for file in "$INPUT_POSTS_DIR"/*; do
	# get filename
	filename="${file##*/}"
	# extract 'tags' line from file
	line=$(grep -Ei '^tags: ?\[.+\]$' "$filename")
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

[[ ${INPUT_TAGS_DIR:0:1} == "/" ]] && INPUT_TAGS_DIR="${INPUT_TAGS_DIR:1}"
if [ ! -d "$INPUT_TAGS_DIR" ]; then mkdir -p "$INPUT_TAGS_DIR"; fi

if [[ -n "$INPUT_FEEDS_DIR" ]]; then
	[[ ${INPUT_FEEDS_DIR:0:1} == "/" ]] && INPUT_FEEDS_DIR="${INPUT_FEEDS_DIR:1}"
	if [ ! -d "$INPUT_FEEDS_DIR" ]; then mkdir -p "$INPUT_FEEDS_DIR"; fi
fi

for tag in "${TAGS[@]}"; do
	# build filename
	tagfile="$TAGS_DIR/$tag.md"
	# check filename exists
	if [ ! -e "$tagfile" ]; then
		# write tag file
		printf "---\nlayout: %s\ntag-name: %s\n---\n" "$INPUT_TAGS_LAYOUT" "$tag" > "$tagfile"
		chmod 0644 "$tagfile"
		((tags_added++))
	fi
	if [ -n "$INPUT_FEEDS_DIR" ]; then
		feedfile="$FEEDS_DIR/$tag.xml"
		if [ ! -e "$feedfile" ]; then
			# write feed file
			printf "---\nlayout: %s\ntag-name: %s\n---\n" "$INPUT_FEEDS_LAYOUT" "$tag" > "$feedfile"
			chmod 0644 "$feedfile"
			((feeds_added++))
		fi
	fi
done

if [ "$INPUT_PRUNE_TAGS" = true ]; then
	for file in "$INPUT_TAGS_DIR"/*; do
		# get filename
		filename="${file##*/}"
		# get tagname
		tagname=${filename%.*}
		value="\<${tagname}\>"
		# shellcheck disable=SC2199
		if [[ ! ${TAGS[@]} =~ $value ]]; then
			rm -f "$file"
			if [ -n "$INPUT_FEEDS_DIR" ]; then
				# get feedname
				feedname="$INPUT_FEEDS_DIR/$tagname.xml"
				[ -f "$feedname" ] && rm -f "$feedname"
			fi
			((tags_removed++))
		fi
	done
fi

if (("$tags_added" > 0)) || (("$feeds_added" > 0)) || (("$tags_removed" > 0)); then
	git add -A
	git commit -m "tags &/or feeds modified\n\nAutomated using $GITHUB_ACTION in $GITHUB_WORKFLOW"
	git push
fi

printf "Tags Added: %d\nFeeds Added: %d\nTags Removed: %d" "$tags_added" "$feeds_added" "$tags_removed" >> "$GITHUB_STEP_SUMMARY"

exit 0
