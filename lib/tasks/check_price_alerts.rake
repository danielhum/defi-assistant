desc "task to check prices and alert if applicable"
task :check_price_alerts => :environment do
  puts "Checking prices..."
  PriceAlertJob.perform_now
  puts "Done."
end
