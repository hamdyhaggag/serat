import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AzkarPages extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final List<String> azkar;
  final PageController pageController;
  final List<int> maxValues;

  const AzkarPages({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.azkar,
    required this.pageController,
    this.maxValues = const [1],
  });

  @override
  AzkarPagesState createState() => AzkarPagesState();
}

class AzkarPagesState extends State<AzkarPages> {
  late PageController _pageController;
  final Map<int, bool> _showCheckIconMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController;
  }

  void _onShowCheckIcon(int index) {
    setState(() {
      _showCheckIconMap[index] = true;
    });
  }

  void _onCheckIconShown() {
    final currentIndex = _pageController.page?.toInt() ?? 0;
    if (currentIndex < widget.azkar.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Widget buildCard(BuildContext context, int index, double offset) {
    if (index < 0 || index >= widget.azkar.length) {
      return const SizedBox.shrink();
    }

    final maxValue =
        index < widget.maxValues.length ? widget.maxValues[index] : 1;

    return Opacity(
      opacity: 0.2,
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Padding(
          padding: EdgeInsets.all(widget.screenWidth * 0.06),
          child: AzkarCard(
            screenWidth: widget.screenWidth,
            text: widget.azkar[index],
            maxValue: maxValue,
            onShowCheckIcon: () => _onShowCheckIcon(index),
            onCheckIconShown: _onCheckIconShown,
            showCheckIcon: _showCheckIconMap[index] ?? false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.azkar.length,
            onPageChanged: (index) {
              context.read<AzkarCubit>().updateIndex(index);
            },
            itemBuilder: (context, index) {
              final maxValue =
                  index < widget.maxValues.length ? widget.maxValues[index] : 1;
              return Padding(
                padding: EdgeInsets.all(widget.screenWidth * 0.02),
                child: AzkarCard(
                  screenWidth: widget.screenWidth,
                  text: widget.azkar[index],
                  maxValue: maxValue,
                  onShowCheckIcon: () => _onShowCheckIcon(index),
                  onCheckIconShown: _onCheckIconShown,
                  showCheckIcon: _showCheckIconMap[index] ?? false,
                ),
              );
            },
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            reverse: true,
          ),
          Positioned(
            left: 410,
            top: 0,
            bottom: 0,
            child: BlocBuilder<AzkarCubit, AzkarState>(
              builder: (context, state) {
                int previousIndex = state.currentIndex - 1;
                return buildCard(
                  context,
                  previousIndex,
                  -widget.screenWidth * 0.2,
                );
              },
            ),
          ),
          Positioned(
            right: 450,
            top: 0,
            bottom: 0,
            child: BlocBuilder<AzkarCubit, AzkarState>(
              builder: (context, state) {
                int nextIndex = state.currentIndex + 1;
                return buildCard(context, nextIndex, widget.screenWidth * 0.3);
              },
            ),
          ),
        ],
      ),
    );
  }
}
