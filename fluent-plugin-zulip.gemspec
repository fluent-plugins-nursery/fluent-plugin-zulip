lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-zulip"
  spec.version = "0.3.0"
  spec.authors = ["Kenji Okimoto"]
  spec.email   = ["okimoto@clear-code.com"]

  spec.summary       = %q{Fluentd output plugin for Zulip powerful open source group chat.}
  spec.description   = %q{Fluentd output plugin for Zulip powerful open source group chat.}
  spec.homepage      = "https://github.com/fluent-plugins-nursery/fluent-plugin-zulip"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "webrick"
  spec.add_runtime_dependency "fluentd", ">= 0.14.10", "< 2"
  spec.add_runtime_dependency "zulip-client", ">= 0.2.0"
end
