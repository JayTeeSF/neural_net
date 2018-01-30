#!/usr/bin/env ruby

require 'csv'
DATA_FILE_FMT = "#{__dir__}/../data/mnist_%s.csv".freeze

if ARGV[0] =~ /help/
  puts "#{$0} [help|train|test] [<max_avg_err 0.1>] [hidden_layer_sizes 15]"
  exit
end

file_type = ARGV.pop
if file_type =~ /train/
  file_type = "train"
  csv_data_file = DATA_FILE_FMT % "train"
else
  file_type = "test"
  csv_data_file = DATA_FILE_FMT % "test"
end

max_avg_err = (ARGV.pop || 0.1).to_f
hidden_layer_sizes = ARGV
if hidden_layer_sizes.empty?
  hidden_layer_sizes = [15]
end

warn "Using the '%s' data file: #{csv_data_file}" % file_type

json_file_name = "#{__dir__}/../data/mnist_%s.json" % file_type
warn "Outputting network description to file: #{json_file_name}"

def to_target(expected_digit)
  case expected_digit.to_i
  when 0
    [1,0,0,0,0,0,0,0,0,0]
  when 1
    [0,1,0,0,0,0,0,0,0,0]
  when 2
    [0,0,1,0,0,0,0,0,0,0]
  when 3
    [0,0,0,1,0,0,0,0,0,0]
  when 4
    [0,0,0,0,1,0,0,0,0,0]
  when 5
    [0,0,0,0,0,1,0,0,0,0]
  when 6
    [0,0,0,0,0,0,1,0,0,0]
  when 7
    [0,0,0,0,0,0,0,1,0,0]
  when 8
    [0,0,0,0,0,0,0,0,1,0]
  else
    [0,0,0,0,0,0,0,0,0,1]
  end
end

File.open(json_file_name, "w") {|f|
  f.puts <<-EOTIPTOP
{
  "debug": false,
  "one_time": true,
  "bias_enabled": false,
  "topology": [
    784,
  EOTIPTOP

  f.puts hidden_layer_sizes.join(",\n") + ",\n"

  f.puts <<-EOTOP
    10
  ],
  "max_avg_sq_error": #{max_avg_err},
  "inputs": [
  EOTOP

  expected_digits = []
  first_time = true
  CSV.foreach(csv_data_file) do |row|
    if !first_time
      f.puts ","
    end
    expected_digits << row[0]
    f.print "[" + row[1..-1].join(", ") + "]"
    if first_time
      first_time = false
    end
  end

  f.puts <<-EOMID
  ],
  EOMID
  f.puts '"target_labels": [' + "[\n" + expected_digits.join(",\n") + "\n] ],"
  f.puts '"targets": [' + "[\n" + expected_digits.map{|d| to_target(d).join(",\n") }.join("\n],\n[\n") + "\n] ]"
  f.puts <<-EOBOTTOM
  }
  EOBOTTOM
}

warn "done."
