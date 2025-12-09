// class SafetyVideo {
//   final String title;
//   final String url; // Online video URL

//   SafetyVideo({required this.title, required this.url});
// }

class YouTubeVideo {
  final String title;
  final String url; // YouTube URL
  final String thumbnail;

  YouTubeVideo({
    required this.title,
    required this.url,
    required this.thumbnail,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      title: json['title'] ?? "",
      url: json['url'],
      thumbnail:
          json['thumbnail'] ??
          'https://img.youtube.com/vi/${json['url'].split("v=").last}/0.jpg',
    );
  }
}
