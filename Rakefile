require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('Blux', '0.0.3') do |p|
	p.description = 'An offline blog manager'
	p.url = 'http://github.com/louissalin/blux'
	p.author = 'Louis Salin'
	p.email = 'louis.phil@gmail.com'
	p.ignore_pattern = ["tags", "TODO", "plan", "gem-public_cert.pem"]
	p.development_dependencies = ["OptionParser >=0.5.1",
								  "atom-tools >=2.0.5",
								  "json >=1.4.6",
								  "RedCloth >=4.2.3"]
	p.runtime_dependencies = ["OptionParser >=0.5.1",
							  "atom-tools >=2.0.5",
							  "json >=1.4.6",
							  "RedCloth >=4.2.3"]
end
