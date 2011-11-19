###
Parse tag type string "{Array|Object}" etc.

@param {String} str
@return {Array}
@api public
###

exports.parseTagTypes = (str) ->
  str.replace('foo', 'bar').split(',')

