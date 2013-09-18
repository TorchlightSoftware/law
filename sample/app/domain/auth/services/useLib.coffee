module.exports =
  dependencies:
    lib: ['coffee-script']
  service: (args, done, {lib}) ->
    compiled = lib['coffee-script'].compile 'console.log "hello"', {bare: true}
    done null, {compiled}
