#!/usr/bin/env ruby
# coding: utf-8


require 'net/http'
require 'uri'
require 'json'

# a6140cbf6e84a0bAffb0cX49138fc5687310b518
#   or
# launchctl setenv REDMINE_ACCESS_TOKEN a6140cbf6e84a0bAffb0cX49138fc5687310b518
token = ENV["REDMINE_ACCESS_TOKEN"]
# https://redmine.xxxx.com
#   or
# launchctl setenv REDMINE_URL https://redmine.xxxx.com
$redmine_url = ENV["REDMINE_URL"] || 'https://redmine.fout.jp'
display = ARGV[0] # qiita/slack
limit = ARGV[1] || 5
# user_id は自分のみ.me はグループ指定を含む
assigned_id = ENV["REDMINE_USER_ID"] || 'me'

def disp_qiita(issue)
  puts <<~EOS.strip
  - [##{issue[:id]}](#{$redmine_url}/issues/#{issue[:id]}):#{issue[:subject]}
      - 
  EOS
end

def disp_slack(issue)
  puts <<~EOS.strip
  ● *[#{issue[:subject]}](#{$redmine_url}/issues/#{issue[:id]})*
      ○ 
  EOS
end

uri = URI.parse("#{$redmine_url}/issues.json?key=#{token}&limit=#{limit}&sort=updated_on:desc&assigned_to_id=#{assigned_id}")

begin
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if(uri.scheme == 'https')
  res = http.start {
    http.get(uri.request_uri)
  }

  raise "error #{res.code} #{res.message}" if res.code != '200'

  result = JSON.parse(res.body, symbolize_names: true)
  issues = result[:issues]

	display_func = "disp_#{display}".to_sym
  issues.reverse.each do |issue|
	  next if /Tech day/.match(issue[:subject])
	  send(display_func, issue)
	end

rescue
  puts "Exception: #{$!}"
end

