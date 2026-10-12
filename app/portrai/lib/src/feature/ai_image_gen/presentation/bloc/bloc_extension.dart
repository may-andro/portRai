import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/ai_image_bloc.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/ai_image_state.dart';

extension ContextExtension on BuildContext {
  AiImageBloc get bloc => read<AiImageBloc>();

  AiImageState get state => bloc.state;
}
