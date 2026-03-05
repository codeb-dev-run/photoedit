/// 필름 필터 종류 - 오픈소스 G'MIC Film Luts 기반 확장
enum FilmFilter {
  // ═══════════════════════════════════════════
  // KODAK 컬러 네거티브
  // ═══════════════════════════════════════════
  /// Kodak Portra 400 - 따뜻하고 부드러운 인물용 필름
  portra400('Kodak Portra 400'),

  /// Kodak Portra 160 - 섬세한 스킨톤
  portra160('Kodak Portra 160'),

  /// Kodak Ektar 100 - 선명하고 채도 높은 필름
  ektar100('Kodak Ektar 100'),

  /// Kodak Gold 200 - 빈티지 따뜻한 일상 필름
  gold200('Kodak Gold 200'),

  /// Kodak ColorPlus 200 - 따뜻한 캐주얼 필름
  colorplus200('Kodak ColorPlus 200'),

  /// Kodak Ultramax 400 - 강한 채도와 콘트라스트
  ultramax400('Kodak Ultramax 400'),

  // ═══════════════════════════════════════════
  // KODAK 흑백
  // ═══════════════════════════════════════════
  /// Kodak Tri-X 400 - 클래식 흑백 필름
  triX400('Kodak Tri-X 400'),

  /// Kodak T-Max 100 - 정밀한 흑백 필름
  tmax100('Kodak T-Max 100'),

  /// Kodak T-Max 400 - 다용도 흑백 필름
  tmax400('Kodak T-Max 400'),

  /// Kodak T-Max 3200 - 고감도 흑백 필름
  tmax3200('Kodak T-Max 3200'),

  /// Kodak BW 400 CN - 흑백 컬러 네거티브
  bw400cn('Kodak BW 400 CN'),

  // ═══════════════════════════════════════════
  // KODAK 슬라이드/리버설
  // ═══════════════════════════════════════════
  /// Kodak Kodachrome 25 - 전설적인 슬라이드 필름
  kodachrome25('Kodak Kodachrome 25'),

  /// Kodak Kodachrome 64 - 클래식 슬라이드
  kodachrome64('Kodak Kodachrome 64'),

  /// Kodak Ektachrome 100 - 선명한 슬라이드
  ektachrome100('Kodak Ektachrome 100'),

  /// Kodak Elite Chrome 200 - 다용도 슬라이드
  eliteChrome200('Kodak Elite Chrome 200'),

  // ═══════════════════════════════════════════
  // FUJI 컬러 네거티브
  // ═══════════════════════════════════════════
  /// Fuji Superia 400 - 90년대 일본 감성 필름
  superia400('Fuji Superia 400'),

  /// Fuji Superia 100 - 섬세한 일상 필름
  superia100('Fuji Superia 100'),

  /// Fuji Superia 800 - 고감도 필름
  superia800('Fuji Superia 800'),

  /// Fuji Superia 1600 - 저조도용 필름
  superia1600('Fuji Superia 1600'),

  /// Fuji Pro 400H - 웨딩/인물용 프로 필름
  pro400h('Fuji Pro 400H'),

  /// Fuji 160C - 스튜디오 인물용
  fuji160c('Fuji 160C'),

  /// Fuji 800Z - 고감도 프로 필름
  fuji800z('Fuji 800Z'),

  /// Fuji Reala 100 - 자연스러운 색 재현
  reala100('Fuji Reala 100'),

  // ═══════════════════════════════════════════
  // FUJI 슬라이드/리버설
  // ═══════════════════════════════════════════
  /// Fuji Velvia 50 - 선명하고 채도 높은 풍경용 필름
  velvia50('Fuji Velvia 50'),

  /// Fuji Velvia 100 - 다용도 고채도 필름
  velvia100('Fuji Velvia 100'),

  /// Fuji Provia 100F - 균형 잡힌 슬라이드
  provia100f('Fuji Provia 100F'),

