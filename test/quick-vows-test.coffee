###
Test usage of quick-vows.coffee.
###
vows = require 'vows'
quickVows = require './helpers/quick-vows'

# Create the test suite.
suite = vows.describe('QuickVows')

# Test quickVows
suite.addBatch
  'Testing quickVows': quickVows
    topic: {name: 'myTopic', size: 15, colors: ['blue', 'green']}
    'it should have property': 'name'
    'it should not have property': 'age'
    'the name should equal': 'myTopic'
    'its size should equal': 15
    'colors should be an instanceof': Array
    'the colors should eql': ['blue', 'green']

# Export the test suite
suite.export module
