#!/usr/bin/env bash
set -ex

#if the above command fails it means line endings are not unix





#if SCOREBOARD not set, run simple regression and exit
if [ -z "${SCOREBOARD}" ]; then
	python3 regression.py
	exit 0
fi


#else, update scoreboard



# Verify our environment variables are set
[ -z "${GIT_REPO}" ] && { echo "Need to set GIT_REPO"; exit 1; }
[ -z "${GIT_BRANCH}" ] && { echo "Need to set GIT_BRANCH"; exit 1; }
[ -z "${GIT_ORIGIN}" ] && { echo "Need to set GIT_ORIGIN"; exit 1; }
[ -z "${COMMIT_USER}" ] && { echo "Need to set COMMIT_USER"; exit 1; }
[ -z "${COMMIT_EMAIL}" ] && { echo "Need to set COMMIT_EMAIL"; exit 1; }
[ -z "${WORKING_DIR}" ] && { echo "Need to set WORKING_DIR"; exit 1; }
[ -z "${FILES_TO_COMMIT}" ] && { echo "Need to set FILES_TO_COMMIT"; exit 1; }

# Change to our working directory
cd ${WORKING_DIR}
ls -la



# Set up our SSH Key
mkdir ~/.ssh
cp .ssh/known_hosts ~/.ssh
cp .ssh/id_rsa ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa

#echo -e "Host *\n    StrictHostKeyChecking=no\n    UserKnownHostsFile=/dev/null\n" > ~/.ssh/config


# Configure our user and email to commit as.
git config --global user.name "${COMMIT_USER}"
git config --global user.email "${COMMIT_EMAIL}"

#change repo from https to ssh
git remote set-url origin "${GIT_REPO}"
git checkout ${GIT_BRANCH}
git reset HEAD -- .

python3 scoreboard.py

git pull origin master

#overwrite instead of merge
#git checkout stash -- .

mv data.json scoreboard
mv bot_scores.md scoreboard

git add scoreboard/*
git status


# Commit and push the detected changes if they are found.
git commit -m "Auto Build Scoreboard."
git push ${GIT_ORIGIN} ${GIT_BRANCH}

