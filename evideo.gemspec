# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'evideo/version'

Gem::Specification.new do |spec|
  spec.name        = 'evideo'
  spec.version     = Evideo::VERSION
  spec.authors     = ['Hernâni Rodrigues Vaz']
  spec.email       = ['hernanirvaz@gmail.com']
  spec.homepage    = 'https://github.com/hernanilr/evideo'
  spec.license     = 'MIT'
  spec.summary     = 'Processa ficheiros video.'
  spec.description = "#{spec.summary} Pode alterar bitrate, framerate, height, aspect ratio e elimina metadata."

  spec.required_ruby_version    = Gem::Requirement.new('~> 3.1')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['yard.run']     = 'yard'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('reek')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rufo')
  spec.add_development_dependency('solargraph')
  spec.add_development_dependency('yard')

  spec.add_dependency('thor')
end
