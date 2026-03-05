import 'package:flutter/material.dart';
import 'package:photoedit/core/presets/preset_model.dart';
import 'package:photoedit/core/filters/film_filter.dart';

/// 프리셋 카드 위젯
///
/// 그리드에 표시되는 개별 프리셋 카드
/// - 그라데이션 배경으로 필터 종류 표현
/// - 프리셋 이름과 설정 요약 표시
/// - 탭/롱프레스 제스처 지원
class PresetCard extends StatelessWidget {
  final EditPreset preset;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PresetCard({
    super.key,
    required this.preset,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getGradientForFilter(preset.filmFilter),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 배경 패턴 (그레인 표현)
            if (preset.grainIntensity > 0.1)
              Positioned.fill(
                child: CustomPaint(
                  painter: _GrainPatternPainter(preset.grainIntensity),
                ),
              ),

            // 내용
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 아이콘과 뱃지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 필터 아이콘
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          preset.isDefault
                              ? Icons.auto_awesome
                              : Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      // MY 뱃지 (사용자 프리셋)
                      if (!preset.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'MY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // 하단: 프리셋 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프리셋 이름
                      Text(
                        preset.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // 설정 요약
                      _buildSettingsSummary(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 필터에 따른 그라데이션 배경
  LinearGradient _getGradientForFilter(FilmFilter? filter) {
    if (filter == null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey[700]!,
          Colors.grey[900]!,
        ],
      );
    }

    switch (filter) {
      case FilmFilter.portra400:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB6B9), // 부드러운 핑크
            Color(0xFFFAE3D9), // 따뜻한 베이지
          ],
        );

      case FilmFilter.gold200:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD93D), // 골드 옐로우
            Color(0xFFFF8B00), // 오렌지
          ],
        );

      case FilmFilter.velvia50:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00C9FF), // 밝은 시안
            Color(0xFF92FE9D), // 민트 그린
          ],
        );

      case FilmFilter.triX400:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50), // 다크 그레이
            Color(0xFF95A5A6), // 라이트 그레이
          ],
        );

      case FilmFilter.polaroid:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFEAA7), // 폴라로이드 옐로우
            Color(0xFFFFC3A0), // 피치
          ],
        );

      case FilmFilter.superia400:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B), // 레드
            Color(0xFFFECA57), // 옐로우
          ],
        );

      case FilmFilter.cinestill800t:
      case FilmFilter.cinestill50d:
      case FilmFilter.vision3_250d:
      case FilmFilter.vision3_500t:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF141E30), // 다크 블루
            Color(0xFF243B55), // 미드나잇 블루
          ],
        );

      // Kodak 컬러 계열
      case FilmFilter.portra160:
      case FilmFilter.ektar100:
      case FilmFilter.colorplus200:
      case FilmFilter.ultramax400:
      case FilmFilter.kodachrome25:
      case FilmFilter.kodachrome64:
      case FilmFilter.ektachrome100:
      case FilmFilter.eliteChrome200:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB6B9),
            Color(0xFFFFC971),
          ],
        );

      // Kodak 흑백 계열
      case FilmFilter.tmax100:
      case FilmFilter.tmax400:
      case FilmFilter.tmax3200:
      case FilmFilter.bw400cn:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF434343),
            Color(0xFF000000),
          ],
        );

      // Fuji 컬러 계열
      case FilmFilter.superia100:
      case FilmFilter.superia800:
      case FilmFilter.superia1600:
      case FilmFilter.pro400h:
      case FilmFilter.fuji160c:
      case FilmFilter.fuji800z:
      case FilmFilter.reala100:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF7E5F),
            Color(0xFFFEB47B),
          ],
        );

      // Fuji 슬라이드 계열
      case FilmFilter.velvia100:
      case FilmFilter.provia100f:
      case FilmFilter.provia400x:
      case FilmFilter.astia100f:
      case FilmFilter.sensia100:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF56CCF2),
            Color(0xFF2F80ED),
          ],
        );

      // Fuji 흑백
      case FilmFilter.neopanAcros:
      case FilmFilter.neopan400:
      case FilmFilter.neopan1600:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF606060),
            Color(0xFF1A1A1A),
          ],
        );

      // Ilford 계열
      case FilmFilter.hp5plus:
      case FilmFilter.fp4plus:
      case FilmFilter.delta100:
      case FilmFilter.delta400:
      case FilmFilter.delta3200:
      case FilmFilter.panF50:
      case FilmFilter.xp2super:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF95A5A6),
          ],
        );

      // Polaroid 계열
      case FilmFilter.polaroid600:
      case FilmFilter.polaroid669:
      case FilmFilter.timeZero:
      case FilmFilter.instax:
      case FilmFilter.fp100c:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFFFCCBC),
          ],
        );

      // Agfa 계열
      case FilmFilter.vistaPlus:
      case FilmFilter.agfaUltra:
      case FilmFilter.apx100:
      case FilmFilter.apx400:
      case FilmFilter.precisa100:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8D5B7),
            Color(0xFFB8860B),
          ],
        );

      // Lomo 계열
      case FilmFilter.lomoColor400:
      case FilmFilter.lomoXpro:
      case FilmFilter.lomoPurple:
      case FilmFilter.lomoRedscale:
      case FilmFilter.lomoEarlGrey:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF416C),
            Color(0xFFFF4B2B),
          ],
        );

      // Rollei 계열
      case FilmFilter.rolleiRetro80s:
      case FilmFilter.rolleiIR400:
      case FilmFilter.rolleiOrtho25:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A4A4A),
            Color(0xFF2D2D2D),
          ],
        );

      // Creative 계열
      case FilmFilter.crossProcess:
      case FilmFilter.bleachBypass:
      case FilmFilter.vintageFade:
      case FilmFilter.sepiaClassic:
      case FilmFilter.cyanotype:
      case FilmFilter.duotoneBlue:
      case FilmFilter.duotoneOrange:
      case FilmFilter.tealOrange:
      case FilmFilter.matteFilm:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8E2DE2),
            Color(0xFF4A00E0),
          ],
        );
    }
  }

  /// 설정 요약 텍스트
  Widget _buildSettingsSummary() {
    final parts = <String>[];

    // 필터 이름
    if (preset.filmFilter != null) {
      parts.add(preset.filmFilter!.displayName);
    }

    // 그레인 강도
    if (preset.grainIntensity > 0.1) {
      parts.add('그레인 ${(preset.grainIntensity * 100).toInt()}%');
    }

    // 블러 강도
    if (preset.blurStrength > 0.1) {
      parts.add('블러');
    }

    // 종횡비
    if (preset.aspectRatio != null) {
      parts.add(preset.aspectRatio!);
    }

    final summary = parts.isEmpty ? '기본' : parts.take(2).join(' • ');

    return Text(
      summary,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        height: 1.2,
        shadows: [
          Shadow(
            color: Colors.black45,
            blurRadius: 2,
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 그레인 패턴 페인터
class _GrainPatternPainter extends CustomPainter {
  final double intensity;

  _GrainPatternPainter(this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(intensity * 0.15)
      ..style = PaintingStyle.fill;

    // 랜덤 시드 고정 (일관된 패턴)
    final seed = 12345;
    var random = seed;

    // 그레인 효과를 위한 작은 점들
    final dotCount = (intensity * 100).toInt();
    for (int i = 0; i < dotCount; i++) {
      // 의사 랜덤 생성 (실제 Random 사용하지 않음)
      random = (random * 1103515245 + 12345) & 0x7fffffff;
      final x = (random % 1000) / 1000 * size.width;

      random = (random * 1103515245 + 12345) & 0x7fffffff;
      final y = (random % 1000) / 1000 * size.height;

      random = (random * 1103515245 + 12345) & 0x7fffffff;
      final radius = (random % 3) / 3 + 0.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // 약간의 노이즈 텍스처 라인
    if (intensity > 0.3) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < 5; i++) {
        final y = size.height * (i / 5);
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
