# frozen_string_literal: true

gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'notam')

require 'minitest/flash'
require 'minitest/focus'

require Pathname(__dir__).join('factory')

class Minitest::Spec
  class << self
    alias_method :context, :describe
  end
end

I18n.locale = :en

def prepare_fixtures
  require 'rake'
  load Pathname(__dir__).join('..', 'lib', 'tasks', 'fixtures.rake')
  ENV['PRESERVE_FIXTURES'] = 'true'
  Rake.application.invoke_task('fixtures:fetch')
end

$debug_info = []
Minitest.after_run do
  puts nil, $debug_info.join("\n\n") if $debug_info.any?
end
