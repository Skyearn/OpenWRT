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

### Interactive configuration (menuconfig over SSH)

- **Actions** → **Menuconfig (SSH)** → **Run workflow**, pick `R68S` or `K3`
  and a session timeout.
- Wait for the `Start SSH session` step to print a command like
  `ssh <session>:<token>@uptermd.upterm.dev`, then connect with it in your
  terminal. Only the workflow initiator's GitHub SSH keys are authorized.
- In the session:

  ```sh
  cd openwrt
  make menuconfig
  exit
  ```

- The job then runs `./scripts/diffconfig.sh`, prints the compact config in the
  log and uploads it as the `diffconfig-<DEVICE>` artifact. Paste that into
  `R68S.config` / `K3.config` and run **OpenWrt Builder**.

### Default hostname and LAN address

Edit the `case` block at the top of `diy-part2.sh`:

```sh
case "${DEVICE}" in
	K3)
		ROUTER_HOSTNAME="Al"
		ROUTER_LAN_IP="10.0.0.254"
		;;
	R68S)
		ROUTER_HOSTNAME="Al"
		ROUTER_LAN_IP="10.0.0.1"
		;;
	*)
		ROUTER_HOSTNAME="LEDE"
		ROUTER_LAN_IP="192.168.1.1"
		;;
esac
```

The script rewrites `package/base-files/files/bin/config_generate` before the
image is built. Current lede uses `LEDE` as the default hostname and
`192.168.1.1` as the LAN address, which is why the old P3TERX
`s/OpenWrt/.../` example no longer matches anything.

Note that these are *defaults for a fresh configuration*: `config_generate`
only runs when `/etc/config/network` or `/etc/config/system` do not exist yet,
so flashing with "keep settings" keeps the previous address/hostname.

## Notes

- The workflow requests `contents: write` and `actions: write`. The repository
  default token permission is read-only, so without them the release upload
  fails with `Resource not accessible by integration` (403).
- `diy-part1.sh` only appends the `helloworld` feed when lede does not already
  ship it. lede ships it in `feeds.conf.default`, and a duplicate feed name
  aborts `./scripts/feeds update -a` with exit code 25.
- `luci-app-easymesh` and `luci-app-guest-wifi` were dropped from the configs:
  they are not part of the enabled feeds (they live in
  `kenzok8/openwrt-packages`, which conflicts with the current feeds).
- The configs are fragments (`make defconfig` fills in the defaults), and only
  symbols that exist in the current feeds are kept. Old entries such as
  `luci-app-turboacc_INCLUDE_*`, `luci-i18n-mwan3-zh-cn`,
  `luci-app-unblockmusic`, and the `lib*`/`kmod-*`/`boost-*` dependency noise
  were removed.
- NaiveProxy is disabled in `R68S.config`: it needs the host package `gn`,
  whose 2026-09-02 revision uses C++20 ranges that do not compile with the
  GCC 12 toolchain of `ubuntu-22.04`. Everything else in passwall is built.
- `diy-part2.sh` injects a patch for `brcmfmac`: Linux 6.6.157 backported the
  removal of `struct usb_driver.drvwrap`, which backports-6.6.15 (kernel 6.6
  in lede) does not expect, so the K3 image would fail with
  `'struct usb_driver' has no member named 'drvwrap'`.
- The K3 build used to pull `boost`, whose SourceForge mirror stalls for an
  hour or more; `boost` and the other old dependency entries are gone, and the
  download step is capped at 90 minutes.

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
