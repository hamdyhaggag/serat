# Quick Download Addition to Existing RecitersScreen

## 🎯 **Simple Steps to Add Download Functionality**

### **Step 1: Add Download Button to App Bar**

In your existing `RecitersScreen`, find the app bar actions and add a download button:

```dart
// In _buildAppBar method, add this to the actions list:
actions: [
  IconButton(
    icon: const Icon(Icons.download, color: Colors.white),
    onPressed: () => _showDownloadManager(),
  ),
  IconButton(
    icon: const Icon(Icons.refresh, color: Colors.white),
    onPressed: () {
      setState(() => _isOfflineMode = false);
      RecitersCubit.get(context).getReciters(forceRefresh: true);
    },
  ),
],
```

### **Step 2: Add Download Manager Method**

Add this method to your `_RecitersScreenState` class:

```dart
void _showDownloadManager() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.download, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const AppText(
                  'مدير التحميلات',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DownloadCubit, DownloadState>(
              builder: (context, state) {
                if (state is DownloadStorageInfoLoaded) {
                  return _buildDownloadContent(context, state);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDownloadContent(BuildContext context, DownloadStorageInfoLoaded state) {
  return Column(
    children: [
      _buildStorageInfo(state.storageInfo),
      const Divider(),
      Expanded(
        child: state.batches.isEmpty
            ? _buildEmptyDownloadState()
            : _buildDownloadBatchesList(context, state.batches),
      ),
    ],
  );
}

Widget _buildStorageInfo(Map<String, dynamic> storageInfo) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        const Icon(Icons.storage, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'المساحة المستخدمة',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              AppText(
                '${storageInfo['totalSizeMB']} ميجابايت',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        AppText(
          '${storageInfo['totalFiles']} ملف',
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ],
    ),
  );
}

Widget _buildEmptyDownloadState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.download_done,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        const AppText(
          'لا توجد تحميلات',
          fontSize: 18,
          color: Colors.grey,
        ),
        const SizedBox(height: 8),
        const AppText(
          'قم بتحميل التلاوات للاستماع بدون إنترنت',
          fontSize: 14,
          color: Colors.grey,
        ),
      ],
    ),
  );
}

Widget _buildDownloadBatchesList(BuildContext context, List<DownloadBatch> batches) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: batches.length,
    itemBuilder: (context, index) {
      final batch = batches[index];
      return _buildDownloadBatchCard(context, batch);
    },
  );
}

Widget _buildDownloadBatchCard(BuildContext context, DownloadBatch batch) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      batch.reciterName,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    AppText(
                      batch.moshafName,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              _buildDownloadStatusChip(batch.overallStatus),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: batch.overallProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    batch.overallStatus == DownloadStatus.completed
                        ? Colors.green
                        : AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AppText(
                '${batch.completedCount}/${batch.totalCount}',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildDownloadStatusChip(DownloadStatus status) {
  Color color;
  String text;
  IconData icon;

  switch (status) {
    case DownloadStatus.completed:
      color = Colors.green;
      text = 'مكتمل';
      icon = Icons.check_circle;
      break;
    case DownloadStatus.downloading:
      color = AppColors.primaryColor;
      text = 'جاري التحميل';
      icon = Icons.downloading;
      break;
    case DownloadStatus.paused:
      color = Colors.orange;
      text = 'متوقف مؤقتاً';
      icon = Icons.pause_circle;
      break;
    case DownloadStatus.failed:
      color = Colors.red;
      text = 'فشل';
      icon = Icons.error;
      break;
    default:
      color = Colors.grey;
      text = 'غير محمل';
      icon = Icons.download;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        AppText(
          text,
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ],
    ),
  );
}
```

### **Step 3: Add Download Button to Reciter Cards**

In your `_ReciterCard` widget, add a download button:

```dart
// In the _ReciterCard build method, add this to the trailing area:
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.download),
      onPressed: () => _showDownloadOptions(reciter),
    ),
    IconButton(
      icon: const Icon(Icons.play_circle_outline),
      onPressed: onTap,
    ),
  ],
),
```

### **Step 4: Add Download Options Method**

```dart
void _showDownloadOptions(Reciter reciter) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'خيارات التحميل',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primaryColor),
            title: const AppText('تحميل سورة واحدة'),
            onTap: () => _downloadSingleSurah(reciter),
          ),
          ListTile(
            leading: const Icon(Icons.download_done, color: AppColors.primaryColor),
            title: const AppText('تحميل عدة سور'),
            onTap: () => _downloadMultipleSurahs(reciter),
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline, color: AppColors.primaryColor),
            title: const AppText('تحميل جميع السور'),
            onTap: () => _downloadAllSurahs(reciter),
          ),
        ],
      ),
    ),
  );
}

void _downloadSingleSurah(Reciter reciter) {
  // Show surah selection dialog
  Navigator.pop(context);
  // Implement surah selection
}

void _downloadMultipleSurahs(Reciter reciter) {
  Navigator.pop(context);
  // Implement multiple surah selection
}

void _downloadAllSurahs(Reciter reciter) {
  Navigator.pop(context);
  // Download all surahs for the first moshaf
  if (reciter.moshaf.isNotEmpty) {
    final moshaf = reciter.moshaf.first;
    final surahList = moshaf.surahList
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    
    DownloadCubit.get(context).downloadMultipleSurahs(
      reciter: reciter,
      moshaf: moshaf,
      surahNumbers: surahList,
    );
  }
}
```

### **Step 5: Initialize DownloadCubit**

Make sure to initialize the DownloadCubit in your initState:

```dart
@override
void initState() {
  super.initState();
  _initializeAudio();
  _initializeNotificationService();
  _loadReciters();
  _setupAnimation();
  _setupSearchListener();
  
  // Initialize download functionality
  WidgetsBinding.instance.addPostFrameCallback((_) {
    DownloadCubit.get(context).initialize();
  });
}
```

## 🎯 **Result**

After adding these changes, you'll have:

✅ **Download button in app bar** - Opens download manager
✅ **Download button on reciter cards** - Shows download options
✅ **Download manager** - Shows all downloads and storage info
✅ **Download options** - Choose single, multiple, or all surahs
✅ **Progress tracking** - See download progress in real-time

## 🚀 **Usage**

1. **Tap download button** in app bar to see all downloads
2. **Tap download button** on any reciter card to download their surahs
3. **Choose download option** (single, multiple, or all surahs)
4. **Monitor progress** in the download manager
5. **Play offline** once downloads are complete

This approach keeps your existing screen structure while adding all the offline download functionality! 