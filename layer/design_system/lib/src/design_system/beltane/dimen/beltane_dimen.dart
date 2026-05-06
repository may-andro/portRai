import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Beltane Dimensions
/// Organic and nature-inspired spacing and elevation system
/// Following Material Design 3 with a natural, organic feel
class BeltaneDimen implements DSDimen {
  const BeltaneDimen();

  // Radius system - organic, softer curves inspired by nature
  @override
  DSRadius get radiusLevel1 => const DSRadius(4.0); // Small radius for buttons, chips

  @override
  DSRadius get radiusLevel2 => const DSRadius(8.0); // Medium radius for cards, containers

  @override
  DSRadius get radiusLevel3 => const DSRadius(16.0); // Large radius for prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - subtle, natural shadows
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(1.0); // Subtle elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(3.0); // Standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(6.0); // Prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
