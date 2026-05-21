import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/imports.dart';
import '../cubit/spiritual_cubit.dart';
import '../models/spiritual_models.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';

class SpiritualDashboardScreen extends StatelessWidget {
  const SpiritualDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SpiritualDashboardContent();
  }
}

class _SpiritualDashboardContent extends StatefulWidget {
  const _SpiritualDashboardContent();

  @override
  State<_SpiritualDashboardContent> createState() =>
      _SpiritualDashboardContentState();
}

class _SpiritualDashboardContentState extends State<_SpiritualDashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(isDarkMode),
            ],
            body: Column(
              children: [
                _buildTabBar(isDarkMode),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DailyTasksTab(
                        isDarkMode: isDarkMode,
                        isEditMode: _isEditMode,
                        confettiController: _confettiController,
                      ),
                      _StatisticsTab(isDarkMode: isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTaskModal(context),
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const AppText('مهمة جديدة',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ).animate().scale()
          : null,
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'ar').format(now);
    final dayDigit = DateFormat('d', 'ar').format(now);
    final monthName = DateFormat('MMMM', 'ar').format(now);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor:
          isDarkMode ? const Color(0xff0A1A14) : AppColors.primaryColor,
      elevation: 0,
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       setState(() {
      //         _isEditMode = !_isEditMode;
      //       });
      //       Vibration.vibrate(duration: 50);
      //     },
      //     icon: Icon(
      //       _isEditMode ? Icons.check_circle_rounded : Icons.edit_note_rounded,
      //       color: Colors.white,
      //     ),
      //     tooltip: _isEditMode ? 'حفظ' : 'تعديل المهام',
      //   ),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const AppText(
          'مركـز العبـادات',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        background: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (isDarkMode
                              ? const Color(0xff0A1A14)
                              : AppColors.primaryColor)
                          .withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    AppText(
                      'اليوم: $dayName، $dayDigit $monthName',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Cairo',
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<SpiritualCubit, SpiritualState>(
                      builder: (context, state) {
                        int streak = 0;
                        if (state is SpiritualLoaded) {
                          streak = state.stats.streakDays;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  color: Colors.orangeAccent, size: 20),
                              const SizedBox(width: 6),
                              AppText(
                                'تتابع: $streak أيام',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ],
                          ),
                        ).animate().fadeIn().scale();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.grey,
        onTap: (index) => setState(() {}),
        tabs: const [
          Tab(
            child: AppText(
              'المهام اليومية',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          Tab(
            child: AppText(
              'الإحصائيات',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: SpiritualCubit.get(context),
        child: const _AddTaskModal(),
      ),
    );
  }
}

class _DailyTasksTab extends StatelessWidget {
  final bool isDarkMode;
  final bool isEditMode;
  final ConfettiController confettiController;
  const _DailyTasksTab(
      {required this.isDarkMode,
      required this.isEditMode,
      required this.confettiController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpiritualCubit, SpiritualState>(
      builder: (context, state) {
        if (state is SpiritualLoaded) {
          final tasks = state.tasks;
          final totalTasks = tasks.length;
          final double totalProgress = tasks.isEmpty
              ? 0.0
              : tasks.fold(0.0, (sum, t) => sum + t.progress);
          final overallProgress =
              totalTasks == 0 ? 0.0 : totalProgress / totalTasks;
          final completedTasksCount =
              tasks.where((t) => t.progress >= 1.0).length;

          if (tasks.isEmpty) {
            return _buildEmptyState(context);
          }

          if (isEditMode) {
            return ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: tasks.length,
              onReorder: (oldIndex, newIndex) {
                SpiritualCubit.get(context).reorderTasks(oldIndex, newIndex);
              },
              header: Column(
                children: [
                  _buildProgressCard(
                      overallProgress, completedTasksCount, totalTasks),
                  const SizedBox(height: 24),
                  const AppText(
                    'تعديل وترتيب المهام',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskCard(
                  key: ValueKey(task.id),
                  task: task,
                  isDarkMode: isDarkMode,
                  isEditMode: true,
                  confettiController: confettiController,
                );
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              _buildProgressCard(
                  overallProgress, completedTasksCount, totalTasks),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'قائمة المهام اليومية',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      AppText(
                        'اضغط ضغطة لزيادة الإنجاز',
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontFamily: 'Cairo',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...tasks.map((task) => _TaskCard(
                    key: ValueKey(task.id),
                    task: task,
                    isDarkMode: isDarkMode,
                    isEditMode: false,
                    confettiController: confettiController,
                  )),
              if (overallProgress >= 1.0 && totalTasks > 0) ...[
                const SizedBox(height: 24),
                _buildCompletionCard(),
              ],
              const SizedBox(height: 40),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_mosaic_rounded,
              size: 80, color: AppColors.primaryColor.withOpacity(0.1)),
          const SizedBox(height: 24),
          const AppText(
            'لا يوجد مهام اليوم',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          const SizedBox(height: 8),
          AppText(
            'ابدأ بإضافة وردك اليومي من زر "مهمة جديدة"',
            fontSize: 13,
            color: Colors.grey[500],
            fontFamily: 'Cairo',
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.stars_rounded, color: Colors.orange, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'أحسنت! أتممت مهامك',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Colors.orange,
                ),
                AppText(
                  'لقد استكملت جميع العبادات المخطط لها اليوم بنجاح.',
                  fontSize: 12,
                  color: Colors.orange,
                  fontFamily: 'Cairo',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().shimmer(duration: 2.seconds).scale();
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'نسبة الإنجاز اليومي',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                const SizedBox(height: 4),
                AppText(
                  'لقد أتممت $completed من أصل $total مهام اليوم',
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  ),
                ),
                Center(
                  child: AppText(
                    '${(progress * 100).toInt()}%',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DIN',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final SpiritualTask task;
  final bool isDarkMode;
  final bool isEditMode;
  final ConfettiController confettiController;
  const _TaskCard(
      {super.key,
      required this.task,
      required this.isDarkMode,
      required this.isEditMode,
      required this.confettiController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress:
              isEditMode ? null : () => _showEditTaskModal(context, task),
          onTap: isEditMode
              ? null
              : () async {
                  final cubit = SpiritualCubit.get(context);
                  if (task.currentCount < task.targetCount) {
                    Vibration.vibrate(duration: 30);
                    cubit.updateTask(task.id, count: task.currentCount + 1);

                    if (task.currentCount + 1 == task.targetCount) {
                      confettiController.play();
                      Vibration.vibrate(duration: 100);
                    }
                  } else {
                    Vibration.vibrate(duration: 50);
                    cubit.updateTask(task.id, count: 0);
                  }
                },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isEditMode) ...[
                  const Icon(Icons.drag_indicator_rounded, color: Colors.grey),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: task.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(task.icon, color: task.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            task.title,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                          if (task.reminderTime != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.notifications_active_rounded,
                                size: 14,
                                color: AppColors.primaryColor.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            AppText(task.reminderTime!,
                                fontSize: 10,
                                color: AppColors.primaryColor.withOpacity(0.6),
                                fontFamily: 'DIN'),
                          ],
                        ],
                      ),
                      AppText(
                        task.subtitle,
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Cairo',
                      ),
                    ],
                  ),
                ),
                if (!isEditMode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.progress >= 1.0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.progress < 1.0) ...[
                              const Icon(Icons.add_rounded,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 2),
                            ],
                            AppText(
                              '${task.currentCount}/${task.targetCount}',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: task.progress >= 1.0
                                  ? Colors.green
                                  : Colors.grey,
                              fontFamily: 'DIN',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Add Explicit Edit Button
                      InkWell(
                        onTap: () => _showEditTaskModal(context, task),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, size: 12, color: AppColors.primaryColor),
                              const SizedBox(width: 4),
                              AppText(
                                'تعديل',
                                fontSize: 10,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isEditMode)
                  IconButton(
                    onPressed: () => _confirmDelete(context, task),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  void _confirmDelete(BuildContext context, SpiritualTask task) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const AppText('حذف المهمة',
            fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        content: AppText('هل أنت متأكد من حذف مهمة "${task.title}"؟',
            fontFamily: 'Cairo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child:
                const AppText('إلغاء', color: Colors.grey, fontFamily: 'Cairo'),
          ),
          TextButton(
            onPressed: () {
              SpiritualCubit.get(context).deleteTask(task.id);
              Vibration.vibrate(duration: 50);
              Navigator.pop(diagContext);
            },
            child: const AppText('حذف', color: Colors.red, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskModal(BuildContext context, SpiritualTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: SpiritualCubit.get(context),
        child: _AddTaskModal(taskToEdit: task),
      ),
    );
  }
}

class _AddTaskModal extends StatefulWidget {
  final SpiritualTask? taskToEdit;
  const _AddTaskModal({this.taskToEdit});

  @override
  State<_AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<_AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late int _targetCount;
  TimeOfDay? _reminderTime;
  TaskCategory _category = TaskCategory.other;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title);
    _subtitleController =
        TextEditingController(text: widget.taskToEdit?.subtitle);
    _targetCount = widget.taskToEdit?.targetCount ?? 1;
    _category = widget.taskToEdit?.category ?? TaskCategory.other;
    if (widget.taskToEdit?.reminderTime != null) {
      final parts = widget.taskToEdit!.reminderTime!.split(':');
      _reminderTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppText(
              widget.taskToEdit == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: 'عنوان المهمة',
              hint: 'مثلاً: قيام الليل',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _subtitleController,
              label: 'وصف مختصر',
              hint: 'مثلاً: ركعتان قبل الفجر',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberPicker(isDarkMode),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(context, isDarkMode),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: AppText(
                  widget.taskToEdit == null ? 'إضافة' : 'حفظ التعديلات',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 13, color: Colors.grey, fontFamily: 'Cairo'),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor:
                isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildNumberPicker(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('الهدف (العدد)',
            fontSize: 13, color: Colors.grey, fontFamily: 'Cairo'),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Vibration.vibrate(duration: 20);
                  setState(() => _targetCount++);
                },
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              ),
              AppText('$_targetCount',
                  fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'DIN'),
              IconButton(
                onPressed: () {
                  Vibration.vibrate(duration: 20);
                  setState(() =>
                      _targetCount = _targetCount > 1 ? _targetCount - 1 : 1);
                },
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('وقت التذكير',
            fontSize: 13, color: Colors.grey, fontFamily: 'Cairo'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            Vibration.vibrate(duration: 30);
            final time = await showTimePicker(
                context: context,
                initialTime: _reminderTime ?? TimeOfDay.now());
            if (time != null) setState(() => _reminderTime = time);
          },
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 20, color: AppColors.primaryColor),
                const SizedBox(width: 10),
                AppText(
                  _reminderTime?.format(context) ?? 'لم يحدد',
                  fontSize: 14,
                  fontFamily: 'DIN',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      Vibration.vibrate(duration: 100);
      final reminderStr = _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null;

      if (widget.taskToEdit == null) {
        final newTask = SpiritualTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          subtitle: _subtitleController.text,
          category: _category,
          targetCount: _targetCount,
          icon: Icons.auto_awesome_rounded,
          color: Colors.deepPurple,
          reminderTime: reminderStr,
          isCustom: true,
        );
        SpiritualCubit.get(context).addTask(newTask);
      } else {
        SpiritualCubit.get(context).updateTask(
          widget.taskToEdit!.id,
          title: _titleController.text,
          subtitle: _subtitleController.text,
          targetCount: _targetCount,
          reminderTime: reminderStr,
        );
      }
      if (reminderStr != null) {
        Fluttertoast.showToast(
          msg:
              'تم جدولة تنبيه لمهمة "${_titleController.text}" في الساعة $reminderStr',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
        );
      }

      Navigator.pop(context);
    }
  }
}

class _StatisticsTab extends StatelessWidget {
  final bool isDarkMode;
  const _StatisticsTab({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpiritualCubit, SpiritualState>(
      builder: (context, state) {
        if (state is SpiritualLoaded) {
          final stats = state.stats;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildMainStatsGauge(context, stats, isDarkMode),
              const SizedBox(height: 24),
              _WeeklyBarChart(
                  weeklyData: stats.weeklyData, isDarkMode: isDarkMode),
              const SizedBox(height: 40),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _confirmReset(BuildContext context) {
    Vibration.vibrate(duration: 50);
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            AppText('تصفير الإحصائيات',
                fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ],
        ),
        content: const AppText(
          'سيتم مسح جميع إحصائياتك وسجل الأسبوع بشكل نهائي. هل أنت متأكد؟',
          fontSize: 13,
          fontFamily: 'Cairo',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child:
                const AppText('إلغاء', color: Colors.grey, fontFamily: 'Cairo'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              SpiritualCubit.get(context).resetStats();
              Vibration.vibrate(duration: 100);
              Navigator.pop(diagContext);
              Fluttertoast.showToast(
                msg: 'تم تصفير الإحصائيات بنجاح',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            },
            child: const AppText('تصفير',
                color: Colors.white, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsGauge(
      BuildContext context, SpiritualStats stats, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText(
                'الوقت الإجمالي للتعبد',
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Cairo',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmReset(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 12, color: Colors.red),
                      SizedBox(width: 4),
                      AppText('تصفير',
                          fontSize: 10, color: Colors.red, fontFamily: 'Cairo'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            height: 120, // Semi-circle height
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: 0,
                        end:
                            (stats.totalWorshipMinutes / 80.0).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: const Size(200, 100),
                        painter: _GaugePainter(
                          progress: value,
                          color: AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      if (stats.totalWorshipMinutes > 0)
                        AppText(
                          '${stats.totalWorshipMinutes.toInt() ~/ 60}س ${stats.totalWorshipMinutes.toInt() % 60}د',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DIN',
                        )
                      else
                        const AppText(
                          '0 د',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DIN',
                        ),
                      AppText(
                        'إجمالي الوقت المسجل',
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Cairo',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Details Breakdown
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatDetailBadge(context, '📖 قرآن',
                  '${stats.quranMinutes.toInt()} د', Colors.green, isDarkMode),
              _buildStatDetailBadge(context, '🤲 أذكار',
                  '${stats.adhkarCount} ورد', Colors.amber, isDarkMode),
              _buildStatDetailBadge(context, '📿 سبحة',
                  '${stats.sunnahCount} تسبيحة', AppColors.primaryColor, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetailBadge(BuildContext context, String title, String value,
      Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(title,
              fontSize: 13,
              color: color,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold),
          const SizedBox(width: 8),
          AppText(value,
              fontSize: 13,
              color: isDarkMode ? Colors.white : Colors.black87,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}

// ─── Weekly Bar Chart ──────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatefulWidget {
  final Map<String, DailyRecord> weeklyData;
  final bool isDarkMode;
  const _WeeklyBarChart({required this.weeklyData, required this.isDarkMode});

  @override
  State<_WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<_WeeklyBarChart> {
  int? _selectedBar;

  static const List<String> _dayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];

  /// Builds the list of 7 days (Mon-today) sorted by date.
  List<MapEntry<String, DailyRecord?>> _buildWeekSlots() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return MapEntry(key, widget.weeklyData[key]);
    });
  }

  String _dayLabel(String dateKey) {
    try {
      final parts = dateKey.split('-');
      final d = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      // weekday: 1=Mon … 7=Sun
      return _dayNames[(d.weekday - 1) % 7];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = _buildWeekSlots();
    final maxScore = slots
        .map((e) => e.value?.totalScore ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b);
    final effectiveMax = maxScore == 0 ? 1.0 : maxScore;

    final primaryColor = AppColors.primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'مجهود الأسبوع',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
              AppText(
                'اضغط على يوم لتفاصيله',
                fontSize: 10,
                color: Colors.grey[400],
                fontFamily: 'Cairo',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bars
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(slots.length, (i) {
                final entry = slots[i];
                final record = entry.value;
                final score = record?.totalScore ?? 0.0;
                final ratio = score / effectiveMax;
                final isSelected = _selectedBar == i;
                final isToday = i == 6;
                final barColor =
                    isToday ? primaryColor : primaryColor.withOpacity(0.5);

                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedBar = isSelected ? null : i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Value label on selected
                          if (isSelected && score > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                score.toInt().toString(),
                                fontSize: 9,
                                color: Colors.white,
                                fontFamily: 'DIN',
                              ),
                            ),
                          const SizedBox(height: 4),
                          // Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: double.infinity,
                            height: ratio * 90 + (score > 0 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : barColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Day labels
          Row(
            children: List.generate(slots.length, (i) {
              final isToday = i == 6;
              return Expanded(
                child: Center(
                  child: AppText(
                    _dayLabel(slots[i].key).isNotEmpty
                        ? _dayLabel(slots[i].key).substring(0, 1) // first char
                        : '-',
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? AppColors.primaryColor : Colors.grey[400],
                    fontFamily: 'Cairo',
                  ),
                ),
              );
            }),
          ),

          // Detail panel on selection
          if (_selectedBar != null) ...[
            const SizedBox(height: 16),
            _buildDetailPanel(
                slots[_selectedBar!], _dayLabel(slots[_selectedBar!].key)),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildDetailPanel(
      MapEntry<String, DailyRecord?> entry, String dayName) {
    final record = entry.value;
    if (record == null || record.totalScore == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: AppText(
            'لا يوجد سجل لـ$dayName',
            fontSize: 12,
            color: Colors.grey[500],
            fontFamily: 'Cairo',
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(dayName,
              fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (record.quranMinutes > 0)
                _chip('📖 ${record.quranMinutes.toInt()} د', Colors.green),
              if (record.adhkarCount > 0)
                _chip('🤲 ${record.adhkarCount} ذكر', Colors.amber),
              if (record.prayerCount > 0)
                _chip('🕌 ${record.prayerCount} صلاة', Colors.blue),
              if (record.sunnahCount > 0)
                _chip('✨ ${record.sunnahCount} ركعة', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: AppText(text, fontSize: 11, color: color, fontFamily: 'Cairo'),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Build the arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, // Start at 180 degrees (left)
      3.14159, // Sweep 180 degrees (semi-circle)
      false,
      basePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159,
      3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const side = 40.0;
    for (double i = 0; i < size.width + side; i += side) {
      for (double j = 0; j < size.height + side; j += side) {
        _drawOctagon(canvas, Offset(i, j), side / 2, paint);
      }
    }
  }

  void _drawOctagon(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(45 * 3.14159 / 180);
    canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: radius, height: radius),
        paint);
    canvas.restore();
    canvas.drawRect(
        Rect.fromCenter(center: center, width: radius, height: radius), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
