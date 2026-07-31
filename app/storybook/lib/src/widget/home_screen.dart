import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.black87 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final descColor = isDark ? Colors.white70 : Colors.black87;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.black, Colors.grey[900]!]
              : [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Card(
          elevation: 8,
          margin: EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 64, height: 64, child: DSImage.logo()),
                const SizedBox(height: 24),
                Text(
                  'PortRai Storybook',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Explore and interact with all UI concepts and components.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: descColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    _ConceptCard(
                      title: 'Foundation',
                      description:
                          'Core design tokens, colors, typography, spacing, and theming.',
                      icon: Icons.layers,
                      onTap: () {},
                      // TODO: Link to Foundation section
                      color: cardColor,
                      textColor: textColor,
                      descColor: descColor,
                    ),
                    const SizedBox(height: 16),
                    _ConceptCard(
                      title: 'Atom',
                      description:
                          'Basic UI elements: buttons, icons, inputs, etc.',
                      icon: Icons.blur_on,
                      onTap: () {},
                      // TODO: Link to Atom components
                      color: cardColor,
                      textColor: textColor,
                      descColor: descColor,
                    ),
                    const SizedBox(height: 16),
                    _ConceptCard(
                      title: 'Molecule',
                      description:
                          'Composed UI elements: form fields, cards, lists.',
                      icon: Icons.scatter_plot,
                      onTap: () {},
                      // TODO: Link to Molecule components
                      color: cardColor,
                      textColor: textColor,
                      descColor: descColor,
                    ),
                    const SizedBox(height: 16),
                    _ConceptCard(
                      title: 'Organism',
                      description:
                          'Complex UI blocks: navigation bars, dialogs, feature sections.',
                      icon: Icons.bubble_chart,
                      onTap: () {},
                      // TODO: Link to Organism components
                      color: cardColor,
                      textColor: textColor,
                      descColor: descColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Color descColor;

  const _ConceptCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.textColor,
    required this.descColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, size: 32, color: textColor),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: descColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
