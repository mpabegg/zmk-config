# mpa's zmk-config

This is my personal [ZMK firmware](https://github.com/zmkfirmware/zmk/) configuration
for the [Forager](https://github.com/carrefinho/forager) (34 keys),
[Chocofi](https://github.com/pashutk/chocofi) (36 keys), and Silakka54 Wireless
(54 keys, dedicated shield, one nice!nano and one nice!view per half).
All three share the same 34-key core and five layers: Base, Nav, Sym, Num, Sys.

Built on upstream ZMK v0.3, with these modules:
 - [zmk-tri-state](https://github.com/urob/zmk-tri-state): Cmd+Tab swapper
 - [zmk-rgbled-widget](https://github.com/caksoylar/zmk-rgbled-widget): battery/connection status on the XIAO LED

![](keymap_img/forager_keymap.svg)

## Silakka54 Wireless

The dedicated shield lives in `boards/shields/silakka54_wireless/`; the keymap
and settings are `config/silakka54_wireless.keymap` and
`config/silakka54_wireless.conf`. The controller target stays separate:
`nice_nano_v2`, with `silakka54_wireless_left` / `silakka54_wireless_right`.
The Bluetooth name is `Silakka54` (within ZMK v0.3's 16-byte limit).

### Layout and keymap

Studio and the keymap now have **54 positions**, not 58 with four dummy keys:
four rows of 12 plus six thumbs. The existing five layers, home-row mods,
smart shift, Cmd+Tab swapper, and Nav + Sym → Sys are preserved.

- Number row: Esc, 1–0, Grave; F1–F12 on Sys, transparent on Nav/Sym/Num.
- Outer columns: Tab / Left Ctrl / Left Shift and Minus / Semicolon / Right Shift.
- Left thumbs, outer to inner: Nav/Backspace (48), Num/Enter (49), Esc (50).
- Right thumbs, inner to outer: Delete (51), smart shift (52), Sym/Space (53).

Migration from the former 58-position transform is: old 0–41 → new 0–41,
old 44–49 → new 42–47, old 50–52 → new 48–50, old 55–57 → new 51–53.
Old 42, 43, 53, 54 are removed, not retained as aliases. Home-row hold triggers
are migrated by the same rule; swapper exclusions remain 14, 30–33.

The owner adjusted the photo-based physical layout and approved the final
symmetrical thumb geometry: 0° outer thumbs, mirrored +15°/−15° middle thumbs,
and wider 1.25u inner thumbs at −60°/+60°. The approved export is preserved at
`/home/mat/Downloads/silakka54_wireless-layout.dtsi`; only its six thumb tuples
were applied to the repository, with all 48 main-key positions unchanged.
Coordinates, angles, and widths remain **owner-adjusted approximations**,
not measured PCB geometry. Logical order is identical to the electrical
transform. No hardware layout file was copied.

### Matrix and nice!view wiring

The shield uses the matrix-compatible portions of upstream ZMK's Lily58
implementation: col-to-row diodes, Pro Micro rows D5–D9, left columns
D19/D18/D15/D14/D16/D10, reversed right columns, and right column offset 6.
The transform is 5 × 12; thumb matrix positions are `(4,1)`, `(4,2)`, `(4,3)`,
`(4,8)`, `(4,9)`, `(4,10)`. It defines **no encoder or SSD1306 OLED**.

Both build entries append `nice_view_adapter nice_view`, in that order,
using the unmodified upstream ZMK v0.3 adapter and display implementation.
The [manufacturer's integration guide](https://nicekeyboards.com/docs/nice-view/getting-started/)
and [ZMK adapter documentation](https://github.com/zmkfirmware/zmk/blob/v0.3.0/app/boards/shields/nice_view_adapter/README.md)
specify the conventional OLED-header adapter wiring:

| nice!view signal | Pro Micro pin | nice!nano GPIO |
| --- | --- | --- |
| SCK (OLED SCL) | D3 | P0.20 |
| MOSI (OLED SDA) | D2 | P0.17 |
| CS, active high | D1 | P0.06 |

Power and ground must also match the nice!view header. The adapter configures
SPI0 at the display's 1 MHz limit, with unused MISO P0.25, and disables I2C0.
There are no separate DC or EXTCOMIN GPIOs in this upstream nice!view node.
None of these configured display pins overlaps the matrix pins.
**This is the standard adapter assumption, not a traced wiring claim for this
wireless PCB.** Its exact display wiring and controller revision remain unknown;
do not infer them from the selected board target.

`CONFIG_ZMK_DISPLAY=y` applies to **both** halves in ZMK v0.3; that release has
no `ZMK_SPLIT_PERIPHERAL_DISPLAY` option. The upstream nice!view custom screen
builds central status on the left and peripheral status/artwork on the right.
Upstream nice!view also disables idle display blanking. Sleep after 15 minutes
and +8 dBm Bluetooth TX power match Chocofi.

### Hardware evidence and limits

The owner confirms a nice!nano and nice!view on each half; the photo shows both
stock displays operating. The backups identify an nRF52840 nice!nano bootloader
(0.6.0), **not a verified controller revision**. Both original UF2 copies were
hash-verified before this work and remain under:

```text
/home/mat/keyboard-backups/silakka54-left-20261015/
/home/mat/keyboard-backups/silakka54-right-20261015/
```

On stock firmware, holding the left thumb below B while pressing A produced
`!`, supporting old matrix position 52 → new 50. Holding the right thumb below
N while pressing Y produced `6`, supporting old 55 → new 51. The right half also
sent `yuiop` through the USB-connected left half. These observations support the
matrix and thumb selection, but are **not an all-54-key electrical scan**.

The earlier dedicated UF2s, before the owner's final thumb-geometry adjustment,
were flashed with the owner's authorization on 2026-10-15, after checking each
device serial and firmware hash. The left re-enumerated as
`Silakka54`; the right returned in peripheral mode. No settings-reset firmware
was used and no pairing reset was requested. The owner then typed `qwertyuiop`
using both halves and reported that both nice!view displays appeared to work.
The owner's post-flash Studio screenshot also confirms device `Silakka54`,
layout `Silakka54 Wireless`, all 54 displayed positions without phantom keys,
and five layers: Base, Nav, Sym, Num, Sys. These are runtime checks of split
typing, reported display operation, and Studio rendering, not exhaustive
validation of all 54 key positions or thumb behaviors.
The final left geometry UF2 was subsequently flashed with the owner's
authorization after verifying its hash and serial `C94181C837D402CD`; it
re-enumerated as `Silakka54`. The right still runs the earlier geometry.
The owner subsequently confirmed that Studio also worked after the final left
update; the screenshot evidence above remains from the earlier geometry.
Existing saved Studio keymap data belongs to the old index space; do not assume
it migrates automatically to this 54-position layout.

### Builds and compiled-artifact verification

`build.yaml` produces `silakka54_left` / `silakka54_right`. Left is the central,
with `studio-rpc-usb-uart`, Studio enabled, and Studio locking disabled; right is
the peripheral without Studio. Both use `nice_nano_v2` and both enable nice!view.

The existing GitHub Actions workflow (`.github/workflows/build.yml`) runs on
push, pull request, or manual dispatch and reads the root `build.yaml` matrix.
Its merged `firmware` artifact includes `silakka54_left.uf2` and
`silakka54_right.uf2`, alongside the existing keyboard targets. The repository's
`zephyr/module.yml` registers the custom shield with the reusable ZMK workflow.
Both Silakka entries were also built locally from the parsed CI matrix, using
the same container image and matrix options. This verifies the firmware targets;
the hosted GitHub Actions run still requires publishing the commit.

Both final-geometry firmwares built successfully in fresh directories against
cached ZMK v0.3 on 2026-10-15, using
`docker.io/zmkfirmware/zmk-build-arm:stable` via Podman.
Inside that container, with the workspace mounted at `/work` and this repository
mounted read-only at `/zmk-config`, the build commands are:

```sh
west build -s /work/zmk/app -d /work/build-silakka54-final-20261015/left \
  -b nice_nano_v2 -S studio-rpc-usb-uart -- \
  -DZephyr_DIR=/work/zephyr/share/zephyr-package/cmake \
  -DSHIELD="silakka54_wireless_left nice_view_adapter nice_view" \
  -DZMK_CONFIG=/zmk-config/config -DZMK_EXTRA_MODULES=/zmk-config \
  -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
west build -s /work/zmk/app -d /work/build-silakka54-final-20261015/right \
  -b nice_nano_v2 -- \
  -DZephyr_DIR=/work/zephyr/share/zephyr-package/cmake \
  -DSHIELD="silakka54_wireless_right nice_view_adapter nice_view" \
  -DZMK_CONFIG=/zmk-config/config -DZMK_EXTRA_MODULES=/zmk-config
```

These builds used new directories without overwriting the deployed baseline in
`build-silakka54-wireless-20261015/`. Final local artifacts (not tracked):

```text
/home/mat/.cache/zmk-build-v03/build-silakka54-final-20261015/left/zephyr/zmk.uf2
/home/mat/.cache/zmk-build-v03/build-silakka54-final-20261015/right/zephyr/zmk.uf2
```

| Half | UF2 bytes | Flash used | RAM used |
| --- | ---: | ---: | ---: |
| Left | 740864 | 370208 | 96430 |
| Right | 533504 | 266656 | 60316 |

Hash-verified, byte-identical convenience copies:

| Half | Download | SHA-256 |
| --- | --- | --- |
| Left | `~/Downloads/Silakka54-Wireless/silakka54-esquerda.uf2` | `7bd7476a6c370182b7af03843e07455955fe7f7b7d8c8d17f17ba8b873982188` |
| Right | `~/Downloads/Silakka54-Wireless/silakka54-direita.uf2` | `194da622211d5b4c2a7752490c3e56797f982dd0c00dc17e1ee0635ffc79dbfa` |

The final smoke check parsed the **generated** `zephyr.dts` with Zephyr's `dtlib`,
plus `.config`, ELF, and every UF2 block. Against each half's deployed baseline,
it verified:

- Five layers × 54 bindings: all **270 bindings** match exactly.
- All 54 physical tuples match the approved export; only thumb indices 48–53
  differ from the baseline. Rotated corners mirror across X = 7u, including
  the −60°/+60° inner thumbs and global rotation pivots.
- Every generated devicetree property except physical-layout `keys` is unchanged:
  matrix/GPIOs, transform, hold-taps, swapper, smart shift, conditional layers,
  and nice!view/display pinctrl included.
- Each generated `.config` is byte-identical to its baseline; both ARM ELFs
  and all nRF52840 UF2 blocks are valid, with UF2 payloads matching `zmk.bin`.

Build logs `left-build.log` / `right-build.log`, `smoke.log`,
`smoke-evidence.json`, and `delivery-evidence.json` are preserved in
`/home/mat/.cache/zmk-build-v03/build-silakka54-final-20261015/`.
The original source export is unchanged. Final left deployment is recorded
above; no settings reset was performed and the final right UF2 is not flashed.

An initial build exposed pre-existing unscoped Forager display defaults, which
forced SSD1306 and overrode unrelated LVGL settings. Those defaults are now
scoped to Forager shields. Both Forager and both Chocofi firmwares were rebuilt
under `build-silakka54-wireless-20261015/regression/`: all five compiled layers
and generated `.config` values match their prior builds exactly; their keymap
and config files were not edited.

The successful Silakka builds retain upstream warnings for deprecated
`NRF_STORE_REBOOT_TYPE_GPREGRET` and USB being unavailable on the right peripheral.
Forager regression builds also retain the existing central logging-delay warning.
Build-time proof does **not** establish electrical compatibility or operation
of this new firmware on the physical keyboard.

### Credits and licensing

- [ZMK](https://github.com/zmkfirmware/zmk) is MIT-licensed, copyright © 2020
  The ZMK Contributors. The dedicated shield's matrix GPIOs and split overlays
  adapt [ZMK's Lily58 shield](https://github.com/zmkfirmware/zmk/tree/v0.3.0/app/boards/shields/lily58);
  copied files retain Pete Johanson's 2020 copyright and MIT SPDX notice.
  The unmodified upstream nice!view/adapter code retains its ZMK contributor notices.
- [Lily58](https://github.com/kata0510/Lily58) by Naoki Katahira is credited as the
  source of the upstream matrix convention, **not as a proven hardware ancestor
  of this wireless PCB**. Its [MIT hardware license](https://github.com/kata0510/Lily58/blob/master/LICENSE)
  credits © 2018 Naoki Katahira, Helix (© 2018 MakotoKurauchi),
  Corne/crkbd (© 2018 foostan), and Ergo42 (© 2017 Biacco42).
  No Lily58 hardware design files or physical-layout data were copied here.
- [Original Silakka54](https://github.com/Squalius-cephalus/silakka54), copyright
  © 2024 Squalius-cephalus, is MIT-licensed. Its documented design uses RP2040
  Zero and credits REVIUNG41/Corne inspiration. This owner's nRF52840 wireless
  variant has unknown authorship; this configuration is not claimed as an
  official wireless port by the original author.
- [vandermey's MIT wireless configuration](https://github.com/vandermey/silakka54-zmk-config)
  documents community use of the matrix-compatible upstream shield. It does
  not establish this PCB's provenance or its nice!view wiring. No code from that
  configuration or GPL/QMK source was copied into the new shield. Earlier
  investigation consulted a QMK map; no clean-room or automatic upstream
  acceptance claim is made.

The following MIT notice accompanies the adapted ZMK shield code and MIT-marked
additions under `boards/shields/silakka54_wireless/`. It is **not** a blanket
relicensing of this personal configuration or of external hardware/dependencies.

```text
MIT License

Copyright (c) 2020 Pete Johanson
Copyright (c) 2020 The ZMK Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
