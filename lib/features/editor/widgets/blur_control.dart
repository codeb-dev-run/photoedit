import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/editor_state.dart';

/// 블러 조절 패널
class BlurControl extends ConsumerWidget {
  const BlurControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorStateProvider);
    final notifier = ref.read(editorStateProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 블러 강도 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.blur_on, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      '블러 강도',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(editorState.blurIntensity * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 블러 강도 슬라이더
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: Theme.of(context).primaryColor,
                overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                trackHeight: 5,
              ),
              child: Slider(
                value: editorState.blurIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                onChanged: (value) {
                  notifier.setBlurIntensity(value);
                },
              ),
            ),

            const SizedBox(height: 12),

            // 투명도 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.opacity, size: 20, color: Colors.cyan.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      '투명도',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(editorState.blurRegion.opacity * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.cyan.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 투명도 슬라이더
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.cyan.shade600,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: Colors.cyan.shade600,
                overlayColor: Colors.cyan.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                trackHeight: 5,
              ),
              child: Slider(
                value: editorState.blurRegion.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                onChanged: (value) {
                  notifier.setBlurOpacity(value);
                },
              ),
            ),

            const SizedBox(height: 12),

            // 프리셋 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PresetButton(
                  label: '없음',
                  value: 0.0,
                  isSelected: editorState.blurIntensity == 0.0,
                  onTap: () => notifier.setBlurIntensity(0.0),
                ),
                _PresetButton(
                  label: '약함',
                  value: 0.3,
                  isSelected: (editorState.blurIntensity - 0.3).abs() < 0.05,
                  onTap: () => notifier.setBlurIntensity(0.3),
                ),
                _PresetButton(
                  label: '중간',
                  value: 0.6,
                  isSelected: (editorState.blurIntensity - 0.6).abs() < 0.05,
                  onTap: () => notifier.setBlurIntensity(0.6),
                ),
                _PresetButton(
                  label: '강함',
                  value: 1.0,
                  isSelected: editorState.blurIntensity == 1.0,
                  onTap: () => notifier.setBlurIntensity(1.0),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 투명도 프리셋 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OpacityPresetButton(
                  label: '완전',
                  value: 1.0,
                  isSelected: editorState.blurRegion.opacity == 1.0,
                  onTap: () => notifier.setBlurOpacity(1.0),
                ),
                _OpacityPresetButton(
                  label: '75%',
                  value: 0.75,
                  isSelected: (editorState.blurRegion.opacity - 0.75).abs() < 0.05,
                  onTap: () => notifier.setBlurOpacity(0.75),
                ),
                _OpacityPresetButton(
                  label: '50%',
                  value: 0.5,
                  isSelected: (editorState.blurRegion.opacity - 0.5).abs() < 0.05,
                  onTap: () => notifier.setBlurOpacity(0.5),
                ),
                _OpacityPresetButton(
                  label: '25%',
                  value: 0.25,
                  isSelected: (editorState.blurRegion.opacity - 0.25).abs() < 0.05,
                  onTap: () => notifier.setBlurOpacity(0.25),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 설명 텍스트
            Text(
              '원형 블러: 안쪽이 블러, 바깥은 선명\n투명도로 블러의 투명함을 조절합니다',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 블러 강도 프리셋 버튼
class _PresetButton extends StatelessWidget {
  final String label;
  final double value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// 투명도 프리셋 버튼
class _OpacityPresetButton extends StatelessWidget {
  final String label;
  final double value;
  final bool isSelected;
  final VoidCallback onTap;

  const _OpacityPresetButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyan.shade600
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.cyan.shade600
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
