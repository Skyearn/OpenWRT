# Actions-OpenWrt

Build OpenWrt firmware with GitHub Actions, based on
[P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt).

Source tree: [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) (`master`)

## Devices

| Device | Config file | Target |
| --- | --- | --- |
| R68S | `R68S.config` | `rockchip/armv8` (`fastrhino_r68s`) |
| K3 | `K3.config` | `bcm53xx/generic` (`phicomm_k3`) |

## Usage

- Go to **Actions** → **OpenWrt Builder** → **Run workflow**, then pick
  `all` (default), `R68S` or `K3`.
- The firmware is uploaded both as a workflow artifact and as a GitHub release
  tagged `YYYY.MM.DD-HHMM-<DEVICE>`.
- The newest 2 workflow runs and newest 4 releases are kept.

## Notes

- The workflow requests `contents: write` and `actions: write`. The repository
  default token permission is read-only, so without them the release upload
  fails with `Resource not accessible by integration` (403).
- `diy-part1.sh` only appends the `helloworld` feed when lede does not already
  ship it. lede ships it in `feeds.conf.default`, and a duplicate feed name
  aborts `./scripts/feeds update -a` with exit code 25.
- `luci-app-easymesh` and `luci-app-guest-wifi` (referenced by the configs) are
  not part of the enabled feeds — they live in `kenzok8/openwrt-packages`.
  `make defconfig` silently drops them, so the firmware will not include those
  two apps unless that feed is added.

## Credits

- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [peter-evans/repository-dispatch](https://github.com/peter-evans/repository-dispatch)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)

## License

[MIT](LICENSE) © [**P3TERX**](https://p3terx.com)
