import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Hogmanay Dimensions
/// Highland Scottish spacing and elevation system
/// Following Material Design 3 with noble, Celtic proportions
class HogmanayDimen implements DSDimen {
  const HogmanayDimen();

  // Radius system - noble, Celtic curves reflecting Highland heritage
  @override
  DSRadius get radiusLevel1 => const DSRadius(4.0); // Noble, dignified curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(8.0); // Highland container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(16.0); // Ceremonial prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - dignified, Highland shadows reflecting Celtic heritage
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(1.0); // Gentle Highland elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(3.0); // Noble standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(6.0); // Ceremonial prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
