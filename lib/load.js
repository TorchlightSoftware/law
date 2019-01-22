let load
const {readdirSync, statSync, existsSync} = require('fs')
const {join, basename, extname, resolve} = require('path')

module.exports = load = function(folder, prefix = null) {
  folder = resolve(folder)

  const services = {}

  // find service definitions
  if (existsSync(folder)) {
    for (let file of readdirSync(folder)) {
      const ext = extname(file)
      const filename = basename(file, ext)
      const fullname = prefix ? `${prefix}/${filename}` : filename
      const filePath = join(folder, file)

      // if it's a service, add it to the list
      if (require.extensions[ext] != null) {
        services[fullname] = require(filePath)

        // recurse on subdirectories
      } else if (statSync(filePath).isDirectory()) {
        const object = load(filePath, fullname)
        for (let name in object) {
          const def = object[name]
          services[name] = def
        }
      }
    }
  }

  return services
}
