Create a .json file, e.g.:
./data/or_gate.json

Then run it as a neural net:
./bin/neural_net.rb ./data/or_gate.json

# Download MNIST csv(s):
  https://pjreddie.com/media/files/mnist_train.csv
  https://pjreddie.com/media/files/mnist_test.csv


# Train on MNIST data:
↪ time ./bin/mnist_csv_to_json.rb train
↪ ./bin/neural_net.rb ./data/mnist_train.json

# FIXME: this depends on being able to save the trained net?!
# Test MNIST 
↪ time ./bin/mnist_csv_to_json.rb test
↪ ./bin/neural_net.rb ./data/mnist_test.json

# TODO:
  update input to be closer to output, i.e.:
  ./output/initial_unbiased_or_gate.json

  a)
  # include (optional) connections & weights
  # that way a trained net can be saved and restored for use later...

  b)
  # activation function specified (by name)

  c)
  # visualize output (not just JSON, but html/css OR canvas)
