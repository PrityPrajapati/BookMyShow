import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/features/venue_map/domain/services/dijkstra_router.dart';

void main() {
  group('DijkstraRouter Venue Indoor Navigation Unit Tests', () {
    late DijkstraRouter router;

    setUp(() {
      router = DijkstraRouter();

      // Set up a representative venue graph
      // Main Entrance (0m) -> Lobby (15m) -> Concessions (25m) -> Screen 1 (40m)
      //                      -> Screen 4 (IMAX) (35m) via Stairs (not accessible)
      //                      -> Elevator (10m) -> Screen 4 (IMAX) (20m, accessible)
      //                      -> Restrooms (12m)
      // Parking Bay A -> Elevator (20m)
      router.addNode('entrance_main', 'Main Entrance');
      router.addNode('lobby', 'Lobby Level 1');
      router.addNode('concessions', 'Concessions Counter');
      router.addNode('restrooms', 'Restrooms Level 1');
      router.addNode('stairs_level2', 'Stairs to Level 2', isAccessible: false);
      router.addNode('elevator', 'Elevator Lobby', isAccessible: true);
      router.addNode('screen_1', 'Screen 1');
      router.addNode('screen_4', 'Screen 4 (IMAX Laser)');
      router.addNode('parking_bay_a', 'Parking Bay A');
      router.addNode('isolated_room', 'Maintenance Closet (Isolated)');

      // Add edges with distance (meters) and accessibility flag
      router.addEdge('entrance_main', 'lobby', 15.0);
      router.addEdge('lobby', 'concessions', 20.0);
      router.addEdge('lobby', 'restrooms', 12.0);
      router.addEdge('concessions', 'screen_1', 15.0);

      // Path to Screen 4 via stairs (faster but inaccessible: 10m + 15m = 25m)
      router.addEdge('lobby', 'stairs_level2', 10.0, isAccessible: false);
      router.addEdge('stairs_level2', 'screen_4', 15.0, isAccessible: false);

      // Path to Screen 4 via elevator (accessible: 12m + 22m = 34m)
      router.addEdge('lobby', 'elevator', 12.0, isAccessible: true);
      router.addEdge('elevator', 'screen_4', 22.0, isAccessible: true);

      // Path from Parking Bay A to Elevator
      router.addEdge('parking_bay_a', 'elevator', 20.0, isAccessible: true);
    });

    test('Finds direct and shortest path from Main Entrance to Screen 1', () {
      final result = router.findShortestPath('entrance_main', 'screen_1');

      expect(result.isFound, isTrue);
      expect(result.path, ['entrance_main', 'lobby', 'concessions', 'screen_1']);
      // 15 + 20 + 15 = 50m
      expect(result.totalDistanceMeters, 50.0);
    });

    test('Finds shortest path to Screen 4 via stairs when accessibility is not required', () {
      final result = router.findShortestPath('entrance_main', 'screen_4', accessibleOnly: false);

      expect(result.isFound, isTrue);
      // Entrance -> Lobby (15) -> Stairs (10) -> Screen 4 (15) = 40m
      expect(result.path, ['entrance_main', 'lobby', 'stairs_level2', 'screen_4']);
      expect(result.totalDistanceMeters, 40.0);
    });

    test('Routes via elevator when accessibleOnly is true (skips stairs)', () {
      final result = router.findShortestPath('entrance_main', 'screen_4', accessibleOnly: true);

      expect(result.isFound, isTrue);
      // Entrance -> Lobby (15) -> Elevator (12) -> Screen 4 (22) = 49m
      expect(result.path, ['entrance_main', 'lobby', 'elevator', 'screen_4']);
      expect(result.totalDistanceMeters, 49.0);
      expect(result.path.contains('stairs_level2'), isFalse);
    });

    test('Computes shortest path from Parking to Restrooms', () {
      final result = router.findShortestPath('parking_bay_a', 'restrooms');

      expect(result.isFound, isTrue);
      // Parking -> Elevator (20) -> Lobby (12) -> Restrooms (12) = 44m
      expect(result.path, ['parking_bay_a', 'elevator', 'lobby', 'restrooms']);
      expect(result.totalDistanceMeters, 44.0);
    });

    test('Returns distance 0 when start and target node are the same', () {
      final result = router.findShortestPath('lobby', 'lobby');

      expect(result.isFound, isTrue);
      expect(result.path, ['lobby']);
      expect(result.totalDistanceMeters, 0.0);
    });

    test('Returns notFound when target is disconnected or does not exist', () {
      final resultIsolated = router.findShortestPath('entrance_main', 'isolated_room');
      expect(resultIsolated.isFound, isFalse);
      expect(resultIsolated.path, isEmpty);

      final resultNonExistent = router.findShortestPath('entrance_main', 'non_existent_node');
      expect(resultNonExistent.isFound, isFalse);
    });
  });
}
