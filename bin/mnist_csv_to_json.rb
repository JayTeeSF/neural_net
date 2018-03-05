#!/usr/bin/env ruby

require 'set'
require 'csv'
DATA_FILE_FMT = "#{__dir__}/../data/mnist_%s.csv".freeze

if ARGV[0] =~ /help/
  puts "#{$0} [help|train|pretrain|test] [<max_avg_err 0.1>] [hidden_layer_sizes 64]"
  # apparently 15 doesn't work, but 64 does!!!
  exit
end

activation_function = "sigmoid"
bias_enabled = true

file_type = ARGV.shift
warn "GOT ARG: >>#{file_type.inspect}<<"
if "pretrain" == file_type
  file_type = "pretrain"
  csv_data_file = DATA_FILE_FMT % "train" # no pre-train csv exists (yet)
elsif "train" == file_type
  file_type = "train"
  csv_data_file = DATA_FILE_FMT % file_type
elsif "test" == file_type
  csv_data_file = DATA_FILE_FMT % file_type
end

max_avg_err = (ARGV.shift || 0.1).to_f
hidden_layer_sizes = ARGV
if hidden_layer_sizes.empty?
  hidden_layer_sizes = [64]
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
  "debug": #{"pretrain" == file_type},
  "one_time": #{"pretrain" != file_type},
  "activation_function": "#{activation_function}",
  "bias_enabled": #{bias_enabled},
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

  one_of_each_digit = Set.new([])
  expected_digits = []
  first_time = true
  CSV.foreach(csv_data_file) do |row|
    expected_digit = row[0]
    if "pretrain" == file_type
      if 10 == one_of_each_digit.size
        break
      end
      if one_of_each_digit.include?(expected_digit)
        next
      end
      one_of_each_digit << expected_digit
    end
    if !first_time
      f.puts ","
    end
    expected_digits << expected_digit
    f.print "[" + row[1..-1].join(", ") + "]"
    if first_time
      first_time = false
    end
  end

  f.puts <<-EOMID
  ],
  EOMID
  f.puts '"target_labels": [' +  expected_digits.join(",\n") + "],"
  f.puts '"targets": [' + "[\n" + expected_digits.map{|d| to_target(d).map(&:to_f).join(",\n") }.join("\n],\n[\n") + "\n] ]"
  f.puts <<-EOBOTTOM
  }
  EOBOTTOM
}

warn "done."
