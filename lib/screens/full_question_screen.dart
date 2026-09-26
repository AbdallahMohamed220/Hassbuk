import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../app_strings.dart';
import '../models.dart';

class FullQuestionScreen extends StatefulWidget {
  const FullQuestionScreen({
    super.key,
    required this.question,
    required this.passage,
    required this.language,
  });

  final QuranVerse question;
  final List<QuranVerse> passage;
  final AppLanguage language;

  @override
  State<FullQuestionScreen> createState() => _FullQuestionScreenState();
}

class _FullQuestionScreenState extends State<FullQuestionScreen> {
  late final AudioPlayer player;
  File? mergedAudioFile;
  final temporaryFiles = <File>[];
  bool isPreparing = false;
  bool isDisposed = false;
  FFmpegSession? mergeSession;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
  }

  @override
  void dispose() {
    isDisposed = true;
    mergeSession?.cancel();
    player.stop();
    player.dispose();
    super.dispose();
  }

  Future<File> mergeVerseAudio() async {
    final urls = widget.passage
        .map((verse) => verse.audioUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
    if (urls.isEmpty) throw Exception('No verse audio URLs');

    final directory = await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final inputFiles = <File>[];
    final client = HttpClient();
    try {
      for (var index = 0; index < urls.length; index++) {
        final request = await client.getUrl(Uri.parse(urls[index]));
        final response = await request.close();
        if (isDisposed) throw Exception('Audio preparation cancelled');
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Audio download failed');
        }
        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        final file = File('${directory.path}/hassbuk_${stamp}_$index.mp3');
        await file.writeAsBytes(bytes, flush: true);
        inputFiles.add(file);
        temporaryFiles.add(file);
      }
    } finally {
      client.close(force: true);
    }

    final listFile = File('${directory.path}/hassbuk_$stamp.txt');
    final outputFile = File('${directory.path}/hassbuk_$stamp.m4a');
    temporaryFiles.add(listFile);
    temporaryFiles.add(outputFile);
    final list = inputFiles
        .map((file) => "file '${file.path.replaceAll("'", "'\\''")}'")
        .join('\n');
    await listFile.writeAsString(list, flush: true);
    final command =
        "-f concat -safe 0 -i '${listFile.path}' -c:a aac -b:a 128k -y '${outputFile.path}'";
    mergeSession = await FFmpegKit.execute(command);
    final session = mergeSession!;
    final returnCode = await session.getReturnCode();
    mergeSession = null;
    if (isDisposed) throw Exception('Audio preparation cancelled');
    if (!ReturnCode.isSuccess(returnCode)) {
      throw Exception('Audio merge failed');
    }
    return outputFile;
  }

  Future<void> toggleAudio() async {
    try {
      if (player.playing) {
        await player.pause();
        return;
      }
      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
      } else if (mergedAudioFile == null) {
        if (!mounted) return;
        setState(() => isPreparing = true);
        mergedAudioFile = await mergeVerseAudio();
        if (!mounted || isDisposed) return;
        await player.setFilePath(mergedAudioFile!.path);
        if (mounted) setState(() => isPreparing = false);
      }
      if (!mounted || isDisposed) return;
      await player.play();
    } catch (_) {
      if (mounted) setState(() => isPreparing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings(widget.language).audioUnavailable)),
      );
    }
  }

  Future<void> seekBy(Duration offset) async {
    final duration = player.duration;
    var target = player.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (duration != null && target > duration) target = duration;
    await player.seek(target);
  }

  String formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${value.inHours > 0 ? '${value.inHours}:' : ''}$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);
    final colors = Theme.of(context).colorScheme;
    final passageText = widget.passage
        .map(
          (verse) => widget.language == AppLanguage.ar
              ? '${verse.textAr} ${strings.quranVerseNumber(verse.ayah)}'
              : '${verse.textEn} ${strings.quranVerseNumber(verse.ayah)}',
        )
        .join(' ');
    return Scaffold(
      appBar: AppBar(title: Text(strings.fullQuestion)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Directionality(
                  textDirection: widget.language == AppLanguage.ar
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          passageText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: widget.language == AppLanguage.ar
                                ? 'Amiri Quran'
                                : 'Georgia',
                            fontSize: widget.language == AppLanguage.ar
                                ? 20
                                : 16,
                            height: 1.8,
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final hasAudio = widget.passage.any(
                      (verse) => verse.audioUrl?.isNotEmpty == true,
                    );
                    final isPlaying = state?.playing ?? false;
                    final isLoading =
                        isPreparing ||
                        state?.processingState == ProcessingState.loading;
                    return StreamBuilder<Duration?>(
                      stream: player.durationStream,
                      builder: (context, durationSnapshot) {
                        final duration = durationSnapshot.data;
                        final canSeek =
                            hasAudio &&
                            !isLoading &&
                            duration != null &&
                            duration > Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: player.positionStream,
                          builder: (context, positionSnapshot) {
                            final position =
                                positionSnapshot.data ?? Duration.zero;
                            return Column(
                              children: [
                                Slider(
                                  value: canSeek
                                      ? position.inMilliseconds
                                            .toDouble()
                                            .clamp(
                                              0,
                                              duration.inMilliseconds
                                                  .toDouble(),
                                            )
                                      : 0,
                                  max: canSeek
                                      ? duration.inMilliseconds.toDouble()
                                      : 1,
                                  onChanged: canSeek
                                      ? (value) => player.seek(
                                          Duration(milliseconds: value.round()),
                                        )
                                      : null,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: canSeek
                                          ? () => seekBy(
                                              const Duration(seconds: -10),
                                            )
                                          : null,
                                      tooltip: '-10s',
                                      icon: const Icon(Icons.replay_10_rounded),
                                    ),
                                    IconButton(
                                      onPressed: hasAudio && !isLoading
                                          ? toggleAudio
                                          : null,
                                      tooltip: isPlaying
                                          ? strings.pauseRecitation
                                          : strings.playRecitation,
                                      icon: isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
                                              isPlaying
                                                  ? Icons
                                                        .pause_circle_filled_rounded
                                                  : Icons
                                                        .play_circle_fill_rounded,
                                              size: 36,
                                            ),
                                    ),
                                    IconButton(
                                      onPressed: canSeek
                                          ? () => seekBy(
                                              const Duration(seconds: 10),
                                            )
                                          : null,
                                      tooltip: '+10s',
                                      icon: const Icon(
                                        Icons.forward_10_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                if (duration != null)
                                  Text(
                                    '${formatDuration(position)} / ${formatDuration(duration)}',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
