import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Obon Dimensions
/// Serene and contemplative spacing and elevation system
/// Following Material Design 3 with peaceful, Japanese spiritual proportions
class ObonDimen implements DSDimen {
  const ObonDimen();

  // Radius system - serene, contemplative curves reflecting Japanese aesthetics
  @override
  DSRadius get radiusLevel1 => const DSRadius(4.0); // Gentle, peaceful curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(8.0); // Contemplative container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(12.0); // Spiritual prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - subtle, spiritual shadows reflecting lantern glow
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(1.0); // Gentle spiritual elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(2.0); // Contemplative standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(4.0); // Peaceful prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
