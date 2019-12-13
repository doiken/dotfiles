#!/usr/bin/env bash
#
# NAME
#   GithubWatcher.sh -- fetch pull requests
# USAGE
#   GithubWatcher.sh PATH_TO_ENVFILE
# DESCRIPTION
#   GITHUB_TOKEN env var should be defined in PATH_TO_ENVFILE
#   jq command required
source $1
since=`date -v-7d "+%Y-%m-%d"`
commands=(
    '"https://api.github.com/issues?filter=subscribed&state=open&sort=updated&since=${since}"| /usr/local/bin/jq ".[] | {title:.title, url: .url, updated_at: .updated_at}"'
    '"https://api.github.com/search/issues?q=involves:doiken+state:open+is:pr+updated:>=${since}" | /usr/local/bin/jq ".items[]|{title: .title, url:.url, updated_at: .updated_at}"'
)

cmd_prefix="curl -sH 'Authorization: token ${GITHUB_TOKEN}' "
stdout=""
for cmd in "${commands[@]}" ; do
    stdout="${stdout} $(eval $cmd_prefix $cmd)"
done

echo $stdout | /usr/local/bin/jq . --slurp
