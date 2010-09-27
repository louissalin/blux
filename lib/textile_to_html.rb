#!/usr/bin/env ruby

require 'redcloth'

ARGF.each do |line|
	STDOUT.puts RedCloth.new(line).to_html
end