  /// Fuji Provia 400X - 고감도 슬라이드
  provia400x('Fuji Provia 400X'),

  /// Fuji Astia 100F - 부드러운 스킨톤 슬라이드
  astia100f('Fuji Astia 100F'),

  /// Fuji Sensia 100 - 입문용 슬라이드
  sensia100('Fuji Sensia 100'),

  // ═══════════════════════════════════════════
  // FUJI 흑백
  // ═══════════════════════════════════════════
  /// Fuji Neopan 100 Acros - 정밀 흑백
  neopanAcros('Fuji Neopan Acros'),

  /// Fuji Neopan 400 - 다용도 흑백
  neopan400('Fuji Neopan 400'),

  /// Fuji Neopan 1600 - 고감도 흑백
  neopan1600('Fuji Neopan 1600'),

  // ═══════════════════════════════════════════
  // ILFORD 흑백
  // ═══════════════════════════════════════════
  /// Ilford HP5 Plus 400 - 클래식 다용도 흑백
  hp5plus('Ilford HP5 Plus'),

  /// Ilford FP4 Plus 125 - 정밀 흑백
  fp4plus('Ilford FP4 Plus'),

  /// Ilford Delta 100 - 미세 입자 흑백
  delta100('Ilford Delta 100'),

  /// Ilford Delta 400 - 다용도 현대 흑백
  delta400('Ilford Delta 400'),

  /// Ilford Delta 3200 - 극고감도 흑백
  delta3200('Ilford Delta 3200'),

  /// Ilford Pan F Plus 50 - 극미세 입자 흑백
  panF50('Ilford Pan F Plus'),

  /// Ilford XP2 Super - C-41 흑백
  xp2super('Ilford XP2 Super'),

  // ═══════════════════════════════════════════
  // POLAROID / INSTANT
  // ═══════════════════════════════════════════
  /// Polaroid SX-70 - 인스턴트 필름 특유의 색감
  polaroid('Polaroid'),

  /// Polaroid 600 - 클래식 폴라로이드
  polaroid600('Polaroid 600'),

  /// Polaroid 669 - 필오프 필름
  polaroid669('Polaroid 669'),

  /// Polaroid Time Zero - 빈티지 인스턴트
  timeZero('Polaroid Time Zero'),

  /// Fuji Instax - 현대 인스턴트
  instax('Fuji Instax'),

  /// Fuji FP-100C - 팩 필름
  fp100c('Fuji FP-100C'),

  // ═══════════════════════════════════════════
  // AGFA
  // ═══════════════════════════════════════════
  /// Agfa Vista 200 - 따뜻한 컬러
  vistaPlus('Agfa Vista 200'),

  /// Agfa Ultra 100 - 고채도 컬러
  agfaUltra('Agfa Ultra 100'),

  /// Agfa APX 100 - 흑백 필름
  apx100('Agfa APX 100'),

  /// Agfa APX 400 - 다용도 흑백
  apx400('Agfa APX 400'),

  /// Agfa Precisa 100 - 슬라이드 필름
  precisa100('Agfa Precisa 100'),

  // ═══════════════════════════════════════════
  // LOMOGRAPHY
  // ═══════════════════════════════════════════
  /// Lomography Color 400 - 생동감 있는 컬러
  lomoColor400('Lomo Color 400'),

  /// Lomography X-Pro Chrome - 크로스 프로세스
  lomoXpro('Lomo X-Pro'),

  /// Lomography Purple - 특수 효과 필름
  lomoPurple('Lomo Purple'),

  /// Lomography Redscale - 레드스케일 필름
  lomoRedscale('Lomo Redscale'),

  /// Lomography Earl Grey - 흑백
  lomoEarlGrey('Lomo Earl Grey'),

  // ═══════════════════════════════════════════
  // CINEMATIC / MOVIE
  // ═══════════════════════════════════════════
  /// Cinestill 800T - 시네마틱 야간 촬영 필름
  cinestill800t('Cinestill 800T'),

