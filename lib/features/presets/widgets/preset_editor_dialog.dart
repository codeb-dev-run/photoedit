import 'package:flutter/material.dart';
import '../../../core/models/preset.dart';

/// 프리셋 편집 다이얼로그
class PresetEditorDialog extends StatefulWidget {
  final Preset? preset;
  final Function(String name, String? description, PresetSettings settings) onSave;

  const PresetEditorDialog({
    super.key,
    this.preset,
    required this.onSave,
  });

  @override
  State<PresetEditorDialog> createState() => _PresetEditorDialogState();
}

class _PresetEditorDialogState extends State<PresetEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late double _brightness;
  late double _contrast;
  late double _saturation;
  late double _blur;
  late double _grain;
  late FilmFilter _filmFilter;
  Color? _tintColor;
  late double _tintOpacity;

  @override
  void initState() {
    super.initState();

    final settings = widget.preset?.settings ?? const PresetSettings();

    _nameController = TextEditingController(text: widget.preset?.name ?? '');
    _descriptionController = TextEditingController(text: widget.preset?.description ?? '');

    _brightness = settings.brightness;
    _contrast = settings.contrast;
    _saturation = settings.saturation;
    _blur = settings.blur;
    _grain = settings.grain;
    _filmFilter = settings.filmFilter;
    _tintColor = settings.tintColor;
    _tintOpacity = settings.tintOpacity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            // 헤더
            AppBar(
              title: Text(widget.preset == null ? '새 프리셋' : '프리셋 편집'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '프리셋 이름',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 설명
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '설명 (선택사항)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),
                    const Text('효과 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // 밝기
                    _buildSlider(
                      label: '밝기',
                      value: _brightness,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (value) => setState(() => _brightness = value),
                    ),

                    // 대비
                    _buildSlider(
                      label: '대비',
                      value: _contrast,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (value) => setState(() => _contrast = value),
                    ),

                    // 채도
                    _buildSlider(
                      label: '채도',
                      value: _saturation,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (value) => setState(() => _saturation = value),
                    ),

                    // 블러
                    _buildSlider(
                      label: '블러',
                      value: _blur,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) => setState(() => _blur = value),
                    ),

                    // 그레인
                    _buildSlider(
                      label: '그레인',
                      value: _grain,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) => setState(() => _grain = value),
                    ),

                    const SizedBox(height: 16),

                    // 필름 필터
                    DropdownButtonFormField<FilmFilter>(
                      value: _filmFilter,
                      decoration: const InputDecoration(
                        labelText: '필름 필터',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.photo_filter),
                      ),
                      items: FilmFilter.values.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _filmFilter = value);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // 틴트 컬러
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '틴트 컬러',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _tintColor == null ? Icons.color_lens_outlined : Icons.color_lens,
                            color: _tintColor,
                          ),
                          onPressed: _pickTintColor,
                        ),
                        if (_tintColor != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() {
                              _tintColor = null;
                              _tintOpacity = 0;
                            }),
                          ),
                      ],
                    ),

                    if (_tintColor != null)
                      _buildSlider(
                        label: '틴트 불투명도',
                        value: _tintOpacity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) => setState(() => _tintOpacity = value),
                      ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('저장'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    final displayValue = value >= 0 ? '+${(value * 100).toInt()}' : '${(value * 100).toInt()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(displayValue, style: const TextStyle(color: Colors.blue)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _pickTintColor() async {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.grey,
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('틴트 컬러 선택'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return InkWell(
              onTap: () => Navigator.pop(context, color),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: _tintColor == color ? Colors.black : Colors.grey,
                    width: _tintColor == color ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedColor != null) {
      setState(() {
        _tintColor = selectedColor;
        if (_tintOpacity == 0) {
          _tintOpacity = 0.2;
        }
      });
    }
  }

  void _save() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋 이름을 입력해주세요')),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final settings = PresetSettings(
      brightness: _brightness,
      contrast: _contrast,
      saturation: _saturation,
      blur: _blur,
      grain: _grain,
      filmFilter: _filmFilter,
      tintColor: _tintColor,
      tintOpacity: _tintOpacity,
    );

    widget.onSave(
      name,
      description.isEmpty ? null : description,
      settings,
    );

    Navigator.pop(context);
  }
}
