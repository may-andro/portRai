import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Hogeras Dimensions
/// Mediterranean coastal spacing and elevation system
/// Following Material Design 3 with warm, flowing Spanish proportions
class HogerasDimen implements DSDimen {
  const HogerasDimen();

  // Radius system - flowing, Mediterranean curves reflecting coastal waves
  @override
  DSRadius get radiusLevel1 => const DSRadius(5.0); // Gentle coastal curves

  @override
  DSRadius get radiusLevel2 => const DSRadius(10.0); // Flowing Mediterranean containers

  @override
  DSRadius get radiusLevel3 => const DSRadius(20.0); // Warm, passionate prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - warm, glowing shadows reflecting bonfire light
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(2.0); // Gentle coastal elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(4.0); // Mediterranean standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(8.0); // Passionate prominent elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
