abstract interface class AssistantRepository {
  Future<bool> isEnabled();

  /// Persists the preference. Disabling also unloads the model from memory.
  Future<void> setEnabled({required bool enabled});

  /// Whether the model files are already on the device.
  Future<bool> isModelDownloaded();

  Future<void> prepareModel({required void Function(int) onProgress});

  /// Stops an in-flight download or load, then deletes everything it wrote.
  Future<void> cancelPreparation();

  /// Unloads the model and deletes its downloaded files.
  Future<void> deleteModel();

  Future<String> answer({
    required String question,
    required String portfolioContext,
  });

  Future<void> dispose();
}
