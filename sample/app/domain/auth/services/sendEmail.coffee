module.exports =
  required: ['email', 'subject']
  optional: ['body']
  service: ({email, body, subject}, done) ->
    # send email
    done()
