import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photoedit/core/presets/default_presets.dart';
import 'package:photoedit/core/presets/preset_model.dart';
import 'package:photoedit/core/filters/film_filter.dart';
import 'package:photoedit/shared/theme/app_theme.dart';
import 'package:photoedit/features/presets/widgets/preset_card.dart';

/// 프리셋 관리 화면 - Lumera 디자인
class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  static const String _storageKey = 'user_presets';

  List<EditPreset> _userPresets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPresets();
  }

  Future<void> _loadUserPresets() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _userPresets = jsonList
            .map((json) => EditPreset.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('프리셋 로드 실패: $e');
      _userPresets = [];
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveUserPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _userPresets.map((preset) => preset.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('프리셋 저장 실패: $e');
    }
  }

  void _showPresetDetails(EditPreset preset) {
    showDialog(
      context: context,
      builder: (context) => _PresetDetailDialog(preset: preset),
    );
  }

  void _editPreset(EditPreset preset) {
    showDialog(
      context: context,
      builder: (context) => _EditPresetDialog(
        preset: preset,
        onSave: (updatedPreset) {
          setState(() {
            final index = _userPresets.indexWhere((p) => p.id == preset.id);
            if (index != -1) {
              _userPresets[index] = updatedPreset;
              _saveUserPresets();
            }
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프리셋이 수정되었습니다')),
          );
        },
      ),
    );
  }

  void _deletePreset(EditPreset preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리셋 삭제'),
        content: Text('\'${preset.name}\' 프리셋을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _userPresets.removeWhere((p) => p.id == preset.id);
                _saveUserPresets();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프리셋이 삭제되었습니다')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPresetOptions(EditPreset preset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _OptionTile(
                  icon: Icons.edit_outlined,
                  label: '편집',
                  onTap: () {
                    Navigator.pop(context);
                    _editPreset(preset);
                  },
                ),
                const SizedBox(height: 12),
                _OptionTile(
                  icon: Icons.delete_outline,
                  label: '삭제',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _deletePreset(preset);
                  },
                ),
                const SizedBox(height: 12),
                _OptionTile(
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createNewPreset() {
    showDialog(
      context: context,
      builder: (context) => _CreatePresetDialog(
        onSave: (newPreset) {
          setState(() {
            _userPresets.add(newPreset);
            _saveUserPresets();
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새 프리셋이 생성되었습니다')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPresets = DefaultPresets.getAll();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 컨텐츠
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 기본 프리셋 섹션
                          const Text(
                            '기본 제공 프리셋',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDefaultPresetsGrid(defaultPresets),

                          const SizedBox(height: 32),

                          // 내 프리셋 섹션
                          const Text(
                            '내 프리셋',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildUserPresetsGrid(),

                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              '길게 눌러서: 편집 | 삭제 | 공유',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppTheme.textMuted.withOpacity(0.7),
                              ),
                            ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LumeraIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          const Text(
            '프리셋 관리',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildDefaultPresetsGrid(List<EditPreset> presets) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        return _LumeraPresetCard(
          preset: preset,
          onTap: () => _showPresetDetails(preset),
        );
      },
    );
  }

  Widget _buildUserPresetsGrid() {
    final itemCount = _userPresets.length + 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _userPresets.length) {
          return _buildNewPresetCard();
        }

        final preset = _userPresets[index];
        return _LumeraPresetCard(
          preset: preset,
          onTap: () => _showPresetDetails(preset),
          onLongPress: () => _showPresetOptions(preset),
        );
      },
    );
  }

  Widget _buildNewPresetCard() {
    return GestureDetector(
      onTap: _createNewPreset,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 2,
          ),
          color: AppTheme.surfaceColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '새 프리셋',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lumera 프리셋 카드
class _LumeraPresetCard extends StatelessWidget {
  final EditPreset preset;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _LumeraPresetCard({
    required this.preset,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getPresetColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.filter_vintage,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (preset.isDefault)
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getPresetDescription(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPresetColor() {
    if (preset.filmFilter != null) {
      final filterName = preset.filmFilter!.name.toLowerCase();
      if (filterName.contains('kodak') || filterName.contains('warm')) {
        return AppTheme.filterWarm;
      } else if (filterName.contains('fuji') || filterName.contains('cool')) {
        return AppTheme.filterCool;
      }
    }
    return AppTheme.primaryColor;
  }

  String _getPresetDescription() {
    final parts = <String>[];
    if (preset.filmFilter != null) {
      parts.add(preset.filmFilter!.displayName);
    }
    if (preset.grainIntensity > 0) {
      parts.add('그레인 ${(preset.grainIntensity * 100).toInt()}%');
    }
    return parts.isEmpty ? '기본 설정' : parts.join(' + ');
  }
}

/// Lumera 아이콘 버튼
class _LumeraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _LumeraIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
    );
  }
}

/// 옵션 타일
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 프리셋 상세 보기 다이얼로그
class _PresetDetailDialog extends StatelessWidget {
  final EditPreset preset;

  const _PresetDetailDialog({required this.preset});

  @override
  Widget build(BuildContext context) {
    final description = DefaultPresets.getDescription(preset.id);

    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        preset.name,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],
            _buildDetailRow('필터', preset.filmFilter?.displayName ?? '없음'),
            _buildDetailRow(
                '필터 강도', '${(preset.filterStrength * 100).toInt()}%'),
            _buildDetailRow(
                '그레인', '${(preset.grainIntensity * 100).toInt()}%'),
            _buildDetailRow('블러', '${(preset.blurStrength * 100).toInt()}%'),
            if (preset.aspectRatio != null)
              _buildDetailRow('비율', preset.aspectRatio!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// 새 프리셋 생성 다이얼로그
class _CreatePresetDialog extends StatefulWidget {
  final void Function(EditPreset) onSave;

  const _CreatePresetDialog({required this.onSave});

  @override
  State<_CreatePresetDialog> createState() => _CreatePresetDialogState();
}

class _CreatePresetDialogState extends State<_CreatePresetDialog> {
  final _nameController = TextEditingController();
  FilmFilter? _selectedFilter;
  double _filterStrength = 0.8;
  double _grainIntensity = 0.25;
  double _blurStrength = 0.0;
  String? _aspectRatio;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋 이름을 입력하세요')),
      );
      return;
    }

    final newPreset = EditPreset(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      createdAt: DateTime.now(),
      isDefault: false,
      filmFilter: _selectedFilter,
      filterStrength: _filterStrength,
      grainIntensity: _grainIntensity,
      blurStrength: _blurStrength,
      aspectRatio: _aspectRatio,
    );

    widget.onSave(newPreset);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        '새 프리셋 만들기',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '프리셋 이름',
                hintText: '예: My Vintage',
              ),
            ),
            const SizedBox(height: 24),
            _buildFilterSelector(),
            const SizedBox(height: 16),
            _buildSlider('필터 강도', _filterStrength, (v) {
              setState(() => _filterStrength = v);
            }),
            _buildSlider('그레인', _grainIntensity, (v) {
              setState(() => _grainIntensity = v);
            }),
            _buildSlider('블러', _blurStrength, (v) {
              setState(() => _blurStrength = v);
            }),
            const SizedBox(height: 16),
            _buildAspectRatioSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('생성'),
        ),
      ],
    );
  }

  Widget _buildFilterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '필름 필터',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<FilmFilter?>(
          isExpanded: true,
          value: _selectedFilter,
          hint: const Text('필터 선택'),
          items: [
            const DropdownMenuItem(value: null, child: Text('없음')),
            ...FilmFilter.values.map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter.displayName),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedFilter = value);
          },
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    void Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.backgroundColor,
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector() {
    final ratios = ['1:1', '4:3', '16:9'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '종횡비',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('원본'),
              selected: _aspectRatio == null,
              selectedColor: AppTheme.primaryColor,
              onSelected: (selected) {
                setState(() => _aspectRatio = null);
              },
            ),
            ...ratios.map((ratio) {
              return ChoiceChip(
                label: Text(ratio),
                selected: _aspectRatio == ratio,
                selectedColor: AppTheme.primaryColor,
                onSelected: (selected) {
                  setState(() => _aspectRatio = selected ? ratio : null);
                },
              );
            }),
          ],
        ),
      ],
    );
  }
}

