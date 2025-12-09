// import 'package:flutter/material.dart';
// import 'package:safecircle/demo2/videomodel.dart';
// import 'package:safecircle/demo2/videoplayscreen.dart';

// class VideoScreen extends StatelessWidget {
//   final List<SafetyVideo> videos = [
//     SafetyVideo(
//       title: "Self-Defense Basics",
//       url:
//           "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
//     ),
//     SafetyVideo(
//       title: "Street Safety Tips",
//       url:
//           "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Self-Safety Videos")),
//       body: ListView.builder(
//         itemCount: videos.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             leading: Icon(Icons.play_circle_fill, color: Colors.red),
//             title: Text(videos[index].title),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => VideoPlayerScreen(video: videos[index]),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;

  YouTubeVideoScreen({required this.videoUrl, required this.thumbnailUrl});

  @override
  _YouTubeVideoScreenState createState() => _YouTubeVideoScreenState();
}

class _YouTubeVideoScreenState extends State<YouTubeVideoScreen> {
  YoutubePlayerController? _controller;
  bool _isPlaying = false;

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(autoPlay: true, mute: false),
    );
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YouTube Video")),
      body: Center(
        child: _isPlaying
            ? YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
              )
            : GestureDetector(
                onTap: _initializePlayer,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(widget.thumbnailUrl),
                    Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
