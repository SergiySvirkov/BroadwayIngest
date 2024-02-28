# csv_generator.rb

require "csv"

# Generate a CSV file with 100 rows and 10 columns of random data
CSV.open("data.csv", "wb") do |csv|
  csv << (1..10).map { |i| "Column #{i}" } # Header row
  100.times do
    csv << (1..10).map { rand(100) } # Data row
  end
end
