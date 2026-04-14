enum Status {
  initGame,
  matched,
  move,
  resign,
  drawOffer,
  drawAccept,
  drawDecline,
  error;

  static Status fromName(String name) {
    final normalized = name.trim().toUpperCase().replaceAll('_', '');
    return Status.values.firstWhere(
      (status) => status.name.toUpperCase() == normalized,
      orElse: () => Status.error,
    );
  }
}