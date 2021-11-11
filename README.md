# Everdale Assets

A collection of assets present in Everdale, a game developed by Supercell.

## Update v9.160

As of version 9.160, the assets folders in the game APKs are not packed into `.osm` files. The asset folders also contains more files and folders than are available here. You should be able to see them by directly unzipping the game's APKs.

**Note:** The `client` and `logic` folders are available as `csv_client` and `csv_logic` in the game's APKs and they contained _compressed_ csv files. This repository contains _uncompressed_ files. The files are decompressed using [`sc_extract`][sce]. Also, the `ui` folder is called `sc` in the game APKs.

---

Unlike other Supercell games, the assets folders in the game APKs are packed into `.osm` files. This repository only contains the unpacked folders. [You can follow these steps to unpack the files yourself.][gist]

Note that this repository does _not_ contain the 3d files because of their massive size.

Some additional notes:

-   The `.osm` files use dynamic `LZMA` compression and can be unpacked using [`everdale.bms`][evbms]. **As of update v9.160, they are no longer present.**
-   The `_tex.sc` files use `LZMA` compression and can be decompressed using [`sc_extract`][sce]. **As of update v9.160, the game uses version 4 `_tex.sc` files and they can be decompressed using only the master branch version of [`sc_extract`][sce].**
-   The `.sc` files either use `LZMA` or `LZHAM` compression and can be decompressed using [`clash_royale.bms`][crbms].
-   ~~The `.csv` files are not compressed.~~ **The `.csv` files are compressed as of update v9.160. They use `LZMA` compression and can be decompressed using [`sc_extract`][sce].**

## License and Disclaimer

This repository is licensed under [the MIT license](LICENSE). However, the use of the contents of this repository is governed by Supercell's [terms of service][tos] and [Fan Content Policy][fcp].

This content is not affiliated with, endorsed, sponsored, or specifically approved by Supercell and Supercell is not responsible for it. For more information see Supercell’s [Fan Content Policy][fcp].

[gist]: https://gist.github.com/snowsee/ada14998398f63b03648ab382e842ced
[evbms]: http://aluigi.altervista.org/bms/everdale.bms
[crbms]: http://aluigi.altervista.org/bms/clash_royale.bms
[tos]: https://supercell.com/en/terms-of-service/
[fcp]: https://www.supercell.com/fan-content-policy
[sce]: https://www.github.com/AriusX7/sc-extract
