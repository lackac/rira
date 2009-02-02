# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rira}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["L\303\241szl\303\263 B\303\241csi"]
  s.date = %q{2009-02-02}
  s.description = %q{Nice interface for Jira, the Ruby way.}
  s.email = %q{lackac@lackac.hu}
  s.files = ["VERSION.yml", "lib/rira.rb", "test/rira_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/lackac/rira}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Nice interface for Jira, the Ruby way.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