/// 프리셋 편집 다이얼로그
class _EditPresetDialog extends StatefulWidget {
  final EditPreset preset;
  final void Function(EditPreset) onSave;

  const _EditPresetDialog({
    required this.preset,
    required this.onSave,
  });

  @override
  State<_EditPresetDialog> createState() => _EditPresetDialogState();
}

class _EditPresetDialogState extends State<_EditPresetDialog> {
  late TextEditingController _nameController;
  late FilmFilter? _selectedFilter;
  late double _filterStrength;
  late double _grainIntensity;
  late double _blurStrength;
  late String? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset.name);
    _selectedFilter = widget.preset.filmFilter;
    _filterStrength = widget.preset.filterStrength;
    _grainIntensity = widget.preset.grainIntensity;
    _blurStrength = widget.preset.blurStrength;
    _aspectRatio = widget.preset.aspectRatio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋 이름을 입력하세요')),
      );
      return;
    }

    final updatedPreset = widget.preset.copyWith(
      name: _nameController.text.trim(),
      filmFilter: _selectedFilter,
      filterStrength: _filterStrength,
      grainIntensity: _grainIntensity,
      blurStrength: _blurStrength,
      aspectRatio: _aspectRatio,
      clearAspectRatio: _aspectRatio == null,
    );

    widget.onSave(updatedPreset);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        '프리셋 편집',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '프리셋 이름',
              ),
            ),
            const SizedBox(height: 24),
            _buildFilterSelector(),
            const SizedBox(height: 16),
            _buildSlider('필터 강도', _filterStrength, (v) {
              setState(() => _filterStrength = v);
            }),
            _buildSlider('그레인', _grainIntensity, (v) {
              setState(() => _grainIntensity = v);
            }),
            _buildSlider('블러', _blurStrength, (v) {
              setState(() => _blurStrength = v);
            }),
            const SizedBox(height: 16),
            _buildAspectRatioSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildFilterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '필름 필터',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<FilmFilter?>(
          isExpanded: true,
          value: _selectedFilter,
          hint: const Text('필터 선택'),
          items: [
            const DropdownMenuItem(value: null, child: Text('없음')),
            ...FilmFilter.values.map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter.displayName),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedFilter = value);
          },
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    void Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.backgroundColor,
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector() {
    final ratios = ['1:1', '4:3', '16:9'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '종횡비',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('원본'),
              selected: _aspectRatio == null,
              selectedColor: AppTheme.primaryColor,
              onSelected: (selected) {
                setState(() => _aspectRatio = null);
              },
            ),
            ...ratios.map((ratio) {
              return ChoiceChip(
                label: Text(ratio),
                selected: _aspectRatio == ratio,
                selectedColor: AppTheme.primaryColor,
                onSelected: (selected) {
                  setState(() => _aspectRatio = selected ? ratio : null);
                },
              );
            }),
          ],
        ),
      ],
    );
  }
}
