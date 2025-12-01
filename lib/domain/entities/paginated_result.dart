class PaginatedResult<T> {
  final List<T> items;
  final String? nextPageToken;

  const PaginatedResult({required this.items, this.nextPageToken});
}
