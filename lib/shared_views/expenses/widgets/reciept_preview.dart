import 'package:flutter/material.dart';
import 'package:leadership/models/remote/prf_media.dart';

class ReceiptPreviewPage extends StatefulWidget {
  const ReceiptPreviewPage({
    required this.receipts,
    required this.initialIndex,
    super.key,
  });

  final List<PRFMedia> receipts;
  final int initialIndex;

  @override
  State<ReceiptPreviewPage> createState() => ReceiptPreviewPageState();
}

class ReceiptPreviewPageState extends State<ReceiptPreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Receipt ${_currentIndex + 1} of ${widget.receipts.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.receipts.length,
        itemBuilder: (context, index) {
          final receipt = widget.receipts[index];
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                receipt.temporaryURL,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
