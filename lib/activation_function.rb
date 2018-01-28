class ActivationFunction
  def self.default_map(alpha=nil)
    sigmoid(alpha)
  end

  def self.sigmoid(alpha=nil)
    {
      name: "sigmoid",
      forward: ->(x) {
        _sigmoid(x)
      },
      back: ->(x) {
        _derivative_of_sigmoid(x)
      },
    }
  end

  def self.relu(alpha=nil)
    if alpha.nil?
    {
      name: "ReLu",
      forward: ->(x) {
        x < 0 ? 0 : x
      },
      back: ->(x) {
        x < 0 ? 0 : 1
      },
    }
    else
      l_relu(alpha)
    end
  end

  def self.tanh(alpha=nil)
    {
      name: "tanH",
      forward: ->(x) {
        Math.tanh(x)
      },
      back: ->(x) {
        1 - (Math.tanh(x) ** 2)
      },
    }
  end

  # private

  def self._sigmoid(x)
    1.0 / (1.0 + Math.exp(-x))
  end

  def self._derivative_of_sigmoid(x)
    #sig = _sigmoid(x)
    #sig * (1.0 - sig)
    x * (1 - x)
  end

  def self.l_relu(alpha)
    {
      name: "Leaky ReLu",
      forward: ->(x) {
        x < 0 ? alpha*x : x
      },
      back: ->(x) {
        x < 0 ? alpha : 1
      },
    }
  end
end
