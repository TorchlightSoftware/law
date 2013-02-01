redisId = /[a-z0-9]{16}/
mongoId = /[a-f0-9]{24}/

module.exports = [
    typeName: 'String'
    validation: ({value, fieldName}, assert) ->
      assert typeof value is 'string', {message: "#{fieldName} is not a string."}
    defaultArgs: ['email', 'password', 'body', 'subject']
  ,
    typeName: 'SessionId'
    validation: ({value}, assert) ->
      assert value and (typeof value is 'string') and value.match redisId
    defaultArgs: ['sessionId']
  ,
    typeName: 'AccountId'
    lookup: ({sessionId}, found) ->
      if sessionId
        found null, "#{sessionId}abcd1234"
      else
        found()

    validation: ({value}, assert) ->
      assert value and (typeof value is 'string') and value.match mongoId
    defaultArgs: ['accountId']
  ,
    typeName: 'MongoId'
    validation: ({value}, assert) ->
      assert value.toString().match mongoId
    defaultArgs: ['userId']
]

#module.exports =
  #words: [
      #name: 'email'
      #displayName: 'Email'
      #validate: 'String'
    #,
      #name: 'password'
      #displayName: 'Password'
      #validate: 'Password'
    #,
      #name: 'sessionId'
      #displayName: 'SessionId'
      #validate: 'RedisId'
    #,
      #name: 'accountId'
      #displayName: 'AccountId'
      #validate: 'MongoId'
      #lookup: 'findAccountIdBySessionId'
      #serverOnly: true
    #,
      #name: 'userId'
      #displayName: 'UserId'
      #validate: 'MongoId'
  #]

  #validations: [
      #name: 'String'
      #def: ({value, displayName}, assert) ->
        #assert (typeof instance.value) is 'string'
    #,
      #name: 'Password'
      #also: 'String'
      #def: ({value, displayName}, assert) ->
        #assert value.length > 6, message: "#{displayName} must be at least 6 letters long."
    #,
      #name: 'MongoId'
      #also: 'String'
      #def: ({value}, assert) ->
        #assert value.toString().match mongoId
    #,
      #name: 'RedisId'
      #also: 'String'
      #def: ({value}, assert) ->
        #assert value.toString().match redisId
  #]

  #lookups: [
      #name: 'findAccountIdBySessionId'
      #def: ({sessionId}, found) ->
        #found "#{sessionId}abcd1234"
      #serverOnly: true
  #]
