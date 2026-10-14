import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

/// Builds a Lottie bar chart with one bar per skill, as tall as the years of
/// hands-on use (or the proficiency level when the years are unknown). The
/// bars grow in one after the other, hold, and shrink back before looping.
class ExpertiseStatsLottieBuilder {
  const ExpertiseStatsLottieBuilder();

  static const _width = 800.0;
  static const _height = 300.0;
  static const _baseline = 280.0;
  static const _frames = 300;
  static const _growFrames = 40;
  static const _maxBarHeight = 240.0;

  Uint8List build(
    ExpertiseEntity expertise, {
    required Color color,
    required Color accent,
  }) {
    final skills = expertise.skills;
    final maxYears = expertise.maxYears ?? 0;
    final slot = skills.isEmpty ? _width : _width / skills.length;
    final barWidth = (slot * 0.55).clamp(6.0, 44.0);
    final stagger = skills.length <= 1
        ? 0
        : ((_frames - 2 * _growFrames - 20) / skills.length).floor().clamp(
            1,
            6,
          );

    final layers = <Map<String, Object?>>[
      _baselineLayer(index: 1, color: color),
      for (final (index, skill) in skills.indexed)
        _barLayer(
          index: index + 2,
          x: slot * index + slot / 2,
          width: barWidth,
          height: _barHeight(skill, maxYears),
          color: skill.level == 'expert' ? accent : color,
          start: index * stagger,
        ),
    ];

    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'v': '5.7.0',
          'fr': 60,
          'ip': 0,
          'op': _frames,
          'w': _width,
          'h': _height,
          'nm': 'expertise_stats',
          'ddd': 0,
          'assets': <Object>[],
          'layers': layers,
        }),
      ),
    );
  }

  double _barHeight(SkillEntity skill, int maxYears) {
    final ratio = skill.years != null && maxYears > 0
        ? skill.years! / maxYears
        : switch (skill.level) {
            'expert' => 1.0,
            'advanced' => 0.75,
            'intermediate' => 0.5,
            _ => 0.3,
          };
    return 40 + (_maxBarHeight - 40) * ratio.clamp(0.0, 1.0);
  }

  Map<String, Object?> _barLayer({
    required int index,
    required double x,
    required double width,
    required double height,
    required Color color,
    required int start,
  }) {
    final grown = start + _growFrames;
    final shrink = _frames - _growFrames - 10 + start ~/ 2;

    return {
      'ddd': 0,
      'ind': index,
      'ty': 4,
      'nm': 'bar',
      'sr': 1,
      'ks': {
        'o': _static(100),
        'r': _static(0),
        'p': _static([x, _baseline, 0]),
        'a': _static([0, 0, 0]),
        's': _keyframes([
          (0, [100.0, 0.0, 100.0]),
          (start, [100.0, 0.0, 100.0]),
          (grown, [100.0, 100.0, 100.0]),
          (shrink, [100.0, 100.0, 100.0]),
          (shrink + _growFrames - 10, [100.0, 0.0, 100.0]),
          (_frames, [100.0, 0.0, 100.0]),
        ]),
      },
      'ao': 0,
      'shapes': [
        {
          'ty': 'gr',
          'it': [
            {
              'ty': 'rc',
              'p': _static([0, -height / 2]),
              's': _static([width, height]),
              'r': _static(width / 3),
            },
            {'ty': 'fl', 'c': _static(_rgba(color)), 'o': _static(80), 'r': 1},
            _transform(),
          ],
        },
      ],
      'ip': 0,
      'op': _frames,
      'st': 0,
      'bm': 0,
    };
  }

  Map<String, Object?> _baselineLayer({
    required int index,
    required Color color,
  }) {
    return {
      'ddd': 0,
      'ind': index,
      'ty': 4,
      'nm': 'baseline',
      'sr': 1,
      'ks': {
        'o': _static(100),
        'r': _static(0),
        'p': _static([0, 0, 0]),
        'a': _static([0, 0, 0]),
        's': _static([100, 100, 100]),
      },
      'ao': 0,
      'shapes': [
        {
          'ty': 'gr',
          'it': [
            {
              'ty': 'sh',
              'ks': _static({
                'c': false,
                'v': [
                  [0, _baseline + 6],
                  [_width, _baseline + 6],
                ],
                'i': [
                  [0, 0],
                  [0, 0],
                ],
                'o': [
                  [0, 0],
                  [0, 0],
                ],
              }),
            },
            {
              'ty': 'st',
              'c': _static(_rgba(color)),
              'o': _static(50),
              'w': _static(2),
              'lc': 2,
              'lj': 1,
            },
            _transform(),
          ],
        },
      ],
      'ip': 0,
      'op': _frames,
      'st': 0,
      'bm': 0,
    };
  }

  List<double> _rgba(Color color) => [color.r, color.g, color.b, 1.0];

  Map<String, Object?> _static(Object? value) => {'a': 0, 'k': value};

  Map<String, Object?> _keyframes(List<(int, List<double>)> frames) {
    final unique = <(int, List<double>)>[];
    for (final frame in frames) {
      if (unique.isNotEmpty && unique.last.$1 >= frame.$1) continue;
      unique.add(frame);
    }
    return {
      'a': 1,
      'k': [
        for (final (index, frame) in unique.indexed)
          {
            't': frame.$1,
            's': frame.$2,
            if (index < unique.length - 1) ...{
              'i': {
                'x': List.filled(frame.$2.length, 0.3),
                'y': List.filled(frame.$2.length, 1),
              },
              'o': {
                'x': List.filled(frame.$2.length, 0.7),
                'y': List.filled(frame.$2.length, 0),
              },
            },
          },
      ],
    };
  }

  Map<String, Object?> _transform() {
    return {
      'ty': 'tr',
      'p': _static([0, 0]),
      'a': _static([0, 0]),
      's': _static([100, 100]),
      'r': _static(0),
      'o': _static(100),
    };
  }
}
