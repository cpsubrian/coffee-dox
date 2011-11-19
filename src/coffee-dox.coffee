
###!
Dox
Copyright (c) 2011 Brian Link <cpsubrian@gmail.com>
MIT Licensed
###

###!
Module dependencies.
###

markdown = require('github-flavored-markdown').parse
{escape} = require './utils'

###
Library version.
###

exports.version = '0.1.2'

###
Parse comments in the given string of `js`.

@param {String} js
@return {Array}
@see exports.parseComment
@api public
###

exports.parseComments = (cs) ->
  comments = []
  buf = ''
  comment = ignore = within = code = null

  for i in [0...cs.length]
    # start comment
    if !within and cs[i] is '#' and cs[i+1] is '#' and cs[i+2] is '#'
      # code following previous comment
      if buf.trim().length
        comment = comments[comments.length - 1]
        comment.code = code = buf.trim()
        comment.ctx = exports.parseCodeContext code
        buf = ''      
      i += 3
      within = true
      ignore = '!' == cs[i]

    # end comment
    else if within and cs[i] is '#' and cs[i+1] is '#' and cs[i+2] is '#'
      i += 2
      buf = buf.replace /^ *\* ?/gm, ''
      comment = exports.parseComment buf
      comment.ignore = ignore
      comments.push comment
      within = ignore = false
      buf = ''
    # buffer comment or code
    else
      buf += cs[i]

  # trailing code
  if buf.trim().length
    comment = comments[comments.length - 1]
    code = buf.trim()
    comment.code = code
    comment.ctx = exports.parseCodeContext(code)

  comments

###
Parse the given comment `str`.

The comment object returned contains the following

  - `tags` array of tag objects
  - `description` the first line of the comment
  - `body` lines following the description
  - `content` both the description and the body
  - `isPrivate` true when "@api private" is used

@param {String} str
@return {Object}
@see exports.parseTag
@api public
###

exports.parseComment = (str) ->
  str = str.trim()
  comment = 
    tags: []
    description: {}

  # parse tags
  if ~str.indexOf('\n@')
    tags = '@' + str.split('\n@').slice(1).join('\n@')
    comment.tags = tags.split('\n').map(exports.parseTag)
    comment.isPrivate = comment.tags.some (tag) ->
      'api' is tag.type and 'private' is tag.visibility

  # parse comment body
  full = str.split('\n@')[0].replace(/^([\w ]+):$/gm, '## $1')
  summary = full.split('\n\n')[0]
  body = full.split('\n\n').slice(1).join('\n\n')

  # markdown
  comment.description.full = markdown full
  comment.description.summary = markdown summary
  comment.description.body = markdown body

  comment

###
# Parse tag string "@param {Array} name description" etc.
#
# @param {String}
# @return {Object}
# @api public
###

exports.parseTag = (str) ->
  tag = {}
  parts = str.split /\ +/
  type = tag.type = parts.shift().replace('@', '')

  switch type

    when 'param'
      tag.types = exports.parseTagTypes(parts.shift())
      tag.name = parts.shift() || ''
      tag.description = parts.join(' ')

    when 'return'
      tag.types = exports.parseTagTypes(parts.shift())
      tag.description = parts.join(' ')

    when 'see', 'api'
      if ~str.indexOf('http')
        tag.title = if parts.length > 1 then parts.shift() else ''
        tag.url = parts.join(' ')
      else
        tag.local = parts.join(' ')

      if type is 'api'
        tag.visibility = parts.shift()

    when 'type'
      tag.types = exports.parseTagTypes(parts.shift())

  tag

###
Parse tag type string "{Array|Object}" etc.

@param {String} str
@return {Array}
@api public
###

exports.parseTagTypes = (str) ->
  str.replace /[{}]/g, ''
  str.split /\ *[|,\/]\ */

###
Parse the context from the given `str` of js.

This method attempts to discover the context
for the comment based on it's code. Currently
supports:

  - function statements
  - function expressions
  - prototype methods
  - prototype properties
  - methods
  - properties
  - declarations

@param {String} str
@return {Object}
@api public
###

exports.parseCodeContext = (str) ->
  str = str.split('\n')[0]
  context = {}

  ## function statement
  if false
  #if /^function (\w+)\(/.exec str
  #  return {
  #      type: 'function'
  #    , name: RegExp.$1
  #    , string: RegExp.$1 + '()'
  #  };

  # function expression
  else if /^(\w+) *= *(\((\w*)\))? *->|=>/.exec str
    context =
      type: 'function'
      name: RegExp.$1
      string: RegExp.$1 + '()'

  # prototype method
  else if /^(\w+)::(\w+) *= *(\((\w*)\))? *->|=>/.exec str
    context =
      type: 'method'
      constructor: RegExp.$1
      name: RegExp.$2
      string: RegExp.$1 + '.prototype.' + RegExp.$2 + '()'

  # prototype property
  else if /^(\w+)::(\w+) *= *([^\n;]+)/.exec str
    context = 
      type: 'property'
      constructor: RegExp.$1
      name: RegExp.$2
      value: RegExp.$3
      string: RegExp.$1 + '.prototype' + RegExp.$2

  # method
  else if /^(\w+)\.(\w+) *= *(\((\w*)\))? *->|=>/.exec str
    context =
      type: 'method'
      receiver: RegExp.$1
      name: RegExp.$2
      string: RegExp.$1 + '.' + RegExp.$2 + '()'

  # property
  else if /^(\w+)\.(\w+) *= *([^\n;]+)/.exec str
    context =
      type: 'property'
      receiver: RegExp.$1
      name: RegExp.$2
      value: RegExp.$3
      string: RegExp.$1 + '.' + RegExp.$2

  # declaration
  else if /^(\w+) *= *([^\n;]+)/.exec str
    context =
      type: 'declaration'
      name: RegExp.$1
      value: RegExp.$2
      string: RegExp.$1

  context
