import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/design_system_card_event.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/design_system_card_state.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/tracking/_tracking.dart';

@register
class DesignSystemCardBloc
    extends Bloc<DesignSystemCardEvent, DesignSystemCardState> {
  DesignSystemCardBloc(this._trackingDelegate)
    : super(const DesignSystemCardState()) {
    on<DesignSystemCardClickEvent>(_mapDesignSystemCardClickEventToState);
  }

  final DesignSystemCardTrackingDelegate _trackingDelegate;

  void _mapDesignSystemCardClickEventToState(
    DesignSystemCardClickEvent event,
    Emitter<DesignSystemCardState> emit,
  ) => _trackingDelegate.trackThemeGalleryClick(event.label);
}
