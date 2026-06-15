# Shuowen

Native SwiftUI client for [*Shuowen Jiezi*](https://en.wikipedia.org/wiki/Shuowen_Jiezi) (说文解字) — browse, search, and read entries offline on iPhone, iPad, Mac, and visionOS.

说文解字原生客户端，支持离线浏览、搜索与收藏。

## Features

- **Roam** — daily random entry with shuffle
- **Browse** — grid of all entries sorted by ID
- **Search** — headword, pinyin, radical, index forms, and gloss keywords
- **Favorites** — star entries for quick access
- **Entry detail** — gloss, variants, Duan notes, radical/volume, seal character, and more
- **Offline** — bundled `shuowen.store` SwiftData database, no network required
- **Localization** — English, Simplified Chinese, Traditional Chinese, Hong Kong Chinese
- **CJK fonts** — [Jigmo](https://kamichikoichi.github.io/jigmo/) for extended hanzi coverage

## Requirements

- Xcode 16+ (tested with Xcode 26 beta)
- iOS 18.6+ / macOS 14+ / visionOS 1.0+
- Swift 5, SwiftUI, SwiftData

## Getting Started

### 1. Clone

```bash
git clone https://github.com/qiyangdev/Shuowen.git
cd Shuowen
```

### 2. Dictionary data

This repository does **not** ship the dictionary JSON. Clone the upstream dataset:

```bash
git clone https://github.com/shuowenjiezi/shuowen.git /tmp/shuowen-data
cp /tmp/shuowen-data/data/*.json Scripts/entries/
```

Or symlink:

```bash
ln -s /path/to/shuowen/data Scripts/entries
```

The data is licensed under [Apache License 2.0](https://github.com/shuowenjiezi/shuowen/blob/master/LICENSE) (Copyright 2019 Shuowen.org).

### 3. Jigmo fonts

Download [Jigmo](https://kamichikoichi.github.io/jigmo/) and place the font files here (gitignored due to size):

```
Shuowen/Fonts/Jigmo.ttf
Shuowen/Fonts/Jigmo2.ttf
Shuowen/Fonts/Jigmo3.ttf
```

Jigmo is dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

### 4. Build the database

Build the Debug app in Xcode first, then run:

```bash
./Scripts/import_entries.sh Scripts/entries
```

This imports JSON into a local SwiftData store and exports `Shuowen/Resources/shuowen.store` for bundling. See `Scripts/import_entries.sh` for details.

### 5. Run

Open `Shuowen.xcodeproj` in Xcode, select the **Shuowen** scheme, and build & run.

Run unit tests with **ShuowenTests** (uses small fixtures in `ShuowenTests/Fixtures/`).

## Project Structure

```
Shuowen/
├── App/                 # App entry, root TabView
├── Features/            # Roam, Browse, Search, Favorites, Settings, Entry UI
├── Models/              # SwiftData models & JSON DTOs
├── Services/            # Data store, search, import, favorites
├── StoreBuild/          # DEBUG store import UI
├── Utilities/           # Fonts, pinyin, JSON decoder
├── Resources/           # Localizable.xcstrings, shuowen.store, notices
└── Fonts/               # Jigmo (not in git)

Scripts/
├── import_entries.sh    # JSON → shuowen.store
└── entries/             # Dictionary JSON (not in git)

Config/
└── ShuowenApp-Info.plist
```

## Third-Party Components

| Component | Use | License |
|-----------|-----|---------|
| [shuowenjiezi/shuowen](https://github.com/shuowenjiezi/shuowen) | Dictionary data | Apache 2.0 |
| [Jigmo](https://kamichikoichi.github.io/jigmo/) | CJK fonts | CC0 1.0 |

Full notices: `Shuowen/Resources/ThirdPartyNotices.txt`, or **Settings → Acknowledgments → Open Source Licenses** in the app.

## License

The **source code in this repository** is licensed under the [MIT License](LICENSE).

Third-party data and fonts remain under their respective licenses above. This project is not affiliated with or endorsed by [shuowen.org](http://www.shuowen.org).

## Contributing

Issues and pull requests are welcome. When submitting changes to dictionary content, please contribute upstream to [shuowenjiezi/shuowen](https://github.com/shuowenjiezi/shuowen) instead of this repo.
