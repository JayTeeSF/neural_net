class ActivationFunction
  def self.default_map(alpha=nil)
    sigmoid(alpha)
  end

  def self.fast(alpha=nil)
    {
      name: "fast",
      forward: ->(x) {
        x ||= x.to_f
        x / (1.0  + x.abs)
      },
      back: ->(x) {
        _derivative_of_sigmoid(x)
      },
    }
  end

  def self.sigmoid(alpha=nil)
    {
      name: "sigmoid",
      forward: ->(x) {
        x ||= x.to_f
        _sigmoid(x)
      },
      back: ->(x) {
        x ||= x.to_f
        _derivative_of_sigmoid(x)
      },
    }
  end

  def self.relu(alpha=nil)
    if alpha.nil?
    {
      name: "ReLu",
      forward: ->(x) {
        x ||= x.to_f
        x < 0.0 ? 0.0 : x
      },
      back: ->(x) {
        x ||= x.to_f
        x < 0.0 ? 0.0 : 1.0
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
        x ||= x.to_f
        Math.tanh(x)
      },
      back: ->(x) {
        x ||= x.to_f
        #1 - (Math.tanh(x) ** 2)
        1.0 - (x ** 2)
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
    # ah, the incoming "x" _is_ the sigmoid that was calculated in the feed-forward!!!
    x * (1.0 - x)
  end

  def self.l_relu(alpha=0.01)
    alpha ||= 0.01
    {
      name: "Leaky ReLu",
      forward: ->(x) {
        x < 0 ? alpha*x : x
      },
      back: ->(x) {
        x < 0 ? alpha : 1.0
      },
    }
  end
end
