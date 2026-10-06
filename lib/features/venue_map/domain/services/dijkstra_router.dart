/// Node representing a waypoint or amenity inside the venue
class VenueNode {
  final String id;
  final String label;
  final bool isAccessible;

  const VenueNode({
    required this.id,
    required this.label,
    this.isAccessible = true,
  });
}

/// Weighted edge connecting two venue waypoints
class VenueEdge {
  final String toNodeId;
  final double distanceMeters;
  final bool isAccessible;

  const VenueEdge({
    required this.toNodeId,
    required this.distanceMeters,
    this.isAccessible = true,
  });
}

/// Result of Dijkstra shortest path computation
class DijkstraRouteResult {
  final List<String> path;
  final double totalDistanceMeters;
  final bool isFound;

  const DijkstraRouteResult({
    required this.path,
    required this.totalDistanceMeters,
    required this.isFound,
  });

  static const DijkstraRouteResult notFound = DijkstraRouteResult(
    path: [],
    totalDistanceMeters: double.infinity,
    isFound: false,
  );
}

/// Pure Dart Dijkstra Router for indoor venue & parking navigation
class DijkstraRouter {
  final Map<String, VenueNode> _nodes = {};
  final Map<String, List<VenueEdge>> _adjacencyList = {};

  void addNode(String id, String label, {bool isAccessible = true}) {
    _nodes[id] = VenueNode(id: id, label: label, isAccessible: isAccessible);
    _adjacencyList.putIfAbsent(id, () => []);
  }

  void addEdge(
    String from,
    String to,
    double distanceMeters, {
    bool isAccessible = true,
    bool bidirectional = true,
  }) {
    _adjacencyList.putIfAbsent(from, () => []).add(
          VenueEdge(
            toNodeId: to,
            distanceMeters: distanceMeters,
            isAccessible: isAccessible,
          ),
        );

    if (bidirectional) {
      _adjacencyList.putIfAbsent(to, () => []).add(
            VenueEdge(
              toNodeId: from,
              distanceMeters: distanceMeters,
              isAccessible: isAccessible,
            ),
          );
    }
  }

  DijkstraRouteResult findShortestPath(
    String startNodeId,
    String targetNodeId, {
    bool accessibleOnly = false,
  }) {
    if (!_nodes.containsKey(startNodeId) || !_nodes.containsKey(targetNodeId)) {
      return DijkstraRouteResult.notFound;
    }

    if (startNodeId == targetNodeId) {
      return DijkstraRouteResult(
        path: [startNodeId],
        totalDistanceMeters: 0.0,
        isFound: true,
      );
    }

    final distances = <String, double>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    for (final nodeId in _nodes.keys) {
      distances[nodeId] = double.infinity;
      previous[nodeId] = null;
      unvisited.add(nodeId);
    }
    distances[startNodeId] = 0.0;

    while (unvisited.isNotEmpty) {
      // Find unvisited node with smallest distance
      String? current;
      double minDistance = double.infinity;

      for (final nodeId in unvisited) {
        final d = distances[nodeId]!;
        if (d < minDistance) {
          minDistance = d;
          current = nodeId;
        }
      }

      if (current == null || minDistance == double.infinity) {
        break; // Target unreachable
      }

      if (current == targetNodeId) {
        break; // Reached target
      }

      unvisited.remove(current);

      final edges = _adjacencyList[current] ?? [];
      for (final edge in edges) {
        if (!unvisited.contains(edge.toNodeId)) continue;
        if (accessibleOnly && !edge.isAccessible) continue;

        final targetNode = _nodes[edge.toNodeId];
        if (accessibleOnly && targetNode != null && !targetNode.isAccessible) {
          continue;
        }

        final alt = distances[current]! + edge.distanceMeters;
        if (alt < distances[edge.toNodeId]!) {
          distances[edge.toNodeId] = alt;
          previous[edge.toNodeId] = current;
        }
      }
    }

    if (distances[targetNodeId] == double.infinity) {
      return DijkstraRouteResult.notFound;
    }

    // Reconstruct path backwards
    final path = <String>[];
    String? curr = targetNodeId;
    while (curr != null) {
      path.insert(0, curr);
      curr = previous[curr];
    }

    return DijkstraRouteResult(
      path: path,
      totalDistanceMeters: distances[targetNodeId]!,
      isFound: true,
    );
  }
}
