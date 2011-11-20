###
Vows tests for CoffeeDox
###

cdox = require '../'
should = require 'should'
fs = require 'fs'
vows = require 'vows'

fixture = (name) ->
  return () ->
    fs.readFile(__dirname + '/fixtures/' + name, 'utf8', @callback)

suite = vows.describe('CoffeeDox')

# App Tests
suite.addBatch
  'Application version':
    topic: cdox.version

    'should be a valid version string': (version) ->
      version.should.match /^\d+\.\d+\.\d+$/

# Parser Test
suite.addBatch
  'When parsing comment blocks,':
    topic: fixture 'a.coffee'

    'the parsed comments':
      topic: (str) ->
        cdox.parseComments str

      'should have the correct file meta': (comments) ->
        file = comments[0]
        file.should.have.property 'ignore', true
        file.description.full.should.equal '<p>A<br />Copyright (c) 2010 Author Name &lt;Author Email&gt;<br />MIT Licensed</p>'
        file.description.summary.should.equal '<p>A<br />Copyright (c) 2010 Author Name &lt;Author Email&gt;<br />MIT Licensed</p>'
        file.description.body.should.equal ''
        file.tags.should.be.empty

      'should have the correct version meta': (comments) ->
        version = comments[1]
        version.should.have.property 'ignore', false
        version.description.full.should.equal '<p>Library version.</p>'
        version.description.summary.should.equal '<p>Library version.</p>'
        version.description.body.should.equal ''
        version.tags.should.be.empty

  'When parsing comment tags,':
    topic: fixture 'b.coffee'

    'the parsed comments':
      topic: (str) ->
        cdox.parseComments str

      'should have the correct version meta': (comments) ->
        version = comments[0]
        version.description.summary.should.equal '<p>Library version.</p>'
        version.description.full.should.equal '<p>Library version.</p>'
        version.tags.should.have.length 2
        version.tags[0].type.should.equal 'type'
        version.tags[0].types.should.eql ['String']
        version.tags[1].type.should.equal 'api'
        version.tags[1].visibility.should.equal 'public'
        version.ctx.type.should.equal 'property'
        version.ctx.receiver.should.equal 'exports'
        version.ctx.name.should.equal 'version'
        version.ctx.value.should.equal "'0.0.1'"

      'should have the correct parse meta': (comments) ->
        parse = comments[1]
        parse.description.summary.should.equal '<p>Parse the given <code>str</code>.</p>'
        parse.description.body.should.equal '<h2>Examples</h2>\n\n<pre><code>parse(str)\n// =&amp;gt; "wahoo"\n</code></pre>'
        parse.description.full.should.equal '<p>Parse the given <code>str</code>.</p>\n\n<h2>Examples</h2>\n\n<pre><code>parse(str)\n// =&amp;gt; "wahoo"\n</code></pre>'
        parse.tags[0].type.should.equal 'param'
        parse.tags[0].name.should.equal 'str'
        parse.tags[0].description.should.equal 'to parse'
        parse.tags[0].types.should.eql ['String', 'Buffer']
        parse.tags[1].type.should.equal 'return'
        parse.tags[1].types.should.eql ['String']
        parse.tags[2].visibility.should.equal 'public'

  'When parsing complex comments,':
    topic: fixture 'c.coffee'

    'the parsed comments':
      topic: (str) ->
        cdox.parseComments str

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
      topic: (str) ->
        cdox.parseComments str

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
      topic: (str) ->
        cdox.parseComments str

      'should have the correct code segments': (comments) ->
        version = comments.shift()
        parse = comments.shift()

        version.code.should.equal "exports.version = '0.0.1'"
        parse.code.should.equal 'exports.parse = (str) ->\n  "wahoo"'

  'When parsing a function expression':
    topic: cdox.parseCodeContext 'foo = () ->\n'

    'the type should be "function"': (context) ->
      context.type.should.equal 'function'

    'the name should be "foo"': (context) ->
      context.name.should.equal 'foo'

  'When parsing a prototype method':
    topic: cdox.parseCodeContext 'User::save = ->\n'

    'the type should be method': (context) ->
      context.type.should.equal 'method'

    'the constructor should be "User"': (context) ->
      context.constructor.should.equal 'User'

    'the name should be "save"': (context) ->
      context.name.should.equal 'save'

  'When parsing a prototype property':
    topic: cdox.parseCodeContext 'Database::enabled = true\nasdf'

    'the type should be "property"': (context) ->
      context.type.should.equal 'property'

    'the constructor should be "Database"': (context) ->
      context.constructor.should.equal 'Database'

    'the name should be "enabled"': (context) ->
      context.name.should.equal 'enabled'

    'the value should be "true"': (context) ->
      context.value.should.equal 'true'

  'When parsing a method':
    topic: cdox.parseCodeContext 'user.save = () ->'

    'the type should be "method"': (context) ->
      context.type.should.equal 'method'

    'the receiver should be "user"': (context) ->
      context.receiver.should.equal 'user'

    'the name should be "save"': (context) ->
      context.name.should.equal 'save'

  'When parsing a property':
    topic: cdox.parseCodeContext 'user.name = "Brian"\nasdf'

    'the type should be "property"': (context) ->
      context.type.should.equal 'property'

    'the receiver should be "user"': (context) ->
      context.receiver.should.equal 'user'

    'the name should be "name"': (context) ->
      context.name.should.equal 'name'

    'the value should be "Brian"': (context) ->
      context.value.should.equal '"Brian"'

  'When parsing a declaration':
    topic: cdox.parseCodeContext 'name = "Brian"\nadf'

    'the type should be "declaration"': (context) ->
      context.type.should.equal 'declaration'

    'the name should equal "name"': (context) ->
      context.name.should.equal 'name'

    'the value should equal "Brian"': (context) ->
      context.value.should.equal '"Brian"'

  'When parsing a @constructor tag':
    topic: cdox.parseTag '@constructor'

    'the type should be "constrcutor"': (tag) ->
      tag.type.should.equal 'constructor'

  'When parsing a @see tag,':

    'that only has a url':
      topic: cdox.parseTag '@see http://google.com'

      'the type should be "see"': (tag) ->
        tag.type.should.equal 'see'

      'the title should be empty': (tag) ->
        tag.title.should.equal ''

      'the url should be "http://google.com"': (tag) ->
        tag.url.should.equal('http://google.com')

    'that has a title and url':
      topic: cdox.parseTag '@see Google http://google.com'

      'the type should be "see"': (tag) ->
        tag.type.should.equal 'see'

      'the title should be "Google"': (tag) ->
        tag.title.should.equal 'Google'

      'the url should be "http://google.com"': (tag) ->
        tag.url.should.equal 'http://google.com'

    'that has a reference to other code':
      topic: cdox.parseTag '@see exports.parseComment'

      'the type should be "see"': (tag) ->
        tag.type.should.equal 'see'

      'the local should be "exports.parseComment"': (tag) ->
        tag.local.should.equal 'exports.parseComment'

  'When parsing an @api tag':
    topic: cdox.parseTag '@api private'

    'the type should be "api"': (tag) ->
      tag.type.should.equal 'api'

    'the visibility should be "private"': (tag) ->
      tag.visibility.should.equal 'private'

  'When parsing a @type tag':
    topic: cdox.parseTag '@type {String}'

    'the type should be "type"': (tag) ->
      tag.type.should.equal 'type'

    'the types should be ["String"]': (tag) ->
      tag.types.should.eql ['String']

  'When parsing a @param tag':
    topic: cdox.parseTag '@param {String|Buffer}'

    'the type should be "param"': (tag) ->
      tag.type.should.equal 'param'

    'the types should be ["String", "Buffer"]': (tag) ->
      tag.types.should.eql ['String', 'Buffer']

    'the name should be empty': (tag) ->
      tag.name.should.equal ''

    'the description should be empty': (tag) ->
      tag.description.should.equal ''

  'When parsing a @param tag with and name and description':
    topic: cdox.parseTag '@param {String} name - A person\'s name'

    'the type should be "param"': (tag) ->
      tag.type.should.equal 'param'

    'the types should be ["String"]': (tag) ->
      tag.types.should.eql ['String']

    'the name should be "name"': (tag) ->
      tag.name.should.equal 'name'

    'the description should be "- a person\'s name"': (tag) ->
      tag.description.should.equal '- A person\'s name'

  'When parsing a @return tag':
    topic: cdox.parseTag '@return {String} a normal string'

    'the type should be "return"': (tag) ->
      tag.type.should.equal 'return'

    'the types should be ["String"]': (tag) ->
      tag.types.should.eql ['String']

    'the description should be "a normal string"': (tag) ->
      tag.description.should.equal 'a normal string'

suite.export module