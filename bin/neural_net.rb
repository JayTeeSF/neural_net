#!/usr/bin/env ruby

require_relative "../lib/net"

if __FILE__ == $PROGRAM_NAME
  net = nil
  # FIXME: read-in data from some JSON file or stream...
  if ARGV.first && File.exist?(ARGV.first)
    require 'json'
    raw_json = File.read(ARGV.first)
    net_info = JSON.parse(raw_json)
    #puts "net_info: #{net_info.inspect}"

    bias_enabled = net_info["bias_enabled"] || false
    topology = net_info["topology"]
    warn "Setting up your Neural Net w/ the following topology (i.e. number of neurons per layer): #{topology.inspect}"
    net = Net.new(bias_enabled, topology)

    net.input_sets = net_info["inputs"]

    max_average_squared_error = net_info["max_avg_sq_error"]
    fail("Invalid max_average_squared_error value") if max_average_squared_error.nil?

    warn "DEBUG - output node-count: #{net.output_layer.size}; #{net.output_layer.map(&:name).inspect}"
    targets = net_info["targets"]
  else
    warn "Input a json file as the first (and only) arg, in order to speed-up this setup process"
    bias_enabled = false
    topology = [2,3,5,1]

    warn "Setting up your Neural Net w/ the following topology (i.e. number of neurons per layer): #{topology.inspect}"
    net = Net.new(bias_enabled, topology)
    net.input_sets = [[0,0],[0,1],[1,0],[1,1]]
    max_average_squared_error = 0.01
    targets = [0,1,1,1]
  end

  warn "Your Net looks as follows:"
  warn "#{net}\n"

  warn "Let the training begin..."
  loop_idx = 0
  print_now = true
  err = 0
  # FIXME: figure-out how to display the net (i.e. it's adjusting weights)...
  loop do
    #avg_sq_errors = []
    (0..(net.input_sets.size - 1)).each do |idx|
      current_inputs = net.input_sets[idx]
      warn "idx/inputs: #{idx}/#{current_inputs.inspect}" if print_now
      net.set_inputs(current_inputs)
      if print_now
        io = ""
        net.inputs.each do |input|
          io << "#{input.keys.first}:  #{input.values.first}\n"
        end
        warn io
      end

      net.feed_forward
      if print_now
        io = ""
        net.outputs.each do |output|
          io << "\t=> #{output.keys.first}: #{output.values.first}\n"
        end
        warn io
      end

      net.back_propagate(targets[idx])
      err += net.average_squared_error(targets[idx])
      #avg_sq_errors << net.average_squared_error(targets[idx])
      if print_now
        warn "\tAverage Squared Error: #{net.average_squared_error(targets[idx])}"
      end
    end
    err /= net.input_sets.size
    break if err < max_average_squared_error #avg_sq_errors.all?{|avg| avg <= max_average_squared_error}
    loop_idx += 1
    print "." unless print_now
    puts() if (0 == (loop_idx % 1_000))
    if print_now
      print_now = false
      puts
    end
    print_now = true if (0 == (loop_idx % 10_000))
  end
  warn "Done."

  warn "Congrats you're network is tuned!"
  warn " *** *** *** *** *** *** *** "
  (0..(net.input_sets.size - 1)).each do |idx|
    net.set_inputs(net.input_sets[idx])
    net.feed_forward
    io = ""
    net.inputs.each do |input|
      io << "#{input.keys.first}:  #{input.values.first}\n"
    end
    net.outputs.each do |output|
      io << "\t=> #{output.keys.first}: #{output.values.first}\n"
    end
    warn io
    #  warn "#{input} => #{net.outputs[input_idx]}"
    warn "\tAverage Squared Error: #{net.average_squared_error(targets[idx])}"
  end
  warn " *** *** *** *** *** *** *** "
  warn "Your Final Net looks like:"
  warn "#{net}\n"
end
