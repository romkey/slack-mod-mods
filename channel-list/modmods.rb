#!/usr/bin/env ruby

require './slack'
require './options'

require 'dotenv/load'
require 'csv'

mod_mods_options = ModModsOptions.new
options = mod_mods_options.options

slack = Slack.new ENV['SLACK_API_TOKEN']
slack.verbose = options[:verbose]

usernames = Hash.new

channels = slack.conversations["channels"].map do |c|
  info = slack.conversation c["id"]

  if !usernames[c["creator"]]
    user_info = slack.user c["creator"]

    if user_info["ok"] && user_info["user"]
      usernames[c["creator"]] = user_info["user"]["name"]
    end
  end

  creator_name = usernames[c["creator"]] || ""

  { name: c["name"],
    created_at: c["created"],
    id: c["id"],
    purpose: c["purpose"]["value"],
    topic: c["topic"]["value"],
    creator: c["creator"],
    creator_name: creator_name,
    num_members: c["num_members"],
    is_private: c["is_private"],
    is_archived: c["is_archived"],
    is_read_only: info["channel"].key?("is_read_only")
  }
end

if options[:csv]
  puts %w{ID Name Created Creator Members Purpose Topic Private Archived ReadOnly CreatorName}.join(', ')
  CSV($stdout) do |csv|
    channels.each do |channel|
      csv << [ channel[:id], channel[:name], channel[:created_at], channel[:creator], channel[:num_members], channel[:purpose], channel[:topic], channel[:is_private], channel[:is_archived], channel[:is_read_only], channel[:creator_name] ]
    end
  end
elsif options[:json]
  puts channels.to_json
else
  channels.each do |channel|
    message = "%c %c %s %11s %32s %u %10s %12s %6d %.20s %.20s" % [channel[:is_archived] ? 'A' : ' ', channel[:is_private] ? 'P' : ' ', channel[:is_read_only] ? 'RO' : 'RW', channel[:id], channel[:name], channel[:created_at], channel[:creator], channel[:creator_name], channel[:num_members], channel[:purpose], channel[:topic] ]
    puts message
  end
end

