# songdownloader

A Flutter app for downloading and converting audio from multiple sources —
YouTube Music, Spotify, Amazon Music, Apple Music, and Deezer — with a
built-in mp4-to-mp3 converter and direct YouTube video downloads.

## Features

- Per-platform link handling for YouTube Music, Spotify, Amazon Music,
  Apple Music, and Deezer
- YouTube video download, independent of the music-link flow
- MP4 → MP3 conversion
- In-app playback of downloaded audio

## How it works

Since most of these platforms don't expose a public download API, the app
works against a companion backend ([Songdownloadbackend](https://github.com/0xiammatrixx/Songdownloadbackend))
that resolves each platform's stream using `yt-dlp` with an authenticated
cookie session, then serves the result back to the app for download or
conversion.

## Stack

Flutter, Dart, `youtube_explode_dart`, `dio`, `audioplayers`

## Status

Personal project, functional for personal use.
