# Google Play IAP — GiftStory

Package: `com.GiftStoryMNG.GiftStory`

Remote config: `https://api2.blwsmartware.net/N293.json`  
If JSON field `disable` is `1`, hide Google Play purchase popups. Shop stays open for coin unlocks.

## Consumable coin packs (buy many times)

| Product ID | Coins |
| --- | --- |
| `gs_pack_1` | 50 |
| `gs_pack_2` | 100 |
| `gs_pack_3` | 200 |
| `gs_pack_4` | 350 |
| `gs_pack_5` | 500 |
| `gs_pack_6` | 750 |
| `gs_pack_7` | 1000 |
| `gs_pack_8` | 1500 |
| `gs_pack_9` | 2200 |
| `gs_pack_10` | 3000 |

## One-time

| Product ID | Unlock |
| --- | --- |
| `gs_remove_ads` | Hide the banner |
| `gs_pro` | More than 4 people |

Create these IDs in Play Console → Monetize → In-app products. Coin packs must be **consumable**. Remove ads and Pro must be **non-consumable**.
