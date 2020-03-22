#!/usr/bin/env ruby

require './slack'
require './options'

require 'htmlentities'
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

  pins_response = slack.pins(c["id"])
  if(pins_response && pins_response["items"])
    pins = pins_response["items"].map { |pin| '## ' + pin["message"]["text"] + ' ##' }
  else
    pins = []
  end

  html_entities = HTMLEntities.new

  { name: c["name"],
    created_at: c["created"],
    created_at_friendly: Time.at(c["created"]).to_datetime.strftime("%-m/%d/%y %H:%M:%S"),
    id: c["id"],
    purpose: html_entities.decode(c["purpose"]["value"]),
    topic: html_entities.decode(c["topic"]["value"]),
    creator: c["creator"],
    creator_name: creator_name,
    num_members: c["num_members"],
    is_private: c["is_private"],
    is_archived: c["is_archived"],
    is_read_only: info["channel"].key?("is_read_only"),
    pins: pins.join(' ; ')
  }
end

if options[:csv]
  puts %w{ID Name Created Creator Members Purpose Topic Private Archived ReadOnly CreatorName CreatedFriendlyTime Pins}.join(', ')

  CSV($stdout) do |csv|
    channels.each do |channel|
      csv << [ channel[:id], channel[:name], channel[:created_at], channel[:creator], channel[:num_members], channel[:purpose], channel[:topic], channel[:is_private], channel[:is_archived], channel[:is_read_only], channel[:creator_name], channel[:created_at_friendly], channel[:pins] ]
    end
  end
elsif options[:json]
  puts channels.to_json
else
  channels.each do |channel|
    message = "%c %c %s %11s %32s %16s %10s %12s %6d %.20s %.20s %32s" % [channel[:is_archived] ? 'A' : ' ', channel[:is_private] ? 'P' : ' ', channel[:is_read_only] ? 'RO' : 'RW', channel[:id], channel[:name], channel[:created_at_friendly], channel[:creator], channel[:creator_name], channel[:num_members], channel[:purpose], channel[:topic], channel[:pins] ]
    puts message
  end
end

