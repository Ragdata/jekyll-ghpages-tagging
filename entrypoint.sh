#!/bin/sh
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

####################################################################
# ENVIRONMENT VARIABLES
####################################################################
## debug switch
## default: `false`
#DEBUG=${INPUT_DEBUG:-${DEBUG:-false}}
#
## branch to deploy to
## default: `gh-pages`
#GHPAGES_BRANCH=${INPUT_GHPAGES_BRANCH:-${GHPAGES_BRANCH:-"gh-pages"}}
#
## jekyll build folder
## default: `_site`
#GHPAGES_DIST_FOLDER=${INPUT_GHPAGES_DIST_FOLDER:-${GHPAGES_DIST_FOLDER:-"_site"}}
#
## commit message
#GHPAGES_COMMIT_MSG=${INPUT_GHPAGES_COMMIT_MSG:-${GHPAGES_COMMIT_MSG:-"deploy commit $GITHUB_SHA\n\nAutodeployed using $GITHUB_ACTION in $GITHUB_WORKFLOW"}}
#
## github token
#GITHUB_TOKEN=${INPUT_GITHUB_TOKEN:-$GITHUB_TOKEN}
#
## remote repo
#REMOTE_REPO=${INPUT_REMOTE_REPO:-${REMOTE_REPO:-"https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"}}
#
## committer username
## default: $GITHUB_ACTOR
#COMMITTER_USERNAME=${INPUT_COMMITTER_USERNAME:-${COMMITTER_USERNAME:-$GITHUB_ACTOR}}
#
## committer email
## default: `$GITHUB_ACTOR@users.noreply.github.com`
#COMMITTER_EMAIL=${INPUT_COMMITTER_EMAIL:-${COMMITTER_EMAIL:-"${GITHUB_ACTOR}@users.noreply.github.com"}}
#
## force push?
## default: `true`
#GIT_FORCE=${INPUT_GIT_FORCE:-${GIT_FORCE:-true}}
#
## override contents of branch with current build?
## default: `false`
#GHPAGES_BRANCH_OVERRIDE=${INPUT_GHPAGES_BRANCH_OVERRIDE:-${GHPAGES_BRANCH_OVERRIDE:-false}}
#
## jekyll build options
#JEKYLL_BUILD_OPTS="${INPUT_JEKYLL_BUILD_OPTS:-${JEKYLL_BUILD_OPTS}}"
#
## add `.nojekyll` file indicating branch should not be built?
## default: `true`
#GHPAGES_NO_JEKYLL=${INPUT_GHPAGES_NO_JEKYLL:-${GHPAGES_NO_JEKYLL:-true}}
#
## skip deployment?
## default: `false`
#SKIP_DEPLOY=${INPUT_SKIP_DEPLOY:-${SKIP_DEPLOY:-false}}
#
## show bundle install log?
## default: `false`
#SHOW_BUNDLE_LOG=${INPUT_SHOW_BUNDLE_LOG:-${SHOW_BUNDLE_LOG:-false}}
#
## version of bundle to install
#BUNDLER_VERSION=${INPUT_BUNDLER_VERSION:-${BUNDLER_VERSION}}
#
## jekyll environment
#JEKYLL_ENV=${INPUT_JEKYLL_ENV:-${JEKYLL_ENV}}

####################################################################
# PROCESS
####################################################################

if [ "$DEBUG" = true ]; then
	echo "::group::Debug"
	echo "Environment:"
	env
	echo
	echo "Working Directory: $PWD"
	echo "::endgroup::"
	set -x
fi



## download tag generator script
#curl -o jekyll-ghpages-tagging.sh https://raw.githubusercontent.com/ragdata/reusable-workflows/master/pages/scripts/jekyll-ghpages-tagging.sh
## grant tag generator script permissions
#chmod +x jekyll-ghpages-tagging.sh
## execute tag generator script
#./jekyll-ghpages-tagging.sh

exit 0
