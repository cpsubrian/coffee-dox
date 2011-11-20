###
Load a fixture.
###
fs = require 'fs'

module.exports = (name) ->
  return () ->
    fs.readFile(__dirname + '/../fixtures/' + name, 'utf8', @callback)