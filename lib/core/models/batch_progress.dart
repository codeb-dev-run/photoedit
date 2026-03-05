/// 일괄 처리 진행 상태
class BatchProgress {
  final int total;
  final int completed;
  final int failed;
  final String? currentFileName;
  final String? errorMessage;
  final BatchStatus status;

  const BatchProgress({
    required this.total,
    required this.completed,
    required this.failed,
    this.currentFileName,
    this.errorMessage,
    required this.status,
  });

  double get progress {
    if (total == 0) return 0.0;
    return (completed + failed) / total;
  }

  int get remaining => total - completed - failed;

  bool get isCompleted => status == BatchStatus.completed;
  bool get isProcessing => status == BatchStatus.processing;
  bool get isCancelled => status == BatchStatus.cancelled;
  bool get hasErrors => failed > 0;

  BatchProgress copyWith({
    int? total,
    int? completed,
    int? failed,
    String? currentFileName,
    String? errorMessage,
    BatchStatus? status,
  }) {
    return BatchProgress(
      total: total ?? this.total,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      currentFileName: currentFileName ?? this.currentFileName,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}

/// 일괄 처리 상태
enum BatchStatus {
  idle,
  processing,
  completed,
  cancelled,
  error,
}

/// 일괄 처리 결과
class BatchResult {
  final List<String> successPaths;
  final List<String> failedPaths;
  final Map<String, String> errors;
  final Duration duration;

  const BatchResult({
    required this.successPaths,
    required this.failedPaths,
    required this.errors,
    required this.duration,
  });

  int get successCount => successPaths.length;
  int get failedCount => failedPaths.length;
  int get totalCount => successCount + failedCount;
  bool get hasErrors => failedCount > 0;
  double get successRate => totalCount == 0 ? 0.0 : successCount / totalCount;
}