  /// Cinestill 50D - 시네마틱 주간 촬영 필름
  cinestill50d('Cinestill 50D'),

  /// Kodak Vision3 250D - 영화용 주간 필름
  vision3_250d('Vision3 250D'),

  /// Kodak Vision3 500T - 영화용 야간 필름
  vision3_500t('Vision3 500T'),

  // ═══════════════════════════════════════════
  // ROLLEI
  // ═══════════════════════════════════════════
  /// Rollei Retro 80s - 레트로 흑백
  rolleiRetro80s('Rollei Retro 80s'),

  /// Rollei Infrared 400 - 적외선 흑백
  rolleiIR400('Rollei IR 400'),

  /// Rollei Ortho 25 - 오소크로매틱 흑백
  rolleiOrtho25('Rollei Ortho 25'),

  // ═══════════════════════════════════════════
  // CREATIVE / SPECIAL
  // ═══════════════════════════════════════════
  /// Cross Process - 크로스 프로세스 효과
  crossProcess('Cross Process'),

  /// Bleach Bypass - 블리치 바이패스 효과
  bleachBypass('Bleach Bypass'),

  /// Vintage Fade - 빈티지 페이드 효과
  vintageFade('Vintage Fade'),

  /// Sepia Classic - 클래식 세피아
  sepiaClassic('Sepia Classic'),

  /// Cyanotype - 시아노타입 청색
  cyanotype('Cyanotype'),

  /// Duotone Blue - 듀오톤 블루
  duotoneBlue('Duotone Blue'),

  /// Duotone Orange - 듀오톤 오렌지
  duotoneOrange('Duotone Orange'),

  /// Teal Orange - 시네마틱 틸/오렌지
  tealOrange('Teal & Orange'),

  /// Matte Film - 매트 필름
  matteFilm('Matte Film');

  const FilmFilter(this.displayName);

  final String displayName;
}

/// 필터 카테고리
enum FilterCategory {
  kodakColor('Kodak 컬러'),
  kodakBW('Kodak 흑백'),
  kodakSlide('Kodak 슬라이드'),
  fujiColor('Fuji 컬러'),
  fujiSlide('Fuji 슬라이드'),
  fujiBW('Fuji 흑백'),
  ilford('Ilford'),
  polaroid('Polaroid/Instant'),
  agfa('Agfa'),
  lomo('Lomography'),
  cinema('Cinema'),
  rollei('Rollei'),
  creative('Creative');

  const FilterCategory(this.displayName);
  final String displayName;
}

