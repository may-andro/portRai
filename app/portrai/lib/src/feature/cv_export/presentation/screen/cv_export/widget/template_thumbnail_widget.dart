part of 'content_widget.dart';

/// A miniature sketch of a template's layout, drawn in the chosen accent.
class _TemplateThumbnailWidget extends StatelessWidget {
  const _TemplateThumbnailWidget({required this.template, required this.color});

  final CvTemplate template;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: switch (template) {
          CvTemplate.sidebar => _sidebar(),
          CvTemplate.classic => _classic(),
          CvTemplate.minimal => _minimal(),
          CvTemplate.bold => _bold(),
        },
      ),
    );
  }

  static const Color _line = Color(0xFFD5D9DE);

  Widget _lines(int count, {double heading = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading > 0)
          Container(
            width: heading,
            height: 3,
            margin: const EdgeInsets.only(bottom: 3),
            color: color,
          ),
        for (var lineIndex = 0; lineIndex < count; lineIndex++)
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 2),
            width: lineIndex.isOdd ? 34 : double.infinity,
            color: _line,
          ),
      ],
    );
  }

  Widget _sidebar() {
    return Row(
      children: [
        Container(
          width: 26,
          color: color.withValues(alpha: 0.12),
          padding: const EdgeInsets.all(4),
          child: _lines(6, heading: 12),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 30, height: 4, color: const Color(0xFF1F2933)),
                const SizedBox(height: 5),
                _lines(3, heading: 14),
                const SizedBox(height: 3),
                _lines(5, heading: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _classic() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 34,
              height: 4,
              color: const Color(0xFF1F2933),
            ),
          ),
          const SizedBox(height: 5),
          Container(height: 1, color: color),
          const SizedBox(height: 4),
          _lines(3),
          Container(height: 1, color: color),
          const SizedBox(height: 4),
          _lines(5),
          Container(height: 1, color: color),
          const SizedBox(height: 4),
          _lines(2),
        ],
      ),
    );
  }

  Widget _minimal() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 30, height: 4, color: const Color(0xFF1F2933)),
          const SizedBox(height: 3),
          Container(width: 14, height: 1.5, color: color),
          const SizedBox(height: 6),
          for (var rowIndex = 0; rowIndex < 3; rowIndex++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 9, height: 2, color: color),
                  const SizedBox(width: 4),
                  Expanded(child: _lines(rowIndex == 1 ? 3 : 2)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bold() {
    return Column(
      children: [
        Container(
          height: 24,
          color: color,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(5),
          child: Container(width: 30, height: 4, color: Colors.white),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _lines(7, heading: 14)),
                const SizedBox(width: 4),
                Expanded(child: _lines(5, heading: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
