(function() {

  /*!
  Dox
  Copyright (c) 2011 Brian Link <cpsubrian@gmail.com>
  MIT Licensed
  */

  /*!
  Module dependencies.
  */

  var escape, markdown;

  markdown = require('github-flavored-markdown').parse;

  escape = require('./utils').escape;

  /*
  Library version.
  */

  exports.version = '0.1.2';

  /*
  Parse comments in the given string of `js`.
  
  @param {String} js
  @return {Array}
  @see exports.parseComment
  @api public
  */

  exports.parseComments = function(cs) {
    var buf, code, comment, comments, i, ignore, within, _ref;
    comments = [];
    buf = '';
    comment = ignore = within = code = null;
    for (i = 0, _ref = cs.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      if (!within && cs[i] === '#' && cs[i + 1] === '#' && cs[i + 2] === '#') {
        if (buf.trim().length) {
          comment = comments[comments.length - 1];
          comment.code = code = buf.trim();
          comment.ctx = exports.parseCodeContext(code);
          buf = '';
        }
        i += 3;
        within = true;
        ignore = '!' === cs[i];
      } else if (within && cs[i] === '#' && cs[i + 1] === '#' && cs[i + 2] === '#') {
        i += 2;
        buf = buf.replace(/^ *\* ?/gm, '');
        comment = exports.parseComment(buf);
        comment.ignore = ignore;
        comments.push(comment);
        within = ignore = false;
        buf = '';
      } else {
        buf += cs[i];
      }
    }
    if (buf.trim().length) {
      comment = comments[comments.length - 1];
      code = buf.trim();
      comment.code = code;
      comment.ctx = exports.parseCodeContext(code);
    }
    return comments;
  };

  /*
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
  */

  exports.parseComment = function(str) {
    var body, comment, full, summary, tags;
    str = str.trim();
    comment = {
      tags: [],
      description: {}
    };
    if (~str.indexOf('\n@')) {
      tags = '@' + str.split('\n@').slice(1).join('\n@');
      comment.tags = tags.split('\n').map(exports.parseTag);
      comment.isPrivate = comment.tags.some(function(tag) {
        return 'api' === tag.type && 'private' === tag.visibility;
      });
    }
    full = str.split('\n@')[0].replace(/^([\w ]+):$/gm, '## $1');
    summary = full.split('\n\n')[0];
    body = full.split('\n\n').slice(1).join('\n\n');
    comment.description.full = markdown(escape(full));
    comment.description.summary = markdown(escape(summary));
    comment.description.body = markdown(escape(body));
    return comment;
  };

  /*
  Parse tag string "@param {Array} name description" etc.
  
  @param {String}
  @return {Object}
  @api public
  */

  exports.parseTag = function(str) {
    var parts, tag, type;
    tag = {};
    parts = str.split(/\ +/);
    type = tag.type = parts.shift().replace('@', '');
    switch (type) {
      case 'param':
        tag.types = exports.parseTagTypes(parts.shift());
        tag.name = parts.shift() || '';
        tag.description = parts.join(' ');
        break;
      case 'return':
        tag.types = exports.parseTagTypes(parts.shift());
        tag.description = parts.join(' ');
        break;
      case 'see':
      case 'api':
        if (~str.indexOf('http')) {
          tag.title = parts.length > 1 ? parts.shift() : '';
          tag.url = parts.join(' ');
        } else {
          tag.local = parts.join(' ');
        }
        if (type === 'api') tag.visibility = parts.shift();
        break;
      case 'type':
        tag.types = exports.parseTagTypes(parts.shift());
    }
    return tag;
  };

  /*
  Parse tag type string "{Array|Object}" etc.
  
  @param {String} str
  @return {Array}
  @api public
  */

  exports.parseTagTypes = function(str) {
    return str.replace(/[{}]/g, '').split(/\ *[|,\/]\ */);
  };

  /*
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
  */

  exports.parseCodeContext = function(str) {
    var context;
    str = str.split('\n')[0];
    context = {};
    if (false) {} else if (/^(\w+) *= *(\((\w*)\))? *->|=>/.exec(str)) {
      context = {
        type: 'function',
        name: RegExp.$1,
        string: RegExp.$1 + '()'
      };
    } else if (/^(\w+)::(\w+) *= *(\((\w*)\))? *->|=>/.exec(str)) {
      context = {
        type: 'method',
        constructor: RegExp.$1,
        name: RegExp.$2,
        string: RegExp.$1 + '.prototype.' + RegExp.$2 + '()'
      };
    } else if (/^(\w+)::(\w+) *= *([^\n]+)/.exec(str)) {
      context = {
        type: 'property',
        constructor: RegExp.$1,
        name: RegExp.$2,
        value: RegExp.$3,
        string: RegExp.$1 + '.prototype' + RegExp.$2
      };
    } else if (/^(\w+)\.(\w+) *= *(\((\w*)\))? *->|=>/.exec(str)) {
      context = {
        type: 'method',
        receiver: RegExp.$1,
        name: RegExp.$2,
        string: RegExp.$1 + '.' + RegExp.$2 + '()'
      };
    } else if (/^(\w+)\.(\w+) *= *([^\n]+)/.exec(str)) {
      context = {
        type: 'property',
        receiver: RegExp.$1,
        name: RegExp.$2,
        value: RegExp.$3,
        string: RegExp.$1 + '.' + RegExp.$2
      };
    } else if (/^(\w+) *= *([^\n]+)/.exec(str)) {
      context = {
        type: 'declaration',
        name: RegExp.$1,
        value: RegExp.$2,
        string: RegExp.$1
      };
    }
    return context;
  };

}).call(this);
