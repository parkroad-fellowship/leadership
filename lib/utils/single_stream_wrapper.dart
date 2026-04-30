import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:prf_design/prf_design.dart';

class SingleStreamWrapper<T> extends StatelessWidget {
  const SingleStreamWrapper({
    required this.stream,
    required this.widget,
    this.loading = const PRFCircularProgressIndicator(),
    this.nullWidget = const SizedBox.shrink(),
    super.key,
  });

  final Stream<T> stream;
  final Widget loading;
  final Widget Function(BuildContext, T) widget;
  final Widget nullWidget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        Logger().e(snapshot);
        if (!snapshot.hasData) {
          return loading;
        }

        final entity = snapshot.data;

        if (entity == null) {
          return nullWidget;
        }

        if (entity is List && entity.isEmpty) {
          return nullWidget;
        }

        return widget(context, entity);
      },
    );
  }
}
