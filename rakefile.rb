require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ["spec/**/*_spec.rb"]
  t.verbose = false
  t.warning = !ENV['RUBYOPT']&.match?(/-W0/)
end

Rake::Task[:test].enhance do
  if ENV['RUBYOPT']&.match?(/-W0/)
    puts "⚠️  Ruby warnings are disabled, remove -W0 from RUBYOPT to enable."
  end
end

task default: :test

Pathname(Dir.pwd).join('lib', 'tasks').glob('*.rake') { load _1 }
