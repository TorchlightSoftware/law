module.exports = util =

  getType: (obj) -> Object.prototype.toString.call(obj).slice 8, -1

  # works like concat, but modifies array
  addTo: (arr, addition) ->
    if Array.isArray addition
      arr.push addition...
    else
      arr.push addition

  # promote elements out of nested arrays
  flatten: (arr) ->
    return arr unless Array.isArray arr

    flattened = []
    for a in arr
      util.addTo flattened, a

    return flattened

  # remove null/undefined elements from array
  compact: (arr) ->
    return arr unless Array.isArray arr
    (a for a in arr when a?)

  # does target string start with search?
  startsWith: (target, search) ->
    target.indexOf(search) is 0

  # merge source hash into target
  merge: (target, source) ->
    return target unless util.getType(target) is 'Object' and util.getType(source) is 'Object'
    for name, value of source
      target[name] = value
    return target
