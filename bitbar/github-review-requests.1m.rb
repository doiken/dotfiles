#!/usr/bin/env ruby
# coding: utf-8

# <bitbar.title>Github Review Requests</bitbar.title>
# <bitbar.version>v0.0.1</bitbar.version>
# <bitbar.author>doiken</bitbar.author>
# <bitbar.author.github>doiken</bitbar.author.github>
# <bitbar.desc>Show Interesting Github Reviews</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'net/http'
require 'uri'
require 'json'
require "date"

# read REDMINE_XXX env var from zsh
envs = `source ~/.zshrc.d/work.zsh; set | grep [G]ITHUB`
envs.split("\n").each do |line|
  values = line.split("=")
  ENV[values[0]] = values[1]
end

token = ENV["GITHUB_TOKEN"] || ''
since = '2019-11-27T08:00:00Z'
new_in_day = 3

uri = URI.parse("https://api.github.com/notifications?all=true&since=#{since}")

begin
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if(uri.scheme == 'https')
  res = http.start {
    http.get(uri.request_uri, {"Authorization" => "token #{token}"})
  }

  raise "error #{res.code} #{res.message}" if res.code != '200'

  result = JSON.parse(res.body, symbolize_names: true)

  repos = Hash.new do | h, k |
    h[k] = {
      review_count: 0,
      reviews: Hash.new { | h1, k1 | h1[k1] = {}}
    }
  end
  result
    .select { |v| (['manual', 'subscribed'].include? v[:reason]) && v[:unread] }
    .each do | v |
      repo_name  = v[:repository][:full_name]
      id  = v[:subject][:url][/\/([0-9]+)$/,1] # extract pull request if from url
      next if repos[repo_name][:reviews].key?(id)
      repos[repo_name][:review_count] += 1
      repos[repo_name][:reviews][id][:name] = v[:subject][:title]
      repos[repo_name][:reviews][id][:updated] = Date.parse(v[:updated_at])
      repos[repo_name][:reviews][id][:id] = id
    end
  pr_count = repos.values.inject(0) {|sum, v| sum + v[:review_count]}

  puts repos.empty? ? "〓 | color=#7d7d7d" : "〓 #{pr_count}"
  puts "---"
  puts "Github | href=https://github.com/notifications/subscriptions"
  puts "---"

  repos.each do | repo_name, repo|
    puts "➠ #{repo_name}: #{repo[:review_count]} | color=#33BFDB size=11"
    reviews = repo[:reviews].values.sort_by{|v| v[:updated]}
    reviews.each do | review |
      prefix = reviews.last == review ? "└" : "├"
      comming = review[:updated] > Date.today.prev_day(new_in_day) ? '✧' : ''
      puts "#{prefix} #{comming} ##{review[:id]} #{review[:name]} | href=https://github.com/#{repo_name}/pull/#{review[:id]} size=11"
    end
    puts "---"
  end
rescue
  puts "〓 ! | color=#ECB935"
  puts "---"
  puts "Exception: #{$!}"
end
