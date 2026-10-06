import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Travel estimation result with distance and duration
class TravelEstimate {
  final double distanceKm;
  final double durationMinutes;
  final bool isFromApi;
  final String description;

  const TravelEstimate({
    required this.distanceKm,
    required this.durationMinutes,
    required this.isFromApi,
    required this.description,
  });

  @override
  String toString() =>
      'TravelEstimate(${distanceKm.toStringAsFixed(1)} km, ${durationMinutes.toStringAsFixed(0)} mins, api: $isFromApi)';
}

/// Service to estimate transit times and calculate smart 'leave-now' reminder schedules
class SmartTransitService {
  final String? googleApiKey;
  final http.Client _httpClient;

  SmartTransitService({
    this.googleApiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Calculate straight-line distance in kilometers using the Haversine formula
  double calculateHaversineDistanceKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(endLat - startLat);
    final double dLon = _toRadians(endLng - startLng);

    final double lat1Rad = _toRadians(startLat);
    final double lat2Rad = _toRadians(endLat);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1Rad) * math.cos(lat2Rad);

    final double c = 2 * math.asin(math.sqrt(math.max(0.0, math.min(1.0, a))));

    return earthRadiusKm * c;
  }

  /// Fallback travel time using straight-line distance divided by 20 km/h (city traffic average)
  double calculateFallbackTravelTimeMinutes(double distanceKm) {
    // Speed = 20 km/h -> time = (distance / 20) * 60 minutes
    const double speedKmh = 20.0;
    final double hours = distanceKm / speedKmh;
    return hours * 60.0;
  }

  /// Estimate travel time from user location to venue location.
  /// Uses Google Distance Matrix API if configured, otherwise falls back to Haversine / 20 km/h.
  Future<TravelEstimate> estimateTravelTime({
    required double userLat,
    required double userLng,
    required double venueLat,
    required double venueLng,
  }) async {
    // 1. Check if Google Distance Matrix API key is configured
    final apiKey = googleApiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$userLat,$userLng'
          '&destinations=$venueLat,$venueLng'
          '&mode=driving'
          '&key=$apiKey',
        );

        final response = await _httpClient
            .get(url)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final rows = data['rows'] as List<dynamic>?;
            if (rows != null && rows.isNotEmpty) {
              final elements = rows[0]['elements'] as List<dynamic>?;
              if (elements != null && elements.isNotEmpty) {
                final element = elements[0] as Map<String, dynamic>;
                if (element['status'] == 'OK') {
                  final durationSec = element['duration']['value'] as num;
                  final distanceMeters = element['distance']['value'] as num;
                  final distanceText = element['distance']['text'] as String? ?? '';
                  final durationText = element['duration']['text'] as String? ?? '';

                  return TravelEstimate(
                    distanceKm: distanceMeters / 1000.0,
                    durationMinutes: durationSec / 60.0,
                    isFromApi: true,
                    description: '$durationText ($distanceText) via Live Traffic',
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Distance Matrix API call failed, falling back to straight-line: $e');
      }
    }

    // 2. Fallback to Haversine / 20 km/h
    final distanceKm = calculateHaversineDistanceKm(
      startLat: userLat,
      startLng: userLng,
      endLat: venueLat,
      endLng: venueLng,
    );
    final durationMinutes = calculateFallbackTravelTimeMinutes(distanceKm);

    return TravelEstimate(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      isFromApi: false,
      description:
          '~${durationMinutes.round()} mins (${distanceKm.toStringAsFixed(1)} km at 20 km/h)',
    );
  }

  /// Calculates the exact 'Smart Leave-Now' reminder trigger time:
  /// Target = showTime - travelTime - 15 minutes buffer
  DateTime calculateLeaveNowTime({
    required DateTime showTime,
    required double travelTimeMinutes,
    int bufferMinutes = 15,
  }) {
    final totalMinutesBeforeShow = travelTimeMinutes + bufferMinutes;
    return showTime.subtract(Duration(minutes: totalMinutesBeforeShow.round()));
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}
