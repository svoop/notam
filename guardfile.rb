clearing :on
scope group: "spec"

def watches
  watch(%r{^spec/(.+)_spec\.rb})
  watch(%r{^lib/(.+)\.rb}) { "spec/lib/#{it[1]}_spec.rb" }
  watch(%r{^spec/(spec_helper|factory)\.rb}) { 'spec' }
end

group :spec do
  guard(:minitest, bundler: true) { watches }
end

group :fu do
  guard(:minitest, bundler: true, cli: "-i/FU/") { watches }
end
