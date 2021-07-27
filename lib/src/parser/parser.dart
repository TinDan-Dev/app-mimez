import '../types.dart';
import 'impl.dart';

abstract class Parser {
  const Parser();

  MimeType get type;

  bool validFromBinary(List<int> fileData);

  bool validFromExtension(String extension);
}

const _parser = <Parser>[
  PNGParser(),
  JPEGParser(),
  GIFParser(),
  HEIFParser(),
];

MimeType? determineMimeType(List<int> fileData, {MimeType? fallback}) {
  for (final parser in _parser) {
    if (parser.validFromBinary(fileData)) return parser.type;
  }

  return fallback;
}

MimeType? determineMimeTypeFromExtension(String extension, {MimeType? fallback}) {
  if (extension.length < 2) return fallback;
  final parsedExtension = extension.startsWith('.') ? extension.substring(1) : extension;

  for (final parser in _parser) {
    if (parser.validFromExtension(parsedExtension)) return parser.type;
  }

  return fallback;
}
