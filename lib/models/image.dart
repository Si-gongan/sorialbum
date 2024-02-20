class Image {
  final int id;

  String? caption = DateTime.now().toString();
  String? description = 'sample description';
  String? userMemo = 'sample user memo';

  List<String>? generalTags = ['gtag1', 'gtag2', 'gtag3'];
  List<String>? alertTags = ['atag1', 'atag2'];

  final String mainUrl;
  String? thumbnailUrl;

  DateTime createdAt = DateTime.now();

  Image(this.id, this.mainUrl);
}
