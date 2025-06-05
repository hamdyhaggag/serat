import 'package:flutter/material.dart';
import 'package:serat/Data/Model/history_model.dart';
import 'package:serat/Data/Services/history_service.dart';
import 'package:serat/imports.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<HistoryModel> _historyItems = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final items = await HistoryService.getHistory();
      setState(() {
        _historyItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showHistoryDetails(BuildContext context, HistoryModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => HistoryDetailsSheet(
          item: item,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: AppBar(
        title: const AppText(
          'التاريخ الإسلامي',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'لا توجد أحداث تاريخية',
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _historyItems.length,
                    itemBuilder: (context, index) {
                      final item = _historyItems[index];
                      return Hero(
                        tag: 'history_${item.id}',
                        child: GestureDetector(
                          onTap: () => _showHistoryDetails(context, item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xff2F2F2F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showHistoryDetails(context, item),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: AppText(
                                              '${item.id}',
                                              fontSize: 12,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Wrap(
                                              spacing: 8,
                                              children: item.date
                                                  .map((date) => AppText(
                                                        date,
                                                        fontSize: 12,
                                                        color: isDarkMode
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600],
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AppText(
                                        item.title,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : AppColors.primaryColor,
                                      ),
                                      const SizedBox(height: 8),
                                      AppText(
                                        item.text,
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class HistoryDetailsSheet extends StatelessWidget {
  final HistoryModel item;
  final ScrollController scrollController;

  const HistoryDetailsSheet({
    super.key,
    required this.item,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final padding = MediaQuery.of(context).padding;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 0,
                bottom: padding.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'history_${item.id}',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            '${item.id}',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: item.date
                                .map((date) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: AppText(
                                        date,
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryColor,
                        fontFamily: 'Cairo',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.text,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[800],
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
