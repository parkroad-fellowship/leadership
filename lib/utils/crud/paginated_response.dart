/// Holds a page of results plus metadata for pagination.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    this.totalCount,
  });

  final List<T> items;
  final int currentPage;
  final bool hasMore;
  final int? totalCount;
}
