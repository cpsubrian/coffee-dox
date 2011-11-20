###
Parse string vows into should.js assertions.

Example Usage:

    vows.describe('quickVows Example').addBatch

      'My context description': quickVows
        topic: {name: 'myTopic', size: 15, colors: ['blue', 'green']}
        'the name should equal': 'myTopic'
        'the size should equal': 15
        'the colors should be an instaceOf': Array
        'the colors should eql': ['blue', 'green']

In the vows property keys, 'the', 'it' and 'its' (at the beginning of the vow)
will be replaced with the topic.  The above example translates directly to:

    vows.describe('quickVows Example').addBatch

      'My context description':
        topic: {name: 'myTopic', size: 15, colors: ['blue', 'green']}

        "the name should equal 'myTopic': (topic) ->
          topic.name.should.equal 'myTopic'

        "the size should equal '15': (topic) ->
          topic.size.should.equal 15

        "the colors should be an instanceof 'function Array() { [native code] }": (topic) ->
          topic.colors.should.be.an.instanceof Array

        "the colors should eql 'blue,green'": (topic) ->
          topic.colors.should.eql ['blue', 'green']

Pretty cool huh?
###
module.exports = (convert) ->
  context = {}
  for own vow, arg of convert
    do (vow, arg) ->
      if vow is 'topic'
        context.topic = arg
      else
        context["#{vow} '#{arg}'"] = (topic) ->
          obj = topic
          scope = {}
          for part in vow.split(' ')
            if not /^(?:the|it|its)$/.test part
              obj = obj[part]
            if part is 'should'
              scope = obj
          if typeof obj is 'function'
            obj.call scope, arg
          else if /^(?:empty|arguments|ok|true|false)$/.test part
            # The assertion is already made.
          else
            throw new Error 'quickVow did not resolve into a function'
  context
