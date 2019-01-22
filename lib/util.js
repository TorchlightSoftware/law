let util
module.exports = util = {
  // like typeof, except useful ^^
  getType(obj) {
    return Object.prototype.toString.call(obj).slice(8, -1)
  },

  // works like concat, but modifies array
  addTo(arr, addition) {
    if (Array.isArray(addition)) {
      return arr.push(...(addition || []))
    } else {
      return arr.push(addition)
    }
  },

  // promote elements out of nested arrays
  flatten(arr) {
    if (!Array.isArray(arr)) {
      return arr
    }
    return arr.reduce((a, b) => a.concat(b), [])
  },

  // remove null/undefined elements from array
  compact(arr) {
    if (!Array.isArray(arr)) {
      return arr
    }
    return arr.filter(a => a != null)
  },

  // does target string start with search?
  startsWith(target, search) {
    return target.indexOf(search) === 0
  },

  // merge source object into target
  merge(target, source) {
    if (util.getType(target) !== 'Object' || util.getType(source) !== 'Object')
      return target

    for (let name in source) {
      target[name] = source[name]
    }
    return target
  },

  isPromise(p) {
    return p != null
      && util.getType(p.then) === 'Function'
      && util.getType(p.catch) === 'Function'
  },
  isFunction(f) {
    return ['Function', 'AsyncFunction'].includes(util.getType(f))
  },
}
