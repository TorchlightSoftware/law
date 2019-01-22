const adjacentDependencies = (
  services,
  source,
  dependencyType = 'services'
) => {
  if (!services[source]) return []
  if (!services[source].dependencies) return []
  return services[source].dependencies[dependencyType]
}

// Give an adjacency array representation of the dependency digraph
const adjacencyRelation = function(services, dependencyType) {
  const rel = []
  for (let name in services) {
    const adjacent = adjacentDependencies(services, name, dependencyType)
    for (let dependency of adjacent) {
      rel.push([name, dependency])
    }
  }
  return rel
}

const flatten = (x, y) => x.concat(y)

const dedup = function(arr) {
  const result = []
  for (let k of arr) {
    if (!result.includes(k)) {
      result.push(k)
    }
  }
  return result
}

// Return all transitive dependencies of 'source' as a sorted array.
//
// We regard each service as a vertex in a directed graph, and each declared
// dependency as defining an arc with the orientation 'a -> b', meaning
// 'a depends on b'. The result of this function is the set of vertices
// reachable from 'source' with respect to this 'depends on' orientation.
const connectedDependencies = function(services, source, dependencyType) {
  var walk = function(source, connected) {
    let result
    connected.push(source)
    const adjacent = adjacentDependencies(services, source, dependencyType)
    const unwalked = adjacent.filter(x => !connected.includes(x))

    if (unwalked.length > 0) {
      result = adjacent.map(s => walk(s, adjacent.concat(connected)))
      result = result.reduce(flatten)
    } else {
      result = connected
    }

    return dedup(result).sort()
  }

  return walk(source, [])
}

const allConnectedServices = function(services) {
  const connectionMap = {}
  for (let name in services) {
    connectionMap[name] = connectedServices(services, name)
  }
  return connectionMap
}

// a reducer that joins on a separator
const join = sep => (s, t) => `${s}${sep}${t}`

const dotNotation = function(services, graphName, dependencyType) {
  let rel = adjacencyRelation(services, dependencyType)
    .map(([x, y]) => `${x} -> ${y};`)
    .reduce(join('\n  '))

  const dot = `\
digraph ${graphName} {
  ${rel}
}`
  return dot
}

module.exports = {
  adjacentDependencies,
  adjacencyRelation,
  connectedDependencies,
  dotNotation,
}
