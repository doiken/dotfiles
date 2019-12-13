#!/usr/bin/env bash
#
# NAME
#   GithubWatcher.sh -- fetch pull requests
# USAGE
#   GithubWatcher.sh PATH_TO_ENVFILE
# DESCRIPTION
#   unfortunately api does not support for fetching only subscribed reviews well
#   https://stackoverflow.com/questions/25438721/how-can-i-see-all-the-issues-im-watching-on-github
#   GITHUB_TOKEN env var should be defined in PATH_TO_ENVFILE
#   jq command required
source $1
since=`date -v-7d "+%Y-%m-%d"`
commands=(
    '"https://api.github.com/notifications?all=true&since=${since}"| /usr/local/bin/jq ".[] | {title:.subject.title, url: .subject.url, updated_at: .updated_at}"'
    '"https://api.github.com/search/issues?q=involves:doiken+state:open+is:pr+updated:>=${since}" | /usr/local/bin/jq ".items[]|{title: .title, url:.url, updated_at: .updated_at}"'
)

cmd_prefix="curl -sH 'Authorization: token ${GITHUB_TOKEN}' "
stdout=""
for cmd in "${commands[@]}" ; do
    stdout="${stdout} $(eval $cmd_prefix $cmd)"
done

echo $stdout | /usr/local/bin/jq . --slurp
