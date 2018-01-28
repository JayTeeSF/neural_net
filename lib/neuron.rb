require 'json'
require_relative "activation_function"
require_relative "connection"

class Neuron
  ETA = 0.9   # learning rate
  ALPHA = 0.14 # momentum rate

  attr_accessor :error, :output
  attr_reader :activation_function_map, :dendrites, :name, :gradient
  def initialize(layer=[], opts={})
    @name = opts[:name]
    #@name += 'bias' if layer.empty?

    @error = 0.0
    @output = 0.0
    @gradient = 0.0
    @dendrites=[]
    layer.each { |neuron|
      @dendrites << Connection.new(neuron)
    }
    @activation_function_map = opts[:activation_function_map] || ActivationFunction.default_map
  end

  def add_error(extra)
    @error += extra
  end

  def feed_forward
    # bias neuron's already have a predefined output value
    return if @dendrites.size == 0

    sum_of_outputs = @dendrites.reduce(0) { |current_sum, dendrite|
      current_sum += dendrite.connected_neuron.output * dendrite.weight
    }
    @output = @activation_function_map[:forward].call(sum_of_outputs)
  end

  def back_propagate
    @gradient = @error * @activation_function_map[:back].call(@output)
    @dendrites.each { |dendrite|
      dendrite.delta_weight = ETA * (dendrite.connected_neuron.output * @gradient) + (ALPHA * dendrite.delta_weight)
      dendrite.weight += dendrite.delta_weight
      dendrite.connected_neuron.add_error(@gradient * dendrite.weight)
    }
    @error = 0.0
  end
end
