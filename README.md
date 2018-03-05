# Create a .json file, e.g.:
./data/or_gate.json

```
  {
    "bias_enabled": false,
    "topology": [ 2, 3, 5, 1 ],
    "max_avg_sq_error": 0.001,
    "inputs": [
      [ 0, 0 ],
      [ 0, 1 ],
      [ 1, 0 ],
      [ 1, 1 ]
    ],
    "targets": [ 0, 1, 1, 1 ]
  }
```


Then run it as a neural net:
```
./bin/neural_net.rb ./data/or_gate.json
```

## Download MNIST csv(s):
```
  https://pjreddie.com/media/files/mnist_train.csv
  https://pjreddie.com/media/files/mnist_test.csv
```

Convert MNIST data to a JSON formatted neural net spec:
```
↪ time ./bin/mnist_csv_to_json.rb pretrain 0.01 64 # quick -- see some quick progress
↪ time ./bin/mnist_csv_to_json.rb train # final - takes longer
```

![alt text](https://github.com/JayTeeSF/neural_net/raw/master/data/mnist_0-9.png "Example of the MNIST handwritten digits")

PreTrain on MNIST data:
(just to see some progress, on recognizing _some_ digits 0 - 9):
  ./bin/neural_net.rb ./data/mnist_pretrain.json

Train on MNIST data:
```
↪ ./bin/neural_net.rb ./data/mnist_train.json
```

FIXME: this depends on being able to save the trained net?!
Convert MNIST data to a JSON formatted neural net spec:
```
↪ time ./bin/mnist_csv_to_json.rb test
```

Test MNIST 
```
↪ ./bin/neural_net.rb ./data/mnist_test.json
```

## TODO:
  update input to be closer to output, i.e.:
  ./output/initial_unbiased_or_gate.json

  a) include (optional) connections & weights
  that way a trained net can be saved and restored for use later...

  ~~b) activation function specified (by name)~~

  ~~c) visualize output (not just JSON, but html/css OR canvas)~~
