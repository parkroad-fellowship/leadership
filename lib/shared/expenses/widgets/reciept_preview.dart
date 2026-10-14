import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:prf_design/prf_design.dart';

/// Full-screen receipt viewer.
///
/// Deliberately keeps fixed dark chrome (black backdrop, white text/icons —
/// 21:1 contrast) so photos of receipts read clearly in either theme.
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
  // Fixed media-viewer chrome; see class doc.
  static const Color _chrome = Colors.black;
  static const Color _onChrome = Colors.white;

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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _chrome,
      appBar: AppBar(
        backgroundColor: _chrome,
        foregroundColor: _onChrome,
        leading: IconButton(
          tooltip: l10n.expenseCloseReceipts,
          icon: const Icon(Icons.close, size: PRFSizeTokens.iconLg),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Semantics(
          liveRegion: true,
          child: Text(
            l10n.expenseReceiptCounter(
              _currentIndex + 1,
              widget.receipts.length,
            ),
            style: theme.textTheme.titleMedium?.copyWith(color: _onChrome),
          ),
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
                semanticLabel: l10n.expenseReceiptCounter(
                  index + 1,
                  widget.receipts.length,
                ),
                errorBuilder: (context, error, stackTrace) {
                  return Padding(
                    padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_not_supported_outlined,
                          color: _onChrome,
                          size: PRFSizeTokens.iconHero,
                        ),
                        const SizedBox(height: PRFSpacingTokens.lg),
                        Text(
                          l10n.expenseReceiptImageFailed,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _onChrome,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: PRFCircularProgressIndicator(
                      size: PRFSizeTokens.iconXxl,
                      color: _onChrome,
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
