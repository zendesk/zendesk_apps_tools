#!/bin/bash

# This script is intended to be used as an 'after deploy' script for the Travis build.
# When a change is merged to master, we want to build the assets and commit to zendesk_app_framework.

echo '*** Checking if branch is master'
if [[ $TRAVIS_BRANCH != "master" ]] || [[ $TRAVIS_EVENT_TYPE != 'push' ]]
then
  echo "** Not on master branch (on branch $TRAVIS_BRANCH, event type $TRAVIS_EVENT_TYPE)- exiting"
  exit 0
fi

echo '** Checking out master branch'
git checkout master

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
VERSION=$(bump $BUMP --no-bundle)

echo "*** Pushing master to origin"
git push origin master

echo "*** Pushing tag $VERSION to origin"
git push origin $VERSION

echo "*** Done"
exit 0
