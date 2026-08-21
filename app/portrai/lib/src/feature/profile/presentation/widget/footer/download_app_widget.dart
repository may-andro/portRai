part of 'footer_widget.dart';

class _DownloadAppWidget extends StatelessWidget {
  const _DownloadAppWidget();

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    final storeButtonWidgets = state.profile.publishedAt.map((store) {
      if (store.name == 'Website') {
        return const SizedBox.shrink();
      }

      return _StoreButtonWidget(
        image: store.image,
        store: store.name,
        onTap: () {
          context.bloc.add(
            OpenExternalUrlEvent(label: store.name, url: store.url),
          );
        },
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        DSTextWidget(
          context.localizations.downloadTheApp,
          color: context.colorPalette.onInverseSurface,
          style: context.typography.emphasizedTitleMedium,
        ),
        ...storeButtonWidgets,
      ],
    );
  }
}

class _StoreButtonWidget extends StatelessWidget {
  const _StoreButtonWidget({
    required this.image,
    required this.store,
    required this.onTap,
  });

  final String image;
  final String store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      radius: context.dimen.radiusLevel2,
      backgroundColor: context.colorPalette.onInverseSurface,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.space(factor: 0.25),
          horizontal: context.space(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(),
          children: [
            DSNetworkImageWidget(
              url: image,
              width: context.space(factor: 5),
              height: context.space(factor: 5),
              color: context.colorPalette.surface.inverseSurface,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSTextWidget(
                  context.localizations.downloadAppAt,
                  style: context.typography.emphasizedLabelLarge,
                  color: context.colorPalette.surface.inverseSurface,
                ),
                DSTextWidget(
                  store,
                  style: context.typography.emphasizedTitleMedium,
                  color: context.colorPalette.surface.inverseSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
