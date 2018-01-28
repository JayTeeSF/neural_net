require 'json'
class Connection
  STARTING_WEIGHTS = [0.09, 0.1, 0.13].freeze
  attr_reader :connected_neuron
  attr_accessor :weight, :delta_weight
  def initialize(connected_neuron)
    @connected_neuron = connected_neuron
    @weight = STARTING_WEIGHTS.sample
    @delta_weight = 0.0
  end

  def to_s
    to_json.to_s
  end

  def to_json
    to_data.to_json
  end
  def to_data
    _data = {
      connected_neuron: connected_neuron.name,
      weight: weight,
      delta_weight: delta_weight
    }

    return _data
  end
end