/// 필터별 카테고리 매핑
Map<FilmFilter, FilterCategory> get filterCategories => {
  // Kodak Color
  FilmFilter.portra400: FilterCategory.kodakColor,
  FilmFilter.portra160: FilterCategory.kodakColor,
  FilmFilter.ektar100: FilterCategory.kodakColor,
  FilmFilter.gold200: FilterCategory.kodakColor,
  FilmFilter.colorplus200: FilterCategory.kodakColor,
  FilmFilter.ultramax400: FilterCategory.kodakColor,
  // Kodak BW
  FilmFilter.triX400: FilterCategory.kodakBW,
  FilmFilter.tmax100: FilterCategory.kodakBW,
  FilmFilter.tmax400: FilterCategory.kodakBW,
  FilmFilter.tmax3200: FilterCategory.kodakBW,
  FilmFilter.bw400cn: FilterCategory.kodakBW,
  // Kodak Slide
  FilmFilter.kodachrome25: FilterCategory.kodakSlide,
  FilmFilter.kodachrome64: FilterCategory.kodakSlide,
  FilmFilter.ektachrome100: FilterCategory.kodakSlide,
  FilmFilter.eliteChrome200: FilterCategory.kodakSlide,
  // Fuji Color
  FilmFilter.superia400: FilterCategory.fujiColor,
  FilmFilter.superia100: FilterCategory.fujiColor,
  FilmFilter.superia800: FilterCategory.fujiColor,
  FilmFilter.superia1600: FilterCategory.fujiColor,
  FilmFilter.pro400h: FilterCategory.fujiColor,
  FilmFilter.fuji160c: FilterCategory.fujiColor,
  FilmFilter.fuji800z: FilterCategory.fujiColor,
  FilmFilter.reala100: FilterCategory.fujiColor,
  // Fuji Slide
  FilmFilter.velvia50: FilterCategory.fujiSlide,
  FilmFilter.velvia100: FilterCategory.fujiSlide,
  FilmFilter.provia100f: FilterCategory.fujiSlide,
  FilmFilter.provia400x: FilterCategory.fujiSlide,
  FilmFilter.astia100f: FilterCategory.fujiSlide,
  FilmFilter.sensia100: FilterCategory.fujiSlide,
  // Fuji BW
  FilmFilter.neopanAcros: FilterCategory.fujiBW,
  FilmFilter.neopan400: FilterCategory.fujiBW,
  FilmFilter.neopan1600: FilterCategory.fujiBW,
  // Ilford
  FilmFilter.hp5plus: FilterCategory.ilford,
  FilmFilter.fp4plus: FilterCategory.ilford,
  FilmFilter.delta100: FilterCategory.ilford,
  FilmFilter.delta400: FilterCategory.ilford,
  FilmFilter.delta3200: FilterCategory.ilford,
  FilmFilter.panF50: FilterCategory.ilford,
  FilmFilter.xp2super: FilterCategory.ilford,
  // Polaroid
  FilmFilter.polaroid: FilterCategory.polaroid,
  FilmFilter.polaroid600: FilterCategory.polaroid,
  FilmFilter.polaroid669: FilterCategory.polaroid,
  FilmFilter.timeZero: FilterCategory.polaroid,
  FilmFilter.instax: FilterCategory.polaroid,
  FilmFilter.fp100c: FilterCategory.polaroid,
  // Agfa
  FilmFilter.vistaPlus: FilterCategory.agfa,
  FilmFilter.agfaUltra: FilterCategory.agfa,
  FilmFilter.apx100: FilterCategory.agfa,
  FilmFilter.apx400: FilterCategory.agfa,
  FilmFilter.precisa100: FilterCategory.agfa,
  // Lomo
  FilmFilter.lomoColor400: FilterCategory.lomo,
  FilmFilter.lomoXpro: FilterCategory.lomo,
  FilmFilter.lomoPurple: FilterCategory.lomo,
  FilmFilter.lomoRedscale: FilterCategory.lomo,
  FilmFilter.lomoEarlGrey: FilterCategory.lomo,
  // Cinema
  FilmFilter.cinestill800t: FilterCategory.cinema,
  FilmFilter.cinestill50d: FilterCategory.cinema,
  FilmFilter.vision3_250d: FilterCategory.cinema,
  FilmFilter.vision3_500t: FilterCategory.cinema,
  // Rollei
  FilmFilter.rolleiRetro80s: FilterCategory.rollei,
  FilmFilter.rolleiIR400: FilterCategory.rollei,
  FilmFilter.rolleiOrtho25: FilterCategory.rollei,
  // Creative
  FilmFilter.crossProcess: FilterCategory.creative,
  FilmFilter.bleachBypass: FilterCategory.creative,
  FilmFilter.vintageFade: FilterCategory.creative,
  FilmFilter.sepiaClassic: FilterCategory.creative,
  FilmFilter.cyanotype: FilterCategory.creative,
  FilmFilter.duotoneBlue: FilterCategory.creative,
  FilmFilter.duotoneOrange: FilterCategory.creative,
  FilmFilter.tealOrange: FilterCategory.creative,
  FilmFilter.matteFilm: FilterCategory.creative,
};

/// 카테고리별 필터 가져오기
List<FilmFilter> getFiltersByCategory(FilterCategory category) {
  return filterCategories.entries
      .where((e) => e.value == category)
      .map((e) => e.key)
      .toList();
}
