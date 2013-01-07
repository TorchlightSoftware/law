module.exports = (args, done) ->
  console.log 'arrived in dashboard service'
  done null, {user: {name: 'Bob'}}
