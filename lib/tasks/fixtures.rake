require 'fileutils'
require 'net/http'
require_relative '../notam/message'
require_relative '../notam/translation'

namespace :fixtures do
  DEFAULT_FIRS = 'ED,LF,LO,LS'
  IGNORE = [
    'LFBB_R0188_24'   # broken - duplicate F item
  ]

  desc "Fetch new NOTAM fixtures for comma separated informal two letter ICAO FIR codes (default: #{DEFAULT_FIRS})"
  task :fetch, [:firs] do |_, args|
    unless ENV['PRESERVE_FIXTURES'] && fixtures_path.glob('*.txt').any?
      firs = (args[:firs] || DEFAULT_FIRS).split(/\W+/).map { NOTAM.expand_fir(_1) }.flatten
      Net::HTTP.post_form(
        URI('https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do'),
        actionType: 'notamRetrievalByICAOs',
        reportType: 'Raw',
        retrieveLocId: firs.join(' ')
      ).tap do |response|
        fail "bad response from DINS" unless response.code == '200'
        counter = 0
        response.body.scan(/<pre>(.+?)<\/pre>/im) do |message|
          message = message.first
          if NOTAM::Message.supported_format? message
            next unless message.match %r{^(\w+?)/(\w+?)\s+\w+\s+Q\)\s+(\w+?)/}
            name = [$3, $1, $2].join('_')
            next if IGNORE.include? name
            counter += 1
            File.write(fixtures_path.join(name + '.txt'), message)
          end
        end
        puts "#{counter} fixtures downloaded"
      end
    end
  end

  desc "Grep all NOTAM fixtures for the given item (default: D)"
  task :grep, [:item] do |_, args|
    item = (args[:item] || 'D').upcase
    fixtures_path.glob('*.txt').each do |fixture|
      text = File.read(fixture)
      if text.match(/\s(#{item}\).*?)[QA-G]\)/m)
        case item
          when 'D' then puts $1.gsub(/\s+/, ' ')
          when 'E' then puts $1, nil
          else puts $1
        end
      end
    end
  end

  desc "Clear current test NOTAM fixtures"
  task :clear do
    fixtures_path.rmtree
  end

  def fixtures_path
    Pathname(Dir.pwd).join('spec', 'fixtures').tap do |path|
      path.mkdir unless path.exist?
    end
  end
end
