import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProductVideoWidget extends StatefulWidget {
  final String videoUrl;

  const ProductVideoWidget({
    super.key,
    required this.videoUrl,
  });

  @override
  State<ProductVideoWidget> createState() => _ProductVideoWidgetState();
}

class _ProductVideoWidgetState extends State<ProductVideoWidget> {
  late VideoPlayerController videoController;

  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await videoController.initialize();

    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          ),

          GestureDetector(
            onTap: () {
              if (videoController.value.isPlaying) {
                videoController.pause();
              } else {
                videoController.play();
              }
              setState(() {});
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: videoController.value.isPlaying ? 0 : 1,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black54,
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}