abstract interface class LocalAssistantRepository {
  Future<bool> isEnabled();

  /// Persists the preference. Disabling also unloads the model from memory.
  Future<void> setEnabled({required bool enabled});

  /// Whether the model files are already on the device.
  Future<bool> isModelDownloaded();

  /// Downloads the model if needed and loads it. With [showsNotification],
  /// a download shows its progress in a notification and, on Android, runs
  /// in the foreground so it continues in the background.
  Future<void> prepareModel({
    required void Function(int) onProgress,
    bool showsNotification = false,
  });

  /// Cancels a download or waits for native loading to finish, discards its
  /// result, then deletes everything it wrote.
  Future<void> cancelPreparation();

  /// Unloads the model and deletes its downloaded files.
  Future<void> deleteModel();

  Future<String> answer({
    required String question,
    required String portfolioContext,
  });

  /// Invalidates pending results and clears follow-up context. Native generation
  /// may continue; this does not guarantee cancellation of native work.
  Future<void> resetSession();

  Future<void> dispose();
}
