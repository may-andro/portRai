import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Sakura Dimensions
/// Delicate and elegant spacing and elevation system
/// Following Material Design 3 with gentle, ephemeral Japanese proportions
class SakuraDimen implements DSDimen {
  const SakuraDimen();

  // Radius system - delicate, petal-like curves reflecting cherry blossom softness
  @override
  DSRadius get radiusLevel1 => const DSRadius(3.0); // Delicate, petal-soft curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(6.0); // Gentle spring container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(12.0); // Graceful prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - subtle, ethereal shadows reflecting floating petals
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(1.0); // Gentle petal elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(2.0); // Delicate standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(3.0); // Graceful prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
