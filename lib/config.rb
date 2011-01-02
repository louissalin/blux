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
	class ConfigSettings
		attr_accessor :editor_cmd

		DEFAULT_EDITOR_CMD = 'vi'

		def initialize
			@editor_cmd = DEFAULT_EDITOR_CMD
		end
	end

	class ConfigReader
		attr_reader :config

		CONFIG_FILENAME = '/.bluxrc'
		EDITOR_CMD_KEY = 'editor_cmd'

		def initialize
			@config = ConfigSettings.new
			@config_path = "#{ENV['HOME']}#{CONFIG_FILENAME}"

			override_default_values if File.exists?(@config_path)
		end

		def override_default_values
			config = ParseConfig.new @config_path
			@config.editor_cmd = config.params[EDITOR_CMD_KEY]
		end
	end
end
