import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Halloween Dimensions
/// Spooky and dramatic spacing and elevation system
/// Following Material Design 3 with gothic, haunting proportions
class HalloweenDimen implements DSDimen {
  const HalloweenDimen();

  // Radius system - gothic, dramatic curves with spooky character
  @override
  DSRadius get radiusLevel1 => const DSRadius(2.0); // Sharp, angular for spooky elements

  @override
  DSRadius get radiusLevel2 => const DSRadius(6.0); // Moderately gothic containers

  @override
  DSRadius get radiusLevel3 => const DSRadius(12.0); // Dramatic haunted prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - dramatic, haunting shadows with gothic depth
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(3.0); // Enhanced spooky elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(6.0); // Dramatic gothic elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(12.0); // Haunting prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
