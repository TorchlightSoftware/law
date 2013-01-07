redisId = /[a-z0-9]{16}/
mongoId = /[a-f0-9]{24}/

module.exports = [
    typeName: 'String'
    validation: (arg, assert) ->
      assert typeof arg is 'string'
    defaultArgs: ['email', 'password']
  ,
    typeName: 'SessionId'
    validation: (arg, assert) ->
      assert (typeof arg is 'string') and arg.match redisId
    defaultArgs: ['sessionId']
  ,
    typeName: 'MongoId'
    validation: (arg, assert) ->
      assert arg.toString().match mongoId
    defaultArgs: ['userId']
]
