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
export PATH="$PATH:/opt/homebrew/bin/"
since=`date -v-7d "+%Y-%m-%d"`
# 先勝ちの unique_by に合わせて自分が更新した issues を先に抽出
commands=(
    "'${REDMINE_URL}/issues.json?key=${REDMINE_ACCESS_TOKEN}&limit=20&status_id=open&assigned_to_id=${REDMINE_USER_ID}&updated_on=%3E%3D${since}&last_updated_by=${REDMINE_USER_ID}'| jq '.issues[] | {id:.id|tostring, title:.subject, url: ("\""${REDMINE_URL}/issues/"\"" + (.id|tostring)), updated_at: .updated_on, type: "\""mine"\"", updated_by: "\""me"\""}'"
    "'${REDMINE_URL}/issues.json?key=${REDMINE_ACCESS_TOKEN}&limit=20&status_id=open&watcher_id=${REDMINE_USER_ID}&updated_on=%3E%3D${since}&last_updated_by=${REDMINE_USER_ID}'| jq '.issues[] | {id:.id|tostring, title:.subject, url: ("\""${REDMINE_URL}/issues/"\"" + (.id|tostring)), updated_at: .updated_on, type: "\""watch"\"", updated_by: "\""me"\""}'"
    "'${REDMINE_URL}/issues.json?key=${REDMINE_ACCESS_TOKEN}&limit=20&status_id=open&assigned_to_id=${REDMINE_USER_ID}&updated_on=%3E%3D${since}'| jq '.issues[] | {id:.id|tostring, title:.subject, url: ("\""${REDMINE_URL}/issues/"\"" + (.id|tostring)), updated_at: .updated_on, type: "\""mine"\"", updated_by: "\""other"\""}'"
    "'${REDMINE_URL}/issues.json?key=${REDMINE_ACCESS_TOKEN}&limit=20&status_id=open&watcher_id=${REDMINE_USER_ID}&updated_on=%3E%3D${since}'| jq '.issues[] | {id:.id|tostring, title:.subject, url: ("\""${REDMINE_URL}/issues/"\"" + (.id|tostring)), updated_at: .updated_on, type: "\""watch"\"", updated_by: "\""other"\""}'"
)

stdout=""
for cmd in "${commands[@]}" ; do
    stdout="${stdout} $(eval curl -s $cmd)"
done

echo $stdout | jq . --slurp | jq 'unique_by(.id)'
