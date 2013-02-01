module.exports =
  required: ['sessionId', 'accountId']
  service: ({accountId}, done) ->
    done null, {role: 'Supreme Commander', accountId: accountId}
