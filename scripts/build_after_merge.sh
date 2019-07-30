#!/bin/bash

# This script is intended to be used as an 'after success' script for the Travis build.
# When a change is merged to master, we want to safely bump zat so that this
# process at least is not a manual one.

branch=cgoddard/autopublish

echo '*** Checking if branch is master'
if [[ $TRAVIS_BRANCH != "cgoddard/autopublish" ]] || [[ $TRAVIS_EVENT_TYPE != 'push' ]]
then
  echo "** Not on master branch (on branch $TRAVIS_BRANCH, event type $TRAVIS_EVENT_TYPE)- exiting"
  exit 0
fi

echo '** Checking out master branch'
git checkout $branch

echo '*** checking if major/minor/patch'
LAST_MSG=$(git log -1)
if [[ $LAST_MSG =~ '[major]' ]]; then
  BUMP='major'
elif [[ $LAST_MSG =~ '[minor]' ]]; then
  BUMP='minor'
else
  BUMP='patch'
fi

echo '*** Updating version'
VERSION=$(bundle exec bump $BUMP --no-bundle | head -n 1 | awk '{print $3}')
# e.g.
# [cgoddard/autopublish 9aee057] v3.2.0
#  1 file changed, 1 insertion(+), 1 deletion(-)
# Bump version 3.1.1 to 3.2.0
# ->
# [cgoddard/autopublish 9aee057] v3.2.0
# -> v3.2.0
echo "*** Pushing master to origin"
git push origin $branch

echo "*** Pushing tag $VERSION to origin"
# git push origin $VERSION

echo "*** Done"
exit 0
