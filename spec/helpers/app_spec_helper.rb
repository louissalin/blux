require 'config'

module AppSpecHelper
	def stub_config_reader
		Blux::ConfigReader.class_eval do
			alias :old_read_config :read_config

			def read_config
				config = Blux::Config.instance
				config.editor_cmd = 'some_editor_cmd'
			end
		end
	end

	def restore_config_reader
		Blux::ConfigReader.class_eval do
			alias :read_config :old_read_config
		end
	end
end
