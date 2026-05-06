import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/foundation.dart';

/// Pachamama Dimensions
/// Grounded and natural spacing and elevation system
/// Following Material Design 3 with nurturing, earth-connected proportions
class PachamamaDimen implements DSDimen {
  const PachamamaDimen();

  // Radius system - natural, earth-connected curves reflecting Andean landscapes
  @override
  DSRadius get radiusLevel1 => const DSRadius(6.0); // Natural, grounded curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(12.0); // Earth-connected container curves

  @override
  DSRadius get radiusLevel3 => const DSRadius(18.0); // Nurturing prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - grounded, natural shadows reflecting earth connection
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(2.0); // Gentle earth elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(4.0); // Natural standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(6.0); // Nurturing prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
