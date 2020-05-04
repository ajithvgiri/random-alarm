import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:random_alarm/stores/observable_alarm/observable_alarm.dart';
import 'package:volume/volume.dart';

class MediaHandler {
  AudioPlayer _currentPlayer;
  int _originalVolume;

  changeVolume(ObservableAlarm alarm) async {
    _originalVolume = await Volume.getVol;
    final maxVolume = await Volume.getMaxVol;
    final newVolume = (maxVolume * alarm.volume).toInt();
    Volume.setVol(newVolume);
  }

  playMusic(ObservableAlarm alarm) async {
    final FlutterAudioQuery query = FlutterAudioQuery();
    final allPlaylists = await query.getPlaylists();

    final playlistSongIds = allPlaylists
        .where((playlist) => alarm.playlistIds.contains(playlist.id))
        .map((info) => info.memberIds)
        .reduce((a, b) => [...a, ...b]);

    // Workaround for the case of a single playlist that has just one song
    // https://github.com/sc4v3ng3r/flutter_audio_query/issues/16
    final playlistPaths =
        (await query.getSongsById(ids: [...playlistSongIds, ""]))
            .map((info) => info.filePath);

    final paths = [...alarm.musicPaths, ...playlistPaths];
    print('Paths: $paths');

    final entry = Random().nextInt(paths.length);
    final path = paths[entry];

    //If empty, get default ringtone
    //Pick a random path, pass it to the player; for testing just print it
    _currentPlayer = AudioPlayer();
    _currentPlayer.play(path, isLocal: true, volume: 1.0);
  }

  stopAlarm() {
    _currentPlayer.stop();
    Volume.setVol(_originalVolume);
  }
}
