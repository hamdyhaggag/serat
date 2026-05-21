import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/utils/cache_helper.dart';
import 'package:serat/features/badges/models/badge_model.dart';

part 'badges_state.dart';

class BadgesCubit extends Cubit<BadgesState> {
  BadgesCubit() : super(BadgesInitial());

  static BadgesCubit get(context) => BlocProvider.of(context);

  List<BadgeModel> badges = BadgeModel.allBadges;

  Future<void> initBadges() async {
    emit(BadgesLoading());
    try {
      final savedData = CacheHelper.getString(key: 'user_badges');
      if (savedData.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(savedData);
        final Map<String, dynamic> savedBadges = {
          for (var item in jsonList) item['id'] as String: item
        };

        for (int i = 0; i < badges.length; i++) {
          final savedBadge = savedBadges[badges[i].id];
          if (savedBadge != null) {
            badges[i] = badges[i].copyWith(
              progressCount: (savedBadge['progressCount'] ?? 0) as int,
              isUnlocked: (savedBadge['isUnlocked'] ?? false) as bool,
            );
          }
        }
      }
      emit(BadgesLoaded(badges));
    } catch (e, stack) {
      print('=== BADGES INIT ERROR ===');
      print(e);
      print(stack);
      emit(BadgesError('حدث خطأ أثناء تحميل الأوسمة'));
    }
  }

  Future<void> submitAction(String badgeId, String action) async {
    emit(BadgesSubmissionLoading());
    try {
      final index = badges.indexWhere((b) => b.id == badgeId);
      
      if (index != -1 && !badges[index].isComplete) {
        final badge = badges[index];
        final newCount = badge.progressCount + 1;
        final isUnlocked = newCount >= badge.requiredCount;
        
        badges[index] = badge.copyWith(
          progressCount: newCount,
          isUnlocked: isUnlocked,
        );
        
        await _saveBadges();
        
        // Random encouraging reason
        final List<String> encouragements = [
          'تقبل الله منك! عمل رائع ومأجور إن شاء الله.',
          'ما شاء الله! خطوة مباركة على هدي النبي ﷺ.',
          'زادك الله حرصاً، استمر في هذا الخير.',
          'بارك الله في عملك وجعله في ميزان حسناتك.',
          'إحياءٌ عظيم لسنّة نبينا ﷺ، هنيئاً لك.'
        ];
        encouragements.shuffle();

        emit(BadgesSubmissionSuccess(
          badge: badges[index],
          reason: encouragements.first,
          isNewlyUnlocked: isUnlocked && !badge.isUnlocked,
        ));
      } else if (index != -1 && badges[index].isComplete) {
          emit(const BadgesSubmissionRejected('تم اكتمال هذا الوسام مسبقاً! ما شاء الله.'));
      } else {
        emit(const BadgesSubmissionRejected('عذراً، حدث خطأ. الوسام غير موجود.'));
      }
      
      // Re-emit loaded state to update UI
      emit(BadgesLoaded(List.from(badges)));
    } catch (e, stack) {
      print('=== BADGES SUBMIT ERROR ===');
      print(e);
      print(stack);
      emit(const BadgesSubmissionRejected('حدث خطأ. يرجى المحاولة لاحقاً.'));
      emit(BadgesLoaded(List.from(badges)));
    }
  }

  Future<void> _saveBadges() async {
    final List<Map<String, dynamic>> jsonList = badges.map((b) => b.toJson()).toList();
    await CacheHelper.saveData(key: 'user_badges', value: json.encode(jsonList));
  }

  Future<void> resetBadges() async {
    emit(BadgesLoading());
    try {
      badges = BadgeModel.allBadges;
      await CacheHelper.removeData(key: 'user_badges');
      emit(BadgesLoaded(badges));
    } catch (e) {
      emit(BadgesError('حدث خطأ أثناء إعادة التعيين'));
    }
  }
}
