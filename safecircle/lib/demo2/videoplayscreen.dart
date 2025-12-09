// import 'package:flutter/material.dart';
// import 'package:safecircle/demo2/videomodel.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final SafetyVideo video;
//   VideoPlayerScreen({required this.video});

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   ChewieController? _chewieController;
//   late Future<void> _initializeVideoPlayerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.video.url);
//     _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//       _chewieController = ChewieController(
//         videoPlayerController: _controller,
//         autoPlay: true,
//         looping: false,
//         allowFullScreen: true,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.video.title)),
//       body: FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Chewie(controller: _chewieController!);
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error loading video"));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safecircle/demo2/videomodel.dart';
import 'package:safecircle/demo2/videoscreen.dart';
import 'dart:convert';

class YouTubeVideoListScreen extends StatefulWidget {
  @override
  _YouTubeVideoListScreenState createState() => _YouTubeVideoListScreenState();
}

class _YouTubeVideoListScreenState extends State<YouTubeVideoListScreen> {
  List<YouTubeVideo> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/videos"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videoList = data['videos'] as List;
        setState(() {
          videos = videoList
              .map((json) => YouTubeVideo.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching videos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YouTube Videos")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YouTubeVideoScreen(
                          videoUrl: video.url,
                          thumbnailUrl: video.thumbnail,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        video.thumbnail,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Icon(
                        Icons.play_circle_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: Colors.black54,
                          child: Text(
                            video.title,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
