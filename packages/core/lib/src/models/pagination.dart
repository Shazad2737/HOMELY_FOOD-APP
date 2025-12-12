// "pagination":{"page":1,"per_page":10,"page_count":17,"total_docs":164}
class Pagination {
  Pagination({
    this.page,
    this.perPage,
    this.pageCount,
    this.totalDocs,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json['page'] as int?,
        perPage: json['per_page'] as int?,
        pageCount: json['page_count'] as int?,
        totalDocs: json['total_docs'] as int?,
      );

  int? page;
  int? pageCount;
  int? perPage;
  int? totalDocs;

  Map<String, dynamic> toJson() => {
        'page': page,
        'per_page': perPage,
        'page_count': pageCount,
        'total_docs': totalDocs,
      };
}
