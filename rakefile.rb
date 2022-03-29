require 'fileutils'
require 'net/http'

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['spec/lib/**/*_spec.rb']
  t.verbose = false
  t.warning = !ENV['RUBYOPT']&.match?(/-W0/)
end

namespace :yard do
  desc "Run local YARD documentation server"
  task :server do
    `rm -rf ./.yardoc`
    Thread.new do
      sleep 2
      `open http://localhost:8808`
    end
    `yard server -r`
  end
end

namespace :fixtures do
  desc "Fetch new test NOTAM fixtures for comma separated ICAO codes from DINS "
  task :fetch, [:icao_codes] do |_, args|
    icao_codes = (args[:icao_codes] || 'LFXX,EDXX,LSAS').gsub(/\W+/, ' ')
    fixtures_path.mkdir unless fixtures_path.exist?
    response = Net::HTTP.post_form(
      URI('https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do'),
      actionType: 'notamRetrievalByICAOs',
      reportType: 'Raw',
      retrieveLocId: icao_codes
    ).tap do |response|
      fail "bad response from DINS" unless response.code == '200'
      response.body.scan(/<pre>(.+?)<\/pre>/im) do |message|
        id = message.first.split(/\s/, 2).first.sub(/\W+/, '_')
        File.write(fixtures_path.join("#{id}.txt"), message.first)
      end
    end
  end

  desc "Clean current test NOTAM fixtures"
  task :clean do
    fixtures_path.rmtree if fixtures_path.exist?
  end

  def fixtures_path
    Pathname(Dir.pwd).join('spec', 'fixtures')
  end
end

Rake::Task[:test].enhance do
  if ENV['RUBYOPT']&.match?(/-W0/)
    puts "⚠️  Ruby warnings are disabled, remove -W0 from RUBYOPT to enable."
  end
end

task default: :test
