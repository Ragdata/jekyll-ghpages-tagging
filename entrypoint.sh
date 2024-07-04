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

if [[ "$INPUT_DEBUG" == true ]]; then
	echo "::group::Debug"
	echo "Environment:"
	env
	echo "Working Directory: $PWD"
	echo "::endgroup::"
fi

declare -a POST_TAGS
declare -a TAGS

FILES_ADDED=false

[[ ${INPUT_POSTS_DIR:0:1} == "/" ]] && INPUT_POSTS_DIR="${INPUT_POSTS_DIR:1}"
[[ ${INPUT_TAGS_DIR:0:1} == "/" ]] && INPUT_TAGS_DIR="${INPUT_TAGS_DIR:1}"

POSTS_DIR="$GITHUB_WORKSPACE/$INPUT_POSTS_DIR"
[[ "$INPUT_DEBUG" == true ]] && echo "::debug::POSTS_DIR = '$POSTS_DIR'"
TAGS_DIR="$GITHUB_WORKSPACE/$INPUT_TAGS_DIR"

if [[ ! -d "$POSTS_DIR" ]]; then echo "::error::POSTS_DIR '$POSTS_DIR' not found"; exit 1; fi
if [[ ! -d "$TAGS_DIR" ]]; then echo "::error::TAGS_DIR '$TAGS_DIR' not found"; exit 1; fi

if [[ -n "$INPUT_FEEDS_DIR" ]]; then
	[[ ${INPUT_FEEDS_DIR:0:1} == "/" ]] && INPUT_FEEDS_DIR="${INPUT_FEEDS_DIR:1}"
	FEEDS_DIR="$GITHUB_WORKSPACE/$INPUT_FEEDS_DIR"
	if [[ ! -d "$FEEDS_DIR" ]]; then echo "::error::FEEDS_DIR '$FEEDS_DIR' not found"; exit 1; fi
fi

## download tag generator script
#curl -o jekyll-ghpages-tagging.sh https://raw.githubusercontent.com/ragdata/reusable-workflows/master/pages/scripts/jekyll-ghpages-tagging.sh
## grant tag generator script permissions
#chmod +x jekyll-ghpages-tagging.sh
## execute tag generator script
#./jekyll-ghpages-tagging.sh

exit 0
