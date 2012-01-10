# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{erector_cache}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Grockit"]
  s.date = %q{2011-01-27}
  s.description = %q{Caching for your Erector}
  s.email = %q{mmol@grockit.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "erector_cache.gemspec",
    "lib/erector_cache.rb",
    "lib/erector_cache/fragment.rb",
    "lib/erector_cache/widget.rb",
    "spec/erector_cache/fragment_spec.rb",
    "spec/erector_cache/widget_spec.rb",
    "spec/erector_cache_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/grockit/erector_cache}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Caching for your Erector}
  s.test_files = [
    "spec/erector_cache/fragment_spec.rb",
    "spec/erector_cache/widget_spec.rb",
    "spec/erector_cache_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.6"])
      s.add_runtime_dependency(%q<lawnchair>, [">= 0.6.8"])
      s.add_runtime_dependency(%q<erector>, [">= 0.8.1"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.6"])
      s.add_dependency(%q<lawnchair>, [">= 0.6.8"])
      s.add_dependency(%q<erector>, [">= 0.8.1"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.6"])
    s.add_dependency(%q<lawnchair>, [">= 0.6.8"])
    s.add_dependency(%q<erector>, [">= 0.8.1"])
  end
end

