import 'package:design_system/src/foundation/dimen/ds_dimen.dart';
import 'package:design_system/src/foundation/dimen/ds_elevation.dart';
import 'package:design_system/src/foundation/dimen/ds_grid.dart';
import 'package:design_system/src/foundation/dimen/ds_radius.dart';

/// Carnival Dimensions
/// Festive and celebratory spacing and elevation system
/// Following Material Design 3 with vibrant, party-inspired proportions
class CarnivalDimen implements DSDimen {
  const CarnivalDimen();

  // Radius system - festive, celebratory curves
  @override
  DSRadius get radiusLevel1 => const DSRadius(6.0); // Slightly larger for festive buttons

  @override
  DSRadius get radiusLevel2 => const DSRadius(12.0); // Celebratory cards and containers

  @override
  DSRadius get radiusLevel3 => const DSRadius(20.0); // Bold, party-style prominent elements

  @override
  DSRadius get radiusCircular => const DSRadius(1000.0); // Fully circular elements

  // Elevation system - dramatic, festival-inspired shadows
  @override
  DSElevation get elevationNone => const DSElevation(0.0);

  @override
  DSElevation get elevationLevel1 => const DSElevation(2.0); // Enhanced subtle elevation

  @override
  DSElevation get elevationLevel2 => const DSElevation(4.0); // Festive standard elevation

  @override
  DSElevation get elevationLevel3 => const DSElevation(8.0); // Bold carnival elevation

  // Grid system - 8dp base unit following Material Design
  @override
  DSGrid get grid => const DSGrid(8.0); // Base grid unit for consistent spacing
}
