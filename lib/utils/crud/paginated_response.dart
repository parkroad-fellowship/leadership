import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';

@freezed
abstract class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    @Default(PaginationMeta()) PaginationMeta pagination,
  }) = _PaginatedResponse<T>;

  factory PaginatedResponse.fromMap({
    required List<T> data,
    required Map<String, dynamic> payload,
  }) {
    return PaginatedResponse<T>(
      data: data,
      pagination: PaginationMeta.fromMap(payload),
    );
  }
}

@freezed
abstract class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    int? currentPage,
    String? currentPageUrl,
    String? path,
    int? perPage,
    int? from,
    int? to,
    String? firstUrl,
    String? lastUrl,
    String? previousUrl,
    String? nextUrl,
    @Default(false) bool hasNext,
    @Default(false) bool hasPrevious,
  }) = _PaginationMeta;

  factory PaginationMeta.fromMap(Map<String, dynamic> payload) {
    final links = payload['links'];
    final meta = payload['meta'];

    final linksMap = links is Map<String, dynamic>
        ? links
        : <String, dynamic>{};
    final metaMap = meta is Map<String, dynamic> ? meta : <String, dynamic>{};

    final nextUrl = _asString(linksMap['next']);
    final previousUrl = _asString(linksMap['prev']);

    return PaginationMeta(
      currentPage: _asInt(metaMap['current_page']),
      currentPageUrl: _asString(metaMap['current_page_url']),
      path: _asString(metaMap['path']),
      perPage: _asInt(metaMap['per_page']),
      from: _asInt(metaMap['from']),
      to: _asInt(metaMap['to']),
      firstUrl: _asString(linksMap['first']),
      lastUrl: _asString(linksMap['last']),
      previousUrl: previousUrl,
      nextUrl: nextUrl,
      hasNext: nextUrl != null,
      hasPrevious: previousUrl != null,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }
}
