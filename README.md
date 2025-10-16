<!--
SPDX-FileCopyrightText: 2018 yuzu Emulator Project - 2024 torzu Emulator Project
SPDX-License-Identifier: GPL-2.0-or-later
-->

<h1 align="center">
  <br>
  <a href="http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu"><img src="https://notabug.org/litucks/torzu/raw/master/dist/yuzu.png" alt="torzu" width="200"></a>
  <br>
  <b>torzu</b>
  <br>
</h1>

<h4 align="center"><b>torzu</b> is a fork of yuzu, an open-source Nintendo Switch emulator.
<br>
It is written in C++ with portability in mind and runs on Linux, Windows and Android
</h4>

## Fake websites

A lot of fake Torzu websites have popped up. These are not mine. **This project will not have a clearnet website for the foreseeable future!**
I highly advice against downloading anything from these websites, specially if their intention is clearly to make money through advertisements.

## Compatibility

The emulator is capable of running most commercial games at full speed, provided you meet the [necessary hardware requirements](http://web.archive.org/web/20240130133811/https://yuzu-emu.org/help/quickstart/#hardware-requirements).

It runs most Nintendo Switch games released until the date of the Yuzu takedown.

## Goals

**Consider this project in feature freeze!** This means no new features are going to be added. All further updates are going to be focused on maintaining compatibility with modern systems.

I think this project has done a really good job with keeping regressions from Yuzu to the minimum. If a game runs on Yuzu, and on the current version of Torzu, it's extremely likely that it works just as well on all future versions of Torzu.

Regardless, I am very happy with how things are right now.
If you're looking for a Yuzu fork that definitely runs the games the original Yuzu emulator did well without any regressions, Torzu is probably your best bet for now.

## Development

All development happens on [Dark Git](http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/). It's also where [our central repository](http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu) is hosted.

To clone this git repository, use these commands (assuming tor is installed as a service and running):

```bash
git -c http.proxy=socks5h://127.0.0.1:9050 clone --depth 1 http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu.git
cd torzu
git submodule update --init --recursive
```

Alternatively, you can clone from the [NotABug mirror repository](https://notabug.org/litucks/torzu):

```bash
git clone --depth 1 https://notabug.org/litucks/torzu.git
cd torzu
git submodule update --init --recursive
```

Note that above repository may be taken down any time. Do not rely on its existence in production. In case the NotABug mirror goes down, another mirror will be most likely be set up on Bitbucket.

This project incorporates several commits from the [Suyu](https://suyu.dev), [Sudachi](https://github.com/sudachi-emu/sudachi) and [Citron](https://github.com/ong19th/Citron) forks, as well as changes listed in **Changes**.

## Building
<!--  -->
* [Android Build](http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu/src/branch/master/build-for-android.md) (NotABug [alt](https://notabug.org/litucks/torzu/src/master/build-for-android.md))
* [Linux Build](http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu/src/branch/master/build-for-linux.md) (NotABug [alt](https://notabug.org/litucks/torzu/src/master/build-for-linux.md))
* [Windows Build](http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu/src/branch/master/build-for-windows.md) (NotABug [alt](https://notabug.org/litucks/torzu/src/master/build-for-windows.md))

## License

torzu is licensed under the GPLv3 (or any later version). Refer to the [LICENSE.txt](./LICENSE.txt) file.
