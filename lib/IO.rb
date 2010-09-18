module BluxOutput
	def set_io(io = {})
		@io = io[:std] || STDOUT
		@err = io[:err] || STDERR
	end
end
