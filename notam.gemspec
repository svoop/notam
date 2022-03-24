# frozen_string_literal: true

require_relative "lib/notam/version"

Gem::Specification.new do |spec|
  spec.name = "notam"
  spec.version = NOTAM::VERSION
  spec.summary     = 'Parser for NOTAM (Notice to Airmen) messages'
  spec.description = <<~END
    Parser for NOTAM (Notice to Airmen) messages in Ruby.
  END
  spec.authors     = ['Sven Schwyn']
  spec.email       = ['ruby@bitcetera.com']
  spec.homepage    = 'https://github.com/svoop/notam'
  spec.license     = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'changelog_uri'     => 'https://github.com/svoop/notam/blob/main/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/svoop/notam',
    'documentation_uri' => 'https://www.rubydoc.info/gems/notam',
    'bug_tracker_uri'   => 'https://github.com/svoop/notam/issues'
  }

  spec.files         = Dir['lib/**/*']
  spec.require_paths = %w(lib)

  spec.cert_chain  = ["certs/svoop.pem"]
  spec.signing_key = File.expand_path(ENV['GEM_SIGNING_KEY']) if ENV['GEM_SIGNING_KEY']

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.rdoc_options    += [
    '--title', 'NOTAM Parser',
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_dependency 'aixm', '~> 1.1'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest-sound'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'
end
