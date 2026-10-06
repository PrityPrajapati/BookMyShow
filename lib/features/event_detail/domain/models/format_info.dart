import 'package:flutter/material.dart';

/// Information and specifications for cinema screen formats
class FormatInfo {
  final String id;
  final String name;
  final String tag;
  final String description;
  final String audioSpec;
  final String visualSpec;
  final IconData icon;
  final double defaultDelta;

  const FormatInfo({
    required this.id,
    required this.name,
    required this.tag,
    required this.description,
    required this.audioSpec,
    required this.visualSpec,
    required this.icon,
    required this.defaultDelta,
  });

  static const List<FormatInfo> allFormats = [
    FormatInfo(
      id: '2D',
      name: '2D Standard Digital',
      tag: 'Base',
      description:
          'High-definition digital cinema projection with pristine clarity and natural color balance.',
      audioSpec: 'Dolby 7.1 Surround Sound',
      visualSpec: '2K / 4K Digital RGB Laser',
      icon: Icons.movie_outlined,
      defaultDelta: 0.0,
    ),
    FormatInfo(
      id: '3D',
      name: 'RealD 3D',
      tag: '+₹80',
      description:
          'Ultra-vivid stereoscopic depth with lightweight circular polarized glasses for seamless immersion.',
      audioSpec: 'Dolby Atmos Immersive Audio',
      visualSpec: 'High-Frame-Rate 3D Digital',
      icon: Icons.view_in_ar_rounded,
      defaultDelta: 80.0,
    ),
    FormatInfo(
      id: 'IMAX 2D',
      name: 'IMAX 2D Laser',
      tag: '+₹180',
      description:
          'Floor-to-ceiling custom curved screen, dual 4K laser projection, and proprietary DMR digital re-mastering.',
      audioSpec: '12-Channel Next-Gen Laser Audio',
      visualSpec: 'Expanded 1.90:1 Aspect Ratio',
      icon: Icons.aspect_ratio_rounded,
      defaultDelta: 180.0,
    ),
    FormatInfo(
      id: 'IMAX 3D',
      name: 'IMAX 3D Laser',
      tag: '+₹260',
      description:
          'The zenith of cinematic reality combining immense IMAX scale with polarized laser-aligned 3D visuals.',
      audioSpec: '12-Channel Spatial Sound',
      visualSpec: 'Dual 4K Laser 3D Projection',
      icon: Icons.vrpano_rounded,
      defaultDelta: 260.0,
    ),
    FormatInfo(
      id: '4DX',
      name: '4DX Motion & Effects',
      tag: '+₹320',
      description:
          'Synchronized motion seats paired with atmospheric effects including wind, fog, lightning, water, and aromas.',
      audioSpec: 'Dolby Surround Sound',
      visualSpec: 'Dynamic Environmental Effects & Haptics',
      icon: Icons.airline_seat_recline_extra_rounded,
      defaultDelta: 320.0,
    ),
  ];
}
