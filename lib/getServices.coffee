{readdirSync, statSync} = require 'fs'
{join, basename, extname} = require 'path'

module.exports = getServices = (folder, prefix=null) ->

  services = {}

  # find service definitions
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
      for name, def of getServices(filePath, fullname)
        services[name] = def

  return services
