{readdirSync, statSync, existsSync} = require 'fs'
{join, basename, extname, resolve} = require 'path'

module.exports = load = (folder, prefix=null) ->
  folder = resolve(folder)

  services = {}

  # find service definitions
  if existsSync(folder)
    for file in readdirSync folder
      ext = extname file
      filename = basename(file, ext)
      fullname = (if prefix then "#{prefix}/#{filename}" else filename)
      filePath = join folder, file

      # if it's a service, add it to the list
      if require.extensions[ext]?
        services[fullname] = require filePath

      # recurse on subdirectories
      else if statSync(filePath).isDirectory()
        for name, def of load(filePath, fullname)
          services[name] = def

  return services
