import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leadership/utils/_index.dart';

class HomeActionCardHandset extends StatelessWidget {
  const HomeActionCardHandset({
    required this.title,
    required this.assetPath,
    this.onTap,
    super.key,
  });

  final String title;
  final String assetPath;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = Misc.getScaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: width,
            padding: EdgeInsets.fromLTRB(
              24 * scaleFactor,
              20 * scaleFactor,
              88 * scaleFactor,
              20 * scaleFactor,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(24 * scaleFactor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(assetPath, height: 100 * scaleFactor),
                SizedBox(height: 24 * scaleFactor),
                Text(
                  title,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16 * scaleFactor), // Add bottom spacing
              ],
            ),
          ),
          Positioned(
            right: 4,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox.square(dimension: 60 * scaleFactor),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 40 * scaleFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 70 * scaleFactor,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40 * scaleFactor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
