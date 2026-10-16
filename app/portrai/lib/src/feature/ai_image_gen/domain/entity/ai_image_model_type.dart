enum AiImageModelType {
  geminiFlashImage('Gemini 2.5 Flash Image', 'gemini-2.5-flash-image'),
  geminiProImage('Gemini 3 Pro Image (preview)', 'gemini-3-pro-image-preview');

  const AiImageModelType(this.label, this.id);

  final String label;
  final String id;
}
