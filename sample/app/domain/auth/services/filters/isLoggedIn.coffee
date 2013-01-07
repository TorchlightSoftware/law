module.exports =
  required: ['sessionId']
  service: (args, next) ->

    # lookup sessionId in redis

    next()
