fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'

option '-s', '--spec', 'Use vows spec mode'

build = (watch, callback) ->
  if typeof watch is 'function'
    callback = watch
    watch = false
  options = ['-c', '-o', 'lib', 'src']
  options.unshift '-w' if watch

  coffee = spawn 'coffee', options
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()
  coffee.on 'exit', (status) -> callback?() if status is 0

task 'build', 'Compile CoffeeScript source files', ->
  build()

task 'watch', 'Recompile CoffeeScript source files when modified', ->
  build true

task 'test', 'Run Vows tests', (options) ->
  command = "vows test/*.coffee" + (if options.spec then " --spec" else "")
  exec command, (err, stdout, stderr) ->
    console.log("> #{command}")
    console.log(stdout)
    console.log(stderr)