IdentifierName = require './IdentifierName'
RESERVED = require '../reserved'

module.exports = ->
  id = IdentifierName()
  id.name = if id.name in RESERVED then "#{id.name}#{id.name}" else id.name
  id
