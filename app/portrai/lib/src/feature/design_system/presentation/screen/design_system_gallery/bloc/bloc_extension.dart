import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/design_system_gallery_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/design_system_gallery_state.dart';

extension ContextExtension on BuildContext {
  DesignSystemGalleryBloc get bloc => read<DesignSystemGalleryBloc>();

  DesignSystemGalleryState get state => bloc.state;
}
