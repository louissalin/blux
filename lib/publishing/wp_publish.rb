#!/usr/bin/env ruby
## Copyright (c) 2007 John Mettraux
## Copyright 2010 Louis-Philippe Salin de l'Etoile, aka Louis Salin
##
## Released under the MIT license
## http://www.opensource.org/licenses/mit-license.php
##
## This file is part of Blux.
##
## Modifications by Louis Salin, October 2010
## => reading blog information from the configuration file
## => splitting out option parsing and refactoring functionnality into methods
## => added delete and put REST commands

require 'net/http'
require 'atom/entry' # sudo gem install atom-tools
require 'atom/collection'
require File.join(File.expand_path(File.dirname(__FILE__)), "..", "blux_config_reader")
require File.join(File.expand_path(File.dirname(__FILE__)), "wp_options")

# a great thanks to the devs of all the libs used here
# some info about you and your blog

def delete(options, base, username, password)
	entry = Atom::Entry.new
	entry.updated!
	entry.edit_url = options.entry_id

	h = Atom::HTTP.new
	h.user = username
	h.pass = password
	h.always_auth = :basic

	c = Atom::Collection.new(base + "/posts", h)
	res = c.delete! entry

	return entry, res
end

def get_content
	content = ""
	loop do
		line = STDIN.gets
		break unless line
		content += line
	end

	content
end

def publish_or_update(command, options, username, password, base, bloguri, authorname)
	raise "please specify a title for the post with the -t option" unless options.title
	content = get_content

	entry = Atom::Entry.new
	entry.title = options.title
	entry.updated!

	author = Atom::Author.new
	author.name = authorname
	author.uri = bloguri
	entry.authors << author

	options.tags.each do |t|
		c = Atom::Category.new
		c["scheme"] = bloguri
		c["term"] = t.strip
		entry.categories << c
	end

	entry.content = content
	entry.content["type"] = options.type if options.type

	h = Atom::HTTP.new
	h.user = username
	h.pass = password
	h.always_auth = :basic

	c = Atom::Collection.new(base + "/posts", h)

	if command == :post
		res = c.post! entry
	elsif command == :put
		entry.edit_url = options.entry_id
		res = c.put! entry
	end

	return entry, res
end

WPOptionParser.parse(ARGV) do |options|
	config = BluxConfigurationReader.new
	config.load_config options.bluxrc

	blog = config.blog
	authorname = config.author_name
	username = config.user_name
	password = config.password

	bloguri = "http://#{blog}"
	base = "https://#{blog}/wp-app.php"

	case(options.command)
	when :post
		entry, res = publish_or_update(:post, options, username, password, 
									   		  base, bloguri, authorname)
		puts "--entry--"
		puts entry

		puts "--response--"
		puts res 

		puts "--url--"
		puts Atom::Entry.parse(res.read_body).edit_url
	when :put
		entry, res = publish_or_update(:put, options, username, password, 
									   	     base, bloguri, authorname)
		puts "--entry--"
		puts entry

		puts "--response--"
		puts res 
	when :delete
		entry, res = delete(options, base, username, password)

		puts "--entry--"
		puts entry

		puts "--response--"
		puts res 
	end
end
