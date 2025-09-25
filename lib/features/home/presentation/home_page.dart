import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:panicattack0918_02/app/router.dart';
import 'package:google_fonts/google_fonts.dart';

const _homeActionButtonAspectRatio = 1.05;
const _homeActionButtonMaxWidth = 100.0;
const _homeActionButtonMinWidth = 80.0;
const _homeActionButtonBaseSpacing = 8.0;
const _homeActionButtonMinSpacing = 4.0;
const _homeActionButtonWidthBoost = 12.0;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logoTextStyle = GoogleFonts.sourceSerif4(
      fontWeight: FontWeight.w700,
      textStyle: Theme.of(context).textTheme.titleLarge,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC9BCB2),
        title: Text('calmpanion', style: logoTextStyle),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 100,
                    color: const Color(0xFFC9BCB2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Level 1',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF3F352F),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.45,
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF7A6F67),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/backgrounds/defaultbg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final targetSize =
                                (constraints.maxWidth * 0.32)
                                    .clamp(160.0, 320.0);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  height: targetSize,
                                  width: targetSize,
                                  child: Image.asset(
                                    'assets/images/characters/bare.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF7F3E5),
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;

                    double spacing = _homeActionButtonBaseSpacing;
                    final baseButtonWidth =
                        ((availableWidth - spacing * 3) / 4).clamp(0, double.infinity);

                    double targetWidth =
                        (baseButtonWidth + _homeActionButtonWidthBoost)
                            .clamp(_homeActionButtonMinWidth, _homeActionButtonMaxWidth);

                    double requiredWidth = targetWidth * 4 + spacing * 3;

                    if (requiredWidth > availableWidth) {
                      spacing = ((availableWidth - targetWidth * 4) / 3)
                          .clamp(_homeActionButtonMinSpacing, _homeActionButtonBaseSpacing);

                      final availableForButtons =
                          (availableWidth - spacing * 3).clamp(0, double.infinity);

                      targetWidth = (availableForButtons / 4)
                          .clamp(_homeActionButtonMinWidth, _homeActionButtonMaxWidth);

                      requiredWidth = targetWidth * 4 + spacing * 3;

                      if (requiredWidth > availableWidth) {
                        spacing = _homeActionButtonMinSpacing;
                        targetWidth = ((availableWidth - spacing * 3) / 4)
                            .clamp(_homeActionButtonMinWidth, _homeActionButtonMaxWidth);
                      }
                    }

                    SizedBox spacingBox() => SizedBox(width: spacing);

                    return Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: targetWidth,
                            child: _HomeActionButton(
                              label: '호흡법',
                              icon: SvgPicture.asset(
                                'assets/icons/navigation/breath.svg',
                                width: 32,
                                height: 32,
                              ),
                              onTap: () =>
                                  context.goNamed(AppRoute.breathing.name),
                            ),
                          ),
                          spacingBox(),
                          SizedBox(
                            width: targetWidth,
                            child: _HomeActionButton(
                              label: '그라운딩',
                              icon: SvgPicture.asset(
                                'assets/icons/navigation/grounding.svg',
                                width: 32,
                                height: 32,
                              ),
                            ),
                          ),
                          spacingBox(),
                          SizedBox(
                            width: targetWidth,
                            child: _HomeActionButton(
                              label: '명상',
                              icon: SvgPicture.asset(
                                'assets/icons/navigation/mental.svg',
                                width: 32,
                                height: 32,
                              ),
                            ),
                          ),
                          spacingBox(),
                          SizedBox(
                            width: targetWidth,
                            child: _HomeActionButton(
                              label: '교육',
                              icon: const Icon(
                                Icons.menu_book,
                                size: 24,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionButton extends StatefulWidget {
  const _HomeActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  State<_HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<_HomeActionButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapEnd([TapUpDetails? details]) {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFD9D0C8);
    final textStyle = Theme.of(context).textTheme.labelLarge;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapCancel: _handleTapEnd,
      onTapUp: _handleTapEnd,
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: _homeActionButtonAspectRatio,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 3,
            ),
            boxShadow: _isPressed
                ? null
                : const [
                    BoxShadow(
                      color: Color(0xFFB4ABA4),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
          ),
          transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
          transformAlignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: widget.icon,
                ),
              ),
              const SizedBox(height: 6),
              Text(widget.label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
