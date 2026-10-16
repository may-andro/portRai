abstract final class AiImagePrompts {
  static const _likeness =
      'Likeness: this must be instantly recognisable as the same person, as '
      'if the photo itself were traced and re-inked in the art style. '
      'Keep the exact pose: the same head tilt and head direction, the same '
      'three-quarter or frontal angle, the same shoulder position and the '
      'same smile and expression as the photo; do not turn the head to face '
      'the camera. Keep the exact hair: the same shape, parting, volume, '
      'length, direction and colour, with no curls or spikes added. Keep '
      'the exact skin tone as in the photo (do not darken or lighten it), '
      'the same facial hair, face shape, eyebrows, eye shape, nose and '
      'jawline. ';

  static const _framing =
      'Composition: use the same framing and crop as the photo, head and '
      'shoulders, centred, with the shoulders reaching the left, right and '
      'bottom edges of the frame and a little space above the hair. Square '
      '1:1 image. '
      'Background: plain solid pure white (#FFFFFF) filling every pixel outside '
      'the character, with no shadows, gradients, patterns, ground or objects, '
      'because it is removed afterwards to make the image transparent. Do not '
      'use white or near-white for the outer edge of the clothes or hair; '
      'keep the dark outline closed around the whole character. '
      'Do not include any text, letters, logos, watermarks, frames or '
      'borders.';

  /// Turns a portrait photo into the portfolio's hand-drawn anime avatar.
  static const avatar =
      'Redraw the person in the supplied photo as a hand-drawn anime-style '
      'character illustration, in a cel-shaded 2D animation look similar to '
      'a Studio Ghibli character portrait. '
      'Style: clean, confident dark outlines of uniform weight; flat colour '
      'fills with simple soft cel shading and no gradients, textures or '
      'photographic detail. '
      '$_likeness'
      'Draw large, round, expressive anime eyes with a small white '
      'highlight, simple defined eyebrows and a simple nose line. '
      'Clothing: keep the same clothes and colours as the photo, drawn with '
      'flat colours, visible seams, collar folds and buttons. '
      '$_framing';

  /// Redraws the photo as a dark, gritty Attack on Titan character.
  static const attackOnTitan =
      'Redraw the person in the supplied photo as a character from the anime '
      'Attack on Titan (Shingeki no Kyojin), in the Wit Studio / MAPPA '
      'style. '
      'Style: sharp, slightly rough dark linework, muted desaturated earthy '
      'colours, hard cel shading with strong shadows, realistic proportions '
      'and a serious, intense, determined expression. '
      '$_likeness'
      'Clothing: replace the clothes with a Survey Corps outfit: brown '
      'leather jacket with the white-and-blue Wings of Freedom emblem, '
      'white shirt with a cravat, and the crossed leather harness straps. '
      '$_framing';

  /// Redraws the photo as a Naruto-style shinobi.
  static const naruto =
      'Redraw the person in the supplied photo as a ninja character from the '
      "anime Naruto, in Masashi Kishimoto's style. "
      'Style: bold black outlines, flat cel shading and the clean, '
      'expressive Naruto line art. '
      '$_likeness'
      'Clothing: only the clothes change. Replace them with a shinobi '
      'outfit: an orange and dark-blue zip-up jacket with a high collar, '
      'and a forehead protector with a metal plate engraved with a '
      'swirl-leaf symbol worn around the neck (not on the forehead, so the '
      'hair stays fully visible and unchanged). '
      '$_framing';

  /// Redraws the photo as a black-and-white manga panel character.
  static const manga =
      'Redraw the person in the supplied photo as a Japanese manga '
      'character in a classic black-and-white print style. '
      'Style: crisp black ink linework with varied line weight, screentone '
      'dot shading and cross-hatching, high contrast, no colour at all '
      '(only black, white and grey tones), large expressive eyes with '
      'detailed highlights and dramatic stylised hair. '
      '$_likeness'
      'Clothing: keep the same clothes as the photo, drawn in inked '
      'black-and-white with screentone fills. '
      '$_framing';
}
