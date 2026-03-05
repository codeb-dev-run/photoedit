import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/models/preset.dart';
import '../../core/models/batch_progress.dart';
import '../presets/preset_manager.dart';
import 'batch_processor.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  List<String> _selectedImagePaths = [];
  List<Preset> _presets = [];
  Preset? _selectedPreset;
  BatchProgress? _progress;
  BatchProcessor? _processor;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final manager = await PresetManager.init();
    final presets = await manager.getAllPresets();
    setState(() {
      _presets = presets;
      if (presets.isNotEmpty) {
        _selectedPreset = presets.first;
      }
    });
  }

  Future<void> _addImages() async {
    if (_isProcessing) return;

    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 100);

      if (images.isNotEmpty) {
        final newPaths = images.map((img) => img.path).toList();
        setState(() {
          _selectedImagePaths.addAll(newPaths);
          if (_selectedImagePaths.length > 50) {
            _selectedImagePaths = _selectedImagePaths.sublist(0, 50);
            _showMessage('최대 50개까지만 선택할 수 있습니다.');
          }
        });
      }
    } catch (e) {
      _showMessage('이미지 선택 실패: $e');
    }
  }

  void _removeImage(int index) {
    if (_isProcessing) return;
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }

  Future<void> _startBatchProcessing() async {
    if (_selectedImagePaths.isEmpty) {
      _showMessage('처리할 이미지를 선택해주세요.');
      return;
    }

    if (_selectedPreset == null) {
      _showMessage('프리셋을 선택해주세요.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = BatchProgress(
        total: _selectedImagePaths.length,
        completed: 0,
        failed: 0,
        status: BatchStatus.processing,
      );
    });

    _processor = BatchProcessor(
      imagePaths: _selectedImagePaths,
      settings: _selectedPreset!.settings,
    );

    _processor!.progressStream.listen(
      (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      },
      onDone: () {
        if (mounted) {
          _onProcessingComplete();
        }
      },
      onError: (error) {
        if (mounted) {
          _showMessage('처리 중 오류 발생: $error');
          setState(() {
            _isProcessing = false;
          });
        }
      },
    );

    try {
      final result = await _processor!.process();
      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('처리 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onProcessingComplete() {
    setState(() {
      _isProcessing = false;
    });
  }

  void _cancelProcessing() {
    _processor?.cancel();
    setState(() {
      _isProcessing = false;
      _progress = null;
    });
  }

  void _showResultDialog(BatchResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('일괄 처리 완료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 처리: ${result.totalCount}개'),
            const SizedBox(height: 8),
            Text(
              '성공: ${result.successCount}개',
              style: const TextStyle(color: Colors.green),
            ),
            if (result.hasErrors) ...[
              const SizedBox(height: 4),
              Text(
                '실패: ${result.failedCount}개',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 8),
            Text('소요 시간: ${_formatDuration(result.duration)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedImagePaths.clear();
                _progress = null;
              });
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '$seconds초';
    }
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds % 60;
    return '$minutes분 $remainingSeconds초';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 컨텐츠
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프리셋 선택
                    _buildPresetSelector(),
                    const SizedBox(height: 32),

                    // 이미지 섹션
                    _buildImageHeader(),
                    const SizedBox(height: 16),

                    // 이미지 그리드
                    Expanded(
                      child: _selectedImagePaths.isEmpty
                          ? _buildEmptyState()
                          : _buildImageGrid(),
                    ),
                  ],
                ),
              ),
            ),

            // 진행률 표시
            if (_progress != null) _buildProgressSection(),

            // 하단 버튼
            _buildBottomButton(),
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
            onTap: _isProcessing ? null : () => Navigator.pop(context),
          ),
          const Text(
            '일괄 처리',
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

  Widget _buildPresetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '적용할 프리셋',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Preset>(
              value: _selectedPreset,
              isExpanded: true,
              hint: const Text('프리셋을 선택하세요'),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textMuted,
              ),
              items: _presets.map((preset) {
                return DropdownMenuItem<Preset>(
                  value: preset,
                  child: Row(
                    children: [
                      if (preset.isDefault)
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          preset.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isProcessing
                  ? null
                  : (preset) {
                      setState(() {
                        _selectedPreset = preset;
                      });
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '이미지 (${_selectedImagePaths.length}/50)',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        GestureDetector(
          onTap: _isProcessing ? null : _addImages,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.add,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  '추가',
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
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '이미지를 추가해주세요',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '최대 50개까지 선택할 수 있습니다',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addImages,
            icon: const Icon(Icons.add),
            label: const Text('이미지 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = _selectedImagePaths[index];
        return _buildImageCard(imagePath, index);
      },
    );
  }

  Widget _buildImageCard(String imagePath, int index) {
    return GestureDetector(
      onTap: _isProcessing ? null : () => _removeImage(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
          if (!_isProcessing)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          if (_isProcessing)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.backgroundColor),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress!.progress,
              minHeight: 8,
              backgroundColor: AppTheme.backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress!.isCompleted
                    ? Colors.green
                    : _progress!.isCancelled
                        ? Colors.orange
                        : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '처리 중: ${_progress!.completed + _progress!.failed}/${_progress!.total}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                '${(_progress!.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _isProcessing ||
                  _selectedImagePaths.isEmpty ||
                  _selectedPreset == null
              ? null
              : _startBatchProcessing,
          child: Text(
            _isProcessing ? '처리 중...' : '일괄 처리 시작',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _processor?.cancel();
    super.dispose();
  }
}

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
