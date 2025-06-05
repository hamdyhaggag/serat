class TextScaleModel {
  final double nameScale;
  final double descriptionScale;
  final double detailNameScale;
  final double detailDescriptionScale;

  const TextScaleModel({
    this.nameScale = 1.0,
    this.descriptionScale = 1.0,
    this.detailNameScale = 1.0,
    this.detailDescriptionScale = 1.0,
  });

  factory TextScaleModel.fromScale(double scale) {
    return TextScaleModel(
      nameScale: 28 * scale,
      descriptionScale: 16 * scale,
      detailNameScale: 36 * scale,
      detailDescriptionScale: 18 * scale,
    );
  }

  static const double minScale = 0.8;
  static const double maxScale = 1.4;
  static const int divisions = 6;
}
