# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{Blux}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Louis Salin"]
  s.date = %q{2010-10-10}
  s.description = %q{An offline blog manager}
  s.email = %q{louis.phil@gmail.com}
  s.extra_rdoc_files = ["COPYING", "README.markdown", "lib/blog_manager.rb", "lib/blux.rb", "lib/blux_config_reader.rb", "lib/blux_option_parser.rb", "lib/draft_manager.rb", "lib/indexer.rb", "lib/textile_to_html.rb", "lib/wp_publish.rb"]
  s.files = ["COPYING", "Manifest", "README.markdown", "Rakefile", "lib/blog_manager.rb", "lib/blux.rb", "lib/blux_config_reader.rb", "lib/blux_option_parser.rb", "lib/draft_manager.rb", "lib/indexer.rb", "lib/textile_to_html.rb", "lib/wp_publish.rb", "spec/blog_manager_spec.rb", "spec/blux_config_reader_spec.rb", "spec/draft_manager_spec.rb", "Blux.gemspec"]
  s.homepage = %q{http://github.com/louissalin/blux}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Blux", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{blux}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{An offline blog manager}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<OptionParser>, [">= 0.5.1"])
      s.add_development_dependency(%q<atom-tools>, [">= 2.0.5"])
      s.add_development_dependency(%q<json>, [">= 1.4.6"])
      s.add_development_dependency(%q<RedCloth>, [">= 4.2.3"])
    else
      s.add_dependency(%q<OptionParser>, [">= 0.5.1"])
      s.add_dependency(%q<atom-tools>, [">= 2.0.5"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<RedCloth>, [">= 4.2.3"])
    end
  else
    s.add_dependency(%q<OptionParser>, [">= 0.5.1"])
    s.add_dependency(%q<atom-tools>, [">= 2.0.5"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<RedCloth>, [">= 4.2.3"])
  end
end
