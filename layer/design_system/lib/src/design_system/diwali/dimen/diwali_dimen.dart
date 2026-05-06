import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Diwali Dimensions
/// Luminous and divine spacing and elevation system
/// Following Material Design 3 with radiant, spiritual proportions
class DiwaliDimen implements DSDimen {
  const DiwaliDimen();

  // Radius system - luminous, divine curves representing diya flames
  @override
  DSRadius get radiusLevel1 => const DSRadius(6.0); // Gentle flame-like curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(10.0); // Divine container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(18.0); // Radiant prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - luminous, glowing shadows reflecting divine light
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(2.0); // Gentle divine glow

  @override
  DSElevation get elevationLevel2 => const DSElevation(4.0); // Luminous standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(8.0); // Radiant prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
