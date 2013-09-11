escodegen = require 'escodegen'
{randomElement, randomInt, randomBool} = require './random'

Program = require './nodes/Program'

class RoundtripFailureError extends Error
  name: 'RoundtripFailureError'
  constructor: (@message) ->
    Error.call this
    Error.captureStackTrace? this, RoundtripFailureError

randomFormat = ->
  indent:
    style: randomElement ['', '  ', '\t'] # TODO: include other whitespace characters
    base: randomElement ['', '  ', '\t'] # TODO: include other whitespace characters
  quotes: randomElement ['auto', 'double', 'single']
  escapeless: randomBool()
  compact: randomBool()
  parentheses: randomBool()
  semicolons: randomBool()

exports.generate = generate = (options = {}) ->
  Program options.maxDepth ? 8

exports.render = render = (programAST, format = randomFormat()) ->
  escodegen.generate programAST, verbatim: 'raw', format: format

renderForComparison = (programAST) -> render programAST, escodegen.FORMAT_MINIFY

exports.fuzzAndRoundtrip = (programAST, parsers) ->
  try
    format = randomFormat()
    program = render programAST, format
    roundTrippedPrograms = (renderForComparison parser.parse program for parser in parsers)
    targetProgram = renderForComparison programAST
  catch err
    err.ast = programAST
    err.js = program
    err.format = format
    throw err
  for roundTrippedProgram in roundTrippedPrograms when roundTrippedProgram isnt targetProgram
    err = new RoundtripFailureError
    err.ast = programAST
    err.js = program
    throw err
  return

exports.fuzz = (programAST, parsers) ->
  try
    format = randomFormat()
    program = render programAST, format
    parser.parse program for parser in parsers
  catch err
    err.ast = programAST
    err.js = program
    err.format = format
    throw err
  return
