import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Holi Dimensions
/// Playful and vibrant spacing and elevation system
/// Following Material Design 3 with joyful, colorful proportions
class HoliDimen implements DSDimen {
  const HoliDimen();

  // Radius system - playful, vibrant curves reflecting colorful celebration
  @override
  DSRadius get radiusLevel1 => const DSRadius(8.0); // Playful curves for colorful elements

  @override
  DSRadius get radiusLevel2 => const DSRadius(16.0); // Vibrant container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(24.0); // Joyful prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - vibrant, colorful shadows reflecting festival energy
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(2.0); // Gentle colorful elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(4.0); // Vibrant standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(8.0); // Joyful prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
