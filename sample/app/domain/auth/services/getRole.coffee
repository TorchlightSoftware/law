module.exports =
  required: ['sessionId']
  service: (args, done) ->
    done null, {role: 'Supreme Commander'}
