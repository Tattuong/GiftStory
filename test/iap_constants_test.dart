import 'package:flutter_test/flutter_test.dart';
import 'package:giftstory/core/constants/iap_constants.dart';
import 'package:giftstory/core/services/iap_config_service.dart';
import 'package:giftstory/models/shop_item.dart';

void main() {
  test('GiftStory IAP ids and N293 endpoint', () {
    expect(IapConstants.productPrefix, 'gs');
    expect(IapConstants.remoteConfigUrl,
        'https://api2.blwsmartware.net/N293.json');
    expect(IapConstants.coinPackIds.first, 'gs_pack_1');
    expect(IapConstants.coinPackIds.last, 'gs_pack_10');
    expect(IapConstants.coinPackIds, hasLength(10));
    expect(IapConstants.removeAdsProductId, 'gs_remove_ads');
    expect(IapConstants.proProductId, 'gs_pro');
    expect(IapConstants.allProductIds,
        containsAll([...IapConstants.coinPackIds, 'gs_remove_ads', 'gs_pro']));
    expect(IapConstants.coinsForProduct('gs_pack_5'), 500);
    expect(IapConstants.freeArchiveLimit, 8);
    expect(IapConstants.proArchiveLimit, 99);
  });

  test('disable=1 hides billing only', () {
    final off = IapRemoteConfig.fromJson({'disable': 1, 'name': 'GiftStory'});
    expect(off.billingDisabled, isTrue);
    final on = IapRemoteConfig.fromJson(
        {'disable': 0, 'name': 'GiftStory', 'code': 'FULL_IAP'});
    expect(on.billingDisabled, isFalse);
    expect(on.name, 'GiftStory');
  });

  test('shop catalog extras can be applied and reverted', () {
    expect(
        ShopCatalog.items.where((e) => e.id.startsWith('theme_')), isNotEmpty);
    expect(ShopCatalog.find(ShopCatalog.featPro), isNotNull);
    expect(ShopCatalog.find('remove_ads'), isNotNull);
    expect(ShopCatalog.find(ShopCatalog.featHint), isNotNull);
    expect(ShopCatalog.find(ShopCatalog.featSound), isNotNull);
    expect(ShopCatalog.isDefaultId(ShopCatalog.defaultThemeId), isTrue);
  });
}
