import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Christmas Dimensions
/// Festive and cozy spacing and elevation system
/// Following Material Design 3 with warm, holiday-inspired proportions
class ChristmasDimen implements DSDimen {
  const ChristmasDimen();

  // Radius system - warm, festive curves reflecting holiday comfort
  @override
  DSRadius get radiusLevel1 => const DSRadius(8.0); // Cozy, warm curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(16.0); // Festive container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(24.0); // Joyful prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - warm, glowing shadows reflecting Christmas lights
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(3.0); // Gentle holiday glow

  @override
  DSElevation get elevationLevel2 => const DSElevation(6.0); // Festive standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(12.0); // Joyful prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
