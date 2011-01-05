#!/usr/bin/env ruby
#
# Copyright 2011 Louis-Philippe Salin de l'Etoile, aka Louis Salin
# email: louis.phil@gmail.com
#
# This file is part of Blux.
#
# Blux is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Blux is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Blux.  If not, see <http://www.gnu.org/licenses/>.

require 'parseconfig'

module Blux
	class Config
		def initialize(data={})
			@data = {}
			update!(data)
		end

		def update!(data)
			data.each do |key, value|
				self[key] = value
			end
		end

		def [](key)
			@data[key.to_sym]
		end

		def []=(key, value)
			if value.class == Hash
				@data[key.to_sym] = Config.new(value)
			else
				@data[key.to_sym] = value
			end
		end

		def method_missing(sym, *args)
			if sym.to_s =~ /(.+)=$/
				self[$1] = args.first
			else
				self[sym]
			end
		end
	end


	class ConfigReader
		attr_reader :config

		CONFIG_FILENAME = '/.bluxrc'
		EDITOR_CMD_KEY = 'editor_cmd'

		def get_config
			config = Config.new
			config.editor_cmd = 'vi'

			config_path = "#{ENV['HOME']}#{CONFIG_FILENAME}"
			override_default_values(config, config_path) if File.exists?(config_path)

			config
		end

	private
		def override_default_values(config, config_path)
			config_parser = ParseConfig.new config_path
			config.editor_cmd = config_parser.params[EDITOR_CMD_KEY]
		end
	end
end
