#!/usr/bin/env bash
#
# NAME
#   RedmineWatcher.sh -- fetch issues
# USAGE
#   RedmineWatcher.sh PATH_TO_ENVFILE
# DESCRIPTION
#   following env var should be defined in PATH_TO_ENVFILE
#     - REDMINE_ACCESS_TOKEN
#     - REDMINE_URL
#     - REDMINE_USER_ID
#   jq command required
source $1
since=`date -v-7d "+%Y-%m-%d"`
commands=(
    "'${REDMINE_URL}/issues.json?key=${REDMINE_ACCESS_TOKEN}&limit=20&status_id=open&assigned_to_id=${REDMINE_USER_ID}&updated_on=%3E%3D${since}'| /usr/local/bin/jq '.issues[] | {id:.id|tostring, title:.subject, url: ("\""${REDMINE_URL}/issues/"\"" + (.id|tostring)), updated_at: .updated_on, type: "\""mine"\""}'"
    "'${REDMINE_URL}/issues.json?key=${REDMINE_ACCESS_TOKEN}&limit=20&status_id=open&watcher_id=${REDMINE_USER_ID}&updated_on=%3E%3D${since}'| /usr/local/bin/jq '.issues[] | {id:.id|tostring, title:.subject, url: ("\""${REDMINE_URL}/issues/"\"" + (.id|tostring)), updated_at: .updated_on, type: "\""watch"\""}'"
)

stdout=""
for cmd in "${commands[@]}" ; do
    stdout="${stdout} $(eval curl -s $cmd)"
done

echo $stdout | /usr/local/bin/jq . --slurp
