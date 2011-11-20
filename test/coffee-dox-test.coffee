###
Vows tests for CoffeeDox
###

cdox = require '../'
should = require 'should'
vows = require 'vows'
fixture = require './helpers/fixture'
quickVows = require './helpers/quick-vows'

# Create the test suite.
suite = vows.describe('CoffeeDox')

# Test quickVows macro.
suite.addBatch
  'Testing quickVows': quickVows
    topic: {name: 'myTopic', size: 15, colors: ['blue', 'green']}
    'the name should equal': 'myTopic'
    'the size should equal': 15
    'the colors should be an instanceof': Array
    'the colors should eql': ['blue', 'green']

# App Tests
suite.addBatch
  'Application version':
    topic: cdox.version

    'should be a valid version string': (version) ->
      version.should.match /^\d+\.\d+\.\d+$/

# Parser Test
suite.addBatch
  'When reading a file with comment blocks':
    topic: fixture 'a.coffee'

    'and parsing it,':
      topic: (str) -> cdox.parseComments str

      'the file comment meta': quickVows
        topic: (comments) -> comments[0]
        'it should have property': 'ignore'
        'the ignore should be true': ''
        'the description full should equal': '<p>A<br />Copyright (c) 2010 Author Name &lt;Author Email&gt;<br />MIT Licensed</p>'
        'the description summary should equal': '<p>A<br />Copyright (c) 2010 Author Name &lt;Author Email&gt;<br />MIT Licensed</p>'
        'the description body should equal': ''
        'the tags should be empty': ''

      'the version comment meta': quickVows
        topic: (comments) -> comments[1]
        'it should have property': 'ignore'
        'the ignore should be false': ''
        'the description full should equal': '<p>Library version.</p>'
        'the description summary should equal': '<p>Library version.</p>'
        'the description body should equal': ''
        'the tags should be empty': ''

  'When reading a file with comment tags':
    topic: fixture 'b.coffee'

    'and parsing it,':
      topic: (str) -> cdox.parseComments str

      'the version comment meta': quickVows
        topic: (comments) -> comments[0]
        'the description summary should equal': '<p>Library version.</p>'
        'the description full should equal': '<p>Library version.</p>'
        'the tags should have length': 2
        'the tags 0 type should equal': 'type'
        'the tags 0 types should eql': ['String']
        'the tags 1 type should equal': 'api'
        'the tags 1 visibility should equal': 'public'
        'the ctx type should equal': 'property'
        'the ctx receiver should equal': 'exports'
        'the ctx name should equal': 'version'
        'the ctx value should equal': "'0.0.1'"

      'the parse comment meta': quickVows
        topic: (comments) -> comments[1]
        'the description summary should equal': '<p>Parse the given <code>str</code>.</p>'
        'the description body should equal': '<h2>Examples</h2>\n\n<pre><code>parse(str)\n// =&amp;gt; "wahoo"\n</code></pre>'
        'the description full should equal': '<p>Parse the given <code>str</code>.</p>\n\n<h2>Examples</h2>\n\n<pre><code>parse(str)\n// =&amp;gt; "wahoo"\n</code></pre>'
        'the tags 0 type should equal': 'param'
        'the tags 0 name should equal': 'str'
        'the tags 0 description should equal': 'to parse'
        'the tags 0 types should eql': ['String', 'Buffer']
        'the tags 1 type should equal': 'return'
        'the tags 1 types should eql': ['String']
        'the tags 2 visibility should equal': 'public'

  'When parsing complex comments,':
    topic: fixture 'c.coffee'

    'the parsed comments':
      topic: (str) -> cdox.parseComments str

      'should have the correct file meta': (comments) ->
        file = comments[0]
        file.tags.should.be.empty
        file.description.full.should.equal '<p>Dox<br />Copyright (c) 2011 Brian Link &lt;<a href=\'mailto:cpsubrian@gmail.com\'>cpsubrian@gmail.com</a>&gt;<br />MIT Licensed</p>'
        file.ignore.should.be.true

      'should have the correct mods meta': (comments) ->
        mods = comments[1]
        mods.tags.should.be.empty
        mods.description.full.should.equal '<p>Module dependencies.</p>'
        mods.description.summary.should.equal '<p>Module dependencies.</p>'
        mods.description.body.should.equal ''
        mods.ignore.should.be.false
        mods.code.should.equal 'markdown = require(\'github-flavored-markdown\').parse\n{escape} = require \'./utils\''
        mods.ctx.type.should.equal 'declaration'
        mods.ctx.name.should.equal 'markdown'
        mods.ctx.value.should.equal 'require(\'github-flavored-markdown\').parse'

      'should have the correct version meta': (comments) ->
        version = comments[2]
        version.tags.should.be.empty
        version.description.full.should.equal '<p>Library version.</p>'

      'should have the correct parseComments meta': (comments) ->
        parseComments = comments[3]
        parseComments.tags.should.have.length 4
        parseComments.ctx.type.should.equal 'method'
        parseComments.ctx.receiver.should.equal 'exports'
        parseComments.ctx.name.should.equal 'parseComments'
        parseComments.description.full.should.equal '<p>Parse comments in the given string of <code>js</code>.</p>'
        parseComments.description.summary.should.equal '<p>Parse comments in the given string of <code>js</code>.</p>'
        parseComments.description.body.should.equal ''

      'should have the correct parseComment meta': (comments) ->
        parseComment = comments[4]
        parseComment.tags.should.have.length 4
        parseComment.description.summary.should.equal '<p>Parse the given comment <code>str</code>.</p>'
        parseComment.description.full.should.equal '<p>Parse the given comment <code>str</code>.</p>\n\n<h2>The comment object returned contains the following</h2>\n\n<ul>\n<li><code>tags</code> array of tag objects</li>\n<li><code>description</code> the first line of the comment</li>\n<li><code>body</code> lines following the description</li>\n<li><code>content</code> both the description and the body</li>\n<li><code>isPrivate</code> true when "@api private" is used</li>\n</ul>'
        parseComment.description.body.should.equal '<h2>The comment object returned contains the following</h2>\n\n<ul>\n<li><code>tags</code> array of tag objects</li>\n<li><code>description</code> the first line of the comment</li>\n<li><code>body</code> lines following the description</li>\n<li><code>content</code> both the description and the body</li>\n<li><code>isPrivate</code> true when "@api private" is used</li>\n</ul>'

      'should have the correct escape meta': (comments) ->
        escape = comments.pop()
        escape.tags.should.have.length 3
        escape.description.full.should.equal '<p>Escape the given <code>html</code>.</p>'
        escape.ctx.type.should.equal 'method'
        escape.ctx.name.should.equal 'escape'

  'When parsing a complete code sample,':
    topic: fixture 'd.coffee'

    'the parsed comments':
      topic: (str) -> cdox.parseComments str

      'should have the correct description, tags, and code': (comments) ->
        first = comments.shift()
        first.tags.should.have.length 3
        first.description.full.should.equal '<p>Parse tag type string "{Array|Object}" etc.</p>'
        first.description.summary.should.equal '<p>Parse tag type string "{Array|Object}" etc.</p>'
        first.description.body.should.equal ''
        first.ctx.type.should.equal 'method'
        first.ctx.receiver.should.equal 'exports'
        first.ctx.name.should.equal 'parseTagTypes'
        first.code.should.equal 'exports.parseTagTypes = (str) ->\n  str.replace(\'foo\', \'bar\').split(\',\')'

  'When parsing comment tags again,':
    topic: fixture 'b.coffee'

    'the parse comments':
      topic: (str) -> cdox.parseComments str

      'should have the correct code segments': (comments) ->
        version = comments.shift()
        parse = comments.shift()

        version.code.should.equal "exports.version = '0.0.1'"
        parse.code.should.equal 'exports.parse = (str) ->\n  "wahoo"'

  'When parsing a function expression': quickVows
    topic: cdox.parseCodeContext 'foo = () ->\n'
    'the type should equal': 'function'
    'the name should equal': 'foo'

  'When parsing a prototype method': quickVows
    topic: cdox.parseCodeContext 'User::save = ->\n'
    'the type should equal': 'method'
    'the constructor should equal': 'User'
    'the name should equal': 'save'

  'When parsing a prototype property': quickVows
    topic: cdox.parseCodeContext 'Database::enabled = true\nasdf'
    'the type should equal': 'property'
    'the constructor should equal': 'Database'
    'the name should equal': 'enabled'
    'the value should equal': 'true'

  'When parsing a method': quickVows
    topic: cdox.parseCodeContext 'user.save = () ->'
    'the type should equal': 'method'
    'the receiver should equal': 'user'
    'the name should equal': 'save'

  'When parsing a property': quickVows
    topic: cdox.parseCodeContext 'user.name = "Brian"\nasdf'
    'the type should equal': 'property'
    'the receiver should equal': 'user'
    'the name should equal': 'name'
    'the value should equal': '"Brian"'

  'When parsing a declaration': quickVows
    topic: cdox.parseCodeContext 'name = "Brian"\nadf'
    'the type should equal': 'declaration'
    'the name should equal': 'name'
    'the value should equal': '"Brian"'

  'When parsing a @constructor tag': quickVows
    topic: cdox.parseTag '@constructor'
    'the type should equal': 'constructor'

  'When parsing a @see tag,':

    'that only has a url': quickVows
      topic: cdox.parseTag '@see http://google.com'
      'the type should equal': 'see'
      'the title should equal': ''
      'the url should equal': 'http://google.com'

    'that has a title and url': quickVows
      topic: cdox.parseTag '@see Google http://google.com'
      'the type should equal': 'see'
      'the title should equal': 'Google'
      'the url should equal': 'http://google.com'

    'that has a reference to other code': quickVows
      topic: cdox.parseTag '@see exports.parseComment'
      'the type should equal': 'see'
      'the local should equal': 'exports.parseComment'

  'When parsing an @api tag': quickVows
    topic: cdox.parseTag '@api private'
    'the type should equal': 'api'
    'the visibility should equal': 'private'

  'When parsing a @type tag': quickVows
    topic: cdox.parseTag '@type {String}'
    'the type should equal': 'type'
    'the types should eql': ['String']

  'When parsing a @param tag': quickVows
    topic: cdox.parseTag '@param {String|Buffer}'
    'the type should equal': 'param'
    'the types should eql': ['String', 'Buffer']
    'the name should equal': ''
    'the description should equal': ''

  'When parsing a @param tag with and name and description': quickVows
    topic: cdox.parseTag '@param {String} name - A person\'s name'
    'the type should equal': 'param'
    'the types should eql': ['String']
    'the name should equal': 'name'
    'the description should equal': '- A person\'s name'

  'When parsing a @return tag': quickVows
    topic: cdox.parseTag '@return {String} a normal string'
    'the type should equal': 'return'
    'the types should eql': ['String']
    'the description should equal': 'a normal string'

suite.export module
