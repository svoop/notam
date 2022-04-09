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
