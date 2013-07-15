adjacentDependencies = (services, source, dependencyType='services') ->
  services[source]?.dependencies?[dependencyType] || []

# Give an adjacency array representation of the dependency digraph
adjacencyRelation = (services, dependencyType) ->
  rel = []
  for name of services
    adjacent = adjacentDependencies services, name, dependencyType
    for dependency in adjacent
      rel.push [name, dependency]
  return rel

flatten = (x, y) -> x.concat y

dedup = (arr) ->
  result = []
  for k in arr
    unless k in result
      result.push k
  return result

# Return all transitive dependencies of 'source' as a sorted array.
# 
# We regard each service as a vertex in a directed graph, and each declared
# dependency as defining an arc with the orientation 'a -> b', meaning
# 'a depends on b'. The result of this function is the set of vertices
# reachable from 'source' with respect to this 'depends on' orientation.
connectedDependencies = (services, source, dependencyType) ->
  walk = (source, connected) ->
    connected.push source
    adjacent = adjacentDependencies services, source, dependencyType
    unwalked = adjacent.filter (x) -> x not in connected

    if unwalked.length > 0
      result = adjacent.map ((s) -> walk s, adjacent.concat connected)
      result = result.reduce flatten
    else
      result = connected

    return (dedup result).sort()

  return walk source, []

allConnectedServices = (services) ->
  connectionMap = {}
  for name of services
    connectionMap[name] = connectedServices services, name
  return connectionMap

join = (arr, sep) -> arr.reduce (s, t) -> "#{s}#{sep}#{t}"

dotNotation = (services, graphName, dependencyType) ->
  rel = adjacencyRelation services, dependencyType
  rel = ("#{x} -> #{y};" for [x,y] in rel)
  rel = join rel, '\n  '
  dot = """
  digraph #{graphName} {
    #{rel}
  }"""
  return dot

module.exports =
  adjacentDependencies: adjacentDependencies
  adjacencyRelation: adjacencyRelation
  connectedDependencies: connectedDependencies
  dotNotation: dotNotation