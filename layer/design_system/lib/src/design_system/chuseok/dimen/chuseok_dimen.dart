import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Chuseok Dimensions
/// Traditional and harmonious spacing and elevation system
/// Following Material Design 3 with Korean cultural proportions and elegance
class ChuseokDimen implements DSDimen {
  const ChuseokDimen();

  // Radius system - traditional, harmonious curves
  @override
  DSRadius get radiusLevel1 => const DSRadius(4.0); // Gentle, traditional curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(8.0); // Balanced traditional containers

  @override
  DSRadius get radiusLevel3 => const DSRadius(16.0); // Respectful, elegant prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - subtle, respectful shadows reflecting Korean aesthetics
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(1.0); // Gentle elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(2.0); // Traditional subtle elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(4.0); // Respectful prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
