#small demo that enables to create decorators
# that modify function's source code

#API for Function is not clear so I will use small helper class instead
class FunctionData
  constructor: (func) ->
    @_source = func.toString()

  getArguments: () ->
    argumentStart = @_source.indexOf('(') + 1
    argumentEnd = @_source.indexOf(')')
    args = @_source.substring(argumentStart, argumentEnd).split(', ')
    if args.length > 0 and args[0].length is 0 then [] else args

  getSource: () ->
    codeStartsAt = @_source.indexOf('{') + 1
    @_source.substring(codeStartsAt, @_source.length - 2)

#Adds support for function's source code decorators
class Aspects
  #base decorator
  #injects specified code as first statement(s) of target function
  @aspect: (injection, fn) ->
    fnData = new FunctionData(fn)
    src = fnData.getSource()
    newFnSource = "#{injection};#{src}"
    new Function(fnData.getArguments(), newFnSource)

  @_fnEnvMacros = 'console.log("args: ", arguments, "\\n this: ", this)'
  #this decorator shows function's arguments and context
  @fnEnv: (fn) -> @aspect(@_fnEnvMacros, fn)


class DecoratorExample extends Aspects
  @wrap: @fnEnv (fn) ->
    console.log 'decorating'
    return -> fn.apply @, arguments


class TestSubject extends DecoratorExample
  constructor: () ->
    @foo = 'bar'

  test: @wrap @fnEnv ->
    console.log 'executing some logic'

Meteor.startup ->
  new TestSubject().test("fn's argument")