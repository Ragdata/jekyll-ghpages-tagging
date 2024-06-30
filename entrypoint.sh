#!/bin/sh -l

# use INPUT_<INPUT_NAME> to get the value of an input
# write outputs to the $GITHUB_OUTPUT file

cd "${GITHUB_WORKSPACE}" || exit

# download tag generator script
curl -o jekyll-ghpages-tagging.sh https://raw.githubusercontent.com/ragdata/reusable-workflows/master/pages/scripts/jekyll-ghpages-tagging.sh
# grant tag generator script permissions
chmod +x jekyll-ghpages-tagging.sh
# execute tag generator script
./jekyll-ghpages-tagging.sh

exit 0
