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
        // Original Basic Azkar
        AzkarItem(
            text: 'سبحان الله',
            count: 33,
            reward:
                'من سبح الله في دبر كل صلاة ثلاثاً وثلاثين غفرت خطاياه وإن كانت مثل زبد البحر',
            isDefault: true),
        AzkarItem(
            text: 'الحمد لله',
            count: 33,
            reward:
                'الحمد لله تملأ الميزان، وسبحان الله والحمد لله تملآن ما بين السماوات والأرض',
            isDefault: true),
        AzkarItem(
            text: 'الله أكبر',
            count: 100,
            reward:
                'التكبير نور، وهو من الباقيات الصالحات التي هي خير عند ربك ثواباً وخير أملاً',
            isDefault: true),
        AzkarItem(
            text: 'لا إله إلا الله',
            count: 33,
            reward:
                'أفضل الذكر لا إله إلا الله، وهي كلمة التوحيد التي لا يدخل النار من قالها مؤمناً',
            isDefault: true),
        AzkarItem(
            text: 'لا حول ولا قوة إلا بالله',
            count: 33,
            reward: 'كنز من كنوز الجنة، ودواء من تسعة وتسعين داء أيسرها الهم',
            isDefault: true),
        AzkarItem(
            text: 'اللهم صلِّ على سيدنا محمد',
            count: 100,
            reward:
                'من صلى علي صلاة صلى الله عليه بها عشراً، ورفعه بها عشر درجات وحط عنه عشر خطيئات',
            isDefault: true),

        // Additional Common Azkar
        AzkarItem(
            text: 'أستغفر الله',
            count: 100,
            reward:
                'من أكثر من الاستغفار جعل الله له من كل ضيق مخرجاً ومن كل هم فرجاً ورزقه من حيث لا يحتسب',
            isDefault: true),
        AzkarItem(
            text: 'سبحان الله وبحمده',
            count: 100,
            reward:
                'من قال سبحان الله وبحمده في يوم مائة مرة حطت خطاياه وإن كانت مثل زبد البحر',
            isDefault: true),
        AzkarItem(
            text: 'سبحان الله العظيم',
            count: 100,
            reward: 'حبيبة إلى الرحمن، خفيفة على اللسان، ثقيلة في الميزان',
            isDefault: true),
        AzkarItem(
            text:
                'لا إله إلا الله وحده لا شريك له له الملك وله الحمد وهو على كل شيء قدير',
            count: 100,
            reward:
                'من قالها مائة مرة كانت له عدل عشر رقاب وكتبت له مائة حسنة ومحيت عنه مائة سيئة',
            isDefault: true),
        AzkarItem(
            text: 'رب اغفر لي',
            count: 100,
            reward: 'من أجمع الدعاء وأحبه إلى الله، ودعاء يستجيب الله له',
            isDefault: true),
        AzkarItem(
            text: 'اللهم أعني على ذكرك وشكرك وحسن عبادتك',
            count: 10,
            reward:
                'دعاء علمه النبي ﷺ لمعاذ بن جبل، وقال: لا تدعن أن تقول دبر كل صلاة',
            isDefault: true),
        AzkarItem(
            text: 'أعوذ بالله من الشيطان الرجيم',
            count: 3,
            reward:
                'إذا قرأت القرآن فاستعذ بالله من الشيطان الرجيم، وهي حماية من وساوس الشيطان',
            isDefault: true),
        AzkarItem(
            text: 'بسم الله الرحمن الرحيم',
            count: 21,
            reward:
                'من أعظم الأذكار، وبركة في كل أمر يبدأ بها، وهي فاتحة كتاب الله',
            isDefault: true),
        AzkarItem(
            text: 'رضيت بالله رباً وبالإسلام ديناً وبمحمد رسولاً',
            count: 3,
            reward:
                'من قالها حين يصبح وحين يمسي كان حقاً على الله أن يرضيه يوم القيامة',
            isDefault: true),
        AzkarItem(
            text: 'اللهم إني أسألك من فضلك ورحمتك فإنه لا يملكها إلا أنت',
            count: 10,
            reward:
                'دعاء جامع للخير كله، والله يحب من عبده أن يسأله من فضله ورحمته',
            isDefault: true),
        AzkarItem(
            text: 'يا حي يا قيوم برحمتك أستغيث',
            count: 3,
            reward:
                'من الدعاء بأسماء الله الحسنى، وقيل إنه اسم الله الأعظم الذي إذا دعي به أجاب',
            isDefault: true),
        AzkarItem(
            text: 'اللهم أنت ربي لا إله إلا أنت خلقتني وأنا عبدك',
            count: 10,
            reward: 'سيد الاستغفار، من قالها موقناً بها فمات من يومه دخل الجنة',
            isDefault: true),
        AzkarItem(
            text: 'سبحان الله وبحمده سبحان الله العظيم',
            count: 10,
            reward:
                'كلمتان حبيبتان إلى الرحمن خفيفتان على اللسان ثقيلتان في الميزان',
            isDefault: true),
        AzkarItem(
            text: 'أشهد أن لا إله إلا الله وأشهد أن محمداً رسول الله',
            count: 100,
            reward:
                'الشهادتان أساس الإيمان وأول أركان الإسلام، من قالها صادقاً دخل الجنة',
            isDefault: true),
      ];
}
