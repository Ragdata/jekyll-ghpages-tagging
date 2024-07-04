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

if [ "$INPUT_DEBUG" = true ]; then
	echo "::group::Debug"
	echo "Environment:"
	env
	echo "Working Directory: $PWD"
	echo "::endgroup::"
fi

POSTS_DIR="$GITHUB_WORKSPACE/$INPUT_POSTS_DIR"


## download tag generator script
#curl -o jekyll-ghpages-tagging.sh https://raw.githubusercontent.com/ragdata/reusable-workflows/master/pages/scripts/jekyll-ghpages-tagging.sh
## grant tag generator script permissions
#chmod +x jekyll-ghpages-tagging.sh
## execute tag generator script
#./jekyll-ghpages-tagging.sh

exit 0
