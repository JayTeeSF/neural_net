require_relative "neuron"

require 'json'
class Net
  attr_accessor :input_sets
  def initialize(bias_enabled=false, *topology)
    @bias_enabled = bias_enabled
    clear_input_sets
    @layers = []
    topology = topology.flatten.map(&:to_i)
    last_layer_idx = topology.size - 1
    topology.each_with_index do |num_neurons, layer_idx|
      layer = []
      previous_layer = @layers[-1]
      (0..(num_neurons - 1)).each do |n|
        opts = {name: "Layer##{layer_idx}-neuron##{n}"}
        layer << Neuron.new(previous_layer || [], opts)
      end
      if @bias_enabled
        unless layer_idx == last_layer_idx
          opts = {name: "Layer##{layer_idx}-(bias)neuron##{num_neurons}"}
          layer << Neuron.new([], opts) # bias-neuron that always returns 1, as part of every layer (except last-layer)
        end
      end
      @layers << layer
    end
  end

  def feed_forward
    last_layer_idx = @layers.size - 1
    @layers.each_with_index do |layer, layer_idx|
      layer.each do |neuron|
        neuron.feed_forward
      end
      if @bias_enabled
        unless layer_idx == last_layer_idx
          layer.last.output = 1 # set bias neuron of each layer (except last -- where there is no bias-neuron)
        end
      end
    end
  end

  def back_propagate(targets)
    # set the error for each output neuron
    errors(targets) { |error, idx| output_layer[idx].error = error }
    @layers.reverse.each do |layer|
      layer.each do |neuron|
        neuron.back_propagate
      end
    end
  end

  def average_squared_error(targets)
    _average_squared_error = 0
    errors(targets) { |error, _idx|
      _average_squared_error += (error * error)
    }
    _average_squared_error /= targets.size

    return _average_squared_error
  end

  def outputs
    _outputs = []
    output_layer.each_with_index do |output_neuron, idx|
      _outputs << { output_neuron.name => output_neuron.output }
    end
    _outputs
  end

  def inputs
    _inputs = []
    input_layer.each_with_index do |input_neuron, idx|
      _inputs << { input_neuron.name => input_neuron.output }
    end
    _inputs
  end

  def prompt_for_inputs
    set_num = 0
    loop do
      inputs = []
      bias_neuron_idx = input_layer.size - 1
      input_layer.each_with_index do |input_neuron, idx|
        if idx < bias_neuron_idx # skip the bias neuron
          input = prompt("What value would you like to use for input neuron ##{idx}, in your #{nth(set_num)} input set? ")
          input = valid_value?(input) ? input.to_f : nil
          inputs << input
        end
      end
      @input_sets << inputs

      continue = prompt("Would you like to specify another set of inputs? [Y|N] ")
      break if continue.downcase[0] != "y"

      set_num += 1
    end
  end

  def set_inputs(inputs=[])
    # inputs *probably* shouldn't include the bias-neuron (though if it gets a 1, it doesn't matter)!
    (0..(inputs.size - 1)).each do |idx|
      input_layer[idx].output = inputs[idx]
    end
  end

  def prompt(message)
    print message
    response = STDIN.gets.chomp.strip
    puts
    return response
  end

  def output_layer
    @layers[-1]
  end

  def input_layer
    @layers[0]
  end

  def to_s
    to_json.to_s
  end

  def to_json
    to_data.to_json
  end

  def to_data
    neurons = []
    @layers.each_with_index do |layer, layer_idx|
      layer.each_with_index do |neuron, neuron_idx|
        neurons << {
          neuron: neuron.name,
          output: neuron.output,
          gradient: neuron.gradient,
          error: neuron.error,
          activation_function: neuron.activation_function_map[:name],
          connections: neuron.dendrites.map(&:to_data)
        }
      end
    end

    return {
      bias_enabled: @bias_enabled,
      neurons: neurons
    }
  end

  def valid_value?(value)
    value && ((value.to_i.to_s == value) || (value.to_f.to_s == value))
  end

  private

  def clear_input_sets
    @input_sets = []
  end

  def errors(targets, &block)
    return unless block_given?
    (0..(output_layer.size - 1)).each do |idx|
      error = targets[idx] - output_layer[idx].output
      block.call(error, idx)
    end
  end

  def nth(num)
    case num
    when 1
      "1st"
    when 2
      "2nd"
    when 3
      "3rd"
    else
      "#{num}th"
    end
  end
end
