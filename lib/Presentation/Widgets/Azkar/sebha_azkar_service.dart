import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'azkar_item.dart';

class SebhaAzkarService {
  static const String _azkarKey = 'azkar_items';

  Future<List<AzkarItem>> loadAzkarItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final azkarJson = prefs.getString(_azkarKey);

      if (azkarJson != null) {
        final List<dynamic> azkarList = json.decode(azkarJson);
        return azkarList.map((item) => AzkarItem.fromJson(item)).toList();
      } else {
        final defaultItems = _defaultAzkarItems();
        await saveAzkarItems(defaultItems);
        return defaultItems;
      }
    } catch (e) {
      // If there's an error loading saved items, return default items
      return _defaultAzkarItems();
    }
  }

  Future<void> saveAzkarItems(List<AzkarItem> azkarItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final azkarJson =
          json.encode(azkarItems.map((item) => item.toJson()).toList());
      await prefs.setString(_azkarKey, azkarJson);
    } catch (e) {
      // Handle save error - could add logging here
      rethrow;
    }
  }

  Future<void> addAzkarItem(AzkarItem item) async {
    final items = await loadAzkarItems();
    items.add(item);
    await saveAzkarItems(items);
  }

  Future<void> removeAzkarItem(String text) async {
    final items = await loadAzkarItems();
    items.removeWhere((item) => item.text == text);
    await saveAzkarItems(items);
  }

  Future<void> updateAzkarItem(AzkarItem updatedItem) async {
    final items = await loadAzkarItems();
    final index = items.indexWhere((item) => item.text == updatedItem.text);
    if (index != -1) {
      items[index] = updatedItem;
      await saveAzkarItems(items);
    }
  }

  List<AzkarItem> _defaultAzkarItems() => [
        AzkarItem(
            text: 'سبحان الله',
            count: 33,
            reward: 'لها ثواب عظيم عند الله',
            isDefault: true),
        AzkarItem(
            text: 'الحمد لله',
            count: 33,
            reward: 'لك أجر عظيم عند الله وذلك لأنك حمدته على نعمه',
            isDefault: true),
        AzkarItem(
            text: 'الله أكبر',
            count: 100,
            reward: 'لا يعلم أجرها إلا الله',
            isDefault: true),
        AzkarItem(
            text: 'لا إله إلا الله',
            count: 33,
            reward: 'لها فضل عظيم لا يعلمه إلا الله',
            isDefault: true),
        AzkarItem(
            text: 'لا حول ولا قوة إلا بالله',
            count: 33,
            reward: 'لك على كل تسبيحه شجرة بالجنه',
            isDefault: true),
        AzkarItem(
            text: 'اللهم صلِّ على سيدنا محمد',
            count: 100,
            reward: 'يرد عليك الرسول صلى الله عليه وسلم السلام',
            isDefault: true),
      ];
}
