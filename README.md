# Everdale Assets

A collection of assets present in Everdale, a game developed by Supercell.

Unlike other Supercell games, the assets folders in the game APKs are packed into `.osm` files. This repository only contains the unpacked folders. [You can follow these steps to unpack the files yourself.](gist)

Note that this repository does *not* contain the 3d files because of their massive size.

Some additional notes:

* The `.osm` files use dynamic `LZMA` compression and can be unpacked using [`everdale.bms`](evbms).
* The `_tex.sc` files use `LZMA` compression.
* The `.sc` files either use `LZMA` or `LZHAM` compression and can be decompressed using [`clash_royale.bms`](crbms).
* The `.csv` files are not compressed.

## License and Disclaimer

This repository is licensed under [the MIT license](LICENSE). However, the use of the contents of this repository is governed by Supercell's [terms of service](tos) and [Fan Content Policy](fcp).

This content is not affiliated with, endorsed, sponsored, or specifically approved by Supercell and Supercell is not responsible for it. For more information see Supercell’s [Fan Content Policy](fcp).

[gist]: https://gist.github.com/snowsee/ada14998398f63b03648ab382e842ced
[evbms]: http://aluigi.altervista.org/bms/everdale.bms
[crbms]: http://aluigi.altervista.org/bms/clash_royale.bms
[tos]: https://supercell.com/en/terms-of-service/
[fcp]: www.supercell.com/fan-content-policy
