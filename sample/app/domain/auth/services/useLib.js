module.exports = {
  dependencies: {
    lib: ['tea-error'],
  },
  service(args, done, {lib}) {
    const SpecialError = lib['tea-error']('SpecialError')
    return done(new SpecialError('testing special error'))
  },
}
