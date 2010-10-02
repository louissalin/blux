#!/usr/bin/env ruby

## Copyright (c) 2007 John Mettraux
## Released under the MIT license
## http://www.opensource.org/licenses/mit-license.php
##
## Modifications by Louis Salin, October 2010
## => reading blog information from the configuration file

require 'optparse'
require 'net/http'

require 'rubygems'
require 'atom/entry' # sudo gem install atom-tools
require 'atom/collection'

# a great thanks to the devs of all the libs used here
#
# some info about you and your blog

blog = "louissalin"
authorname = "Louis Salin"
username = "louissalin"
password = "kazam!!!"

bloguri = "http://#{blog}.wordpress.com"
base = "https://#{blog}.wordpress.com/wp-app.php"

#
# parse options

tags = []
title = nil
type = 'html'

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
	"-h",
	"--help",
	"displays this help") do

	puts
	puts opts.to_s
	puts
	exit 0
	end

opts.parse ARGV

raise "please specify a title for the post with the -t option" unless title

#
# gather content

content = ""
loop do
	line = STDIN.gets
	break unless line
	content += line
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
res = c.post! entry

puts res.read_body

