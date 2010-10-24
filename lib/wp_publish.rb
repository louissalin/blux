#!/usr/bin/env ruby
## Copyright (c) 2007 John Mettraux
## Released under the MIT license
## http://www.opensource.org/licenses/mit-license.php
##
## Modifications by Louis Salin, October 2010
## => reading blog information from the configuration file

require 'optparse'
require 'net/http'
require 'atom/entry' # sudo gem install atom-tools
require 'atom/collection'
require "#{File.dirname(__FILE__)}/blux_config_reader"

# parse options

tags = []
title = nil
type = 'html'
bluxrc = nil
command = :post
entry_id = nil

opts = OptionParser.new
opts.banner = "Usage: post.rb [options]"
opts.separator ""
opts.separator "options :"

opts.on(
	"-c",
	"--categories {list}",
	"comma separated list of tags/categories") do |v|

	tags = v.split ","
	end

opts.on(
	"-t",
	"--title {title}",
	"title for the post") do |v|

	title = v
	end

opts.on(
	"-T",
	"--type {html|xhtml|text}",
	"type of the content. ('html' is the default).") do |v|

	type = v
	end

opts.on(
	"--config {config_file}",
	"blux config file path") do |f|
	bluxrc = f
	end

opts.on(
	"--update {entry_id}",
	"update an existing post") do |id|
	command = :put
	entry_id = id
	end

opts.on(
	"--delete {entry_id}",
	"delete an existing post") do |id|
	command = :delete
	entry_id = id
	end

opts.on(
	"-h",
	"--help",
	"displays this help") do

	puts
	puts opts.to_s
	puts
	exit 0
	end

opts.parse ARGV


# a great thanks to the devs of all the libs used here
#
# some info about you and your blog

config = BluxConfigurationReader.new
config.load_config bluxrc

blog = config.blog
authorname = config.author_name
username = config.user_name
password = config.password

bloguri = "http://#{blog}.wordpress.com"
base = "https://#{blog}.wordpress.com/wp-app.php"

#
# gather content

content = ""
if command != :delete
	loop do
		line = STDIN.gets
		break unless line
		content += line
	end
end

# create entry

entry = Atom::Entry.new
entry.title = title
entry.updated!

author = Atom::Author.new
author.name = authorname
author.uri = bloguri
entry.authors << author

tags.each do |t|
	c = Atom::Category.new
	c["scheme"] = bloguri
	c["term"] = t.strip
	entry.categories << c
end

entry.content = content
entry.content["type"] = type if type

h = Atom::HTTP.new
h.user = username
h.pass = password
h.always_auth = :basic

c = Atom::Collection.new(base + "/posts", h)
case(command)
when :post
	raise "please specify a title for the post with the -t option" unless title

	res = c.post! entry
	puts "--entry--"
	puts entry

	puts "--response--"
	puts res 

	puts "--url--"
	puts Atom::Entry.parse(res.read_body).edit_url
when :put
	entry.edit_url = entry_id
	res = c.put! entry
when :delete
	entry.edit_url = entry_id
	res = c.delete! entry
end

