import 'dart:typed_data';

import '../types.dart';
import 'parser.dart';

bool _compareMagicNumber(List<int> fileData, List<int> magicNumber) {
  if (fileData.length < magicNumber.length) return false;

  for (int i = 0; i < magicNumber.length; i++) {
    if (fileData[i] != magicNumber[i]) return false;
  }

  return true;
}

bool _compareMagicNumbers(List<int> fileData, List<List<int>> magicNumbers) {
  for (final magicNumber in magicNumbers) {
    if (_compareMagicNumber(fileData, magicNumber)) return true;
  }

  return false;
}

class PNGParser extends Parser {
  const PNGParser();

  static const _extension = 'png';
  static const _magicNumber = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

  @override
  MimeType get type => MimeType.png;

  @override
  bool validFromBinary(List<int> fileData) => _compareMagicNumber(fileData, _magicNumber);

  @override
  bool validFromExtension(String extension) => extension == _extension;
}

class JPEGParser extends Parser {
  const JPEGParser();

  static const _extensions = ['jpg', 'jpeg', 'jpe', 'jif', 'jfif', 'jfi'];
  static const _magicNumber = [0xFF, 0xD8, 0xFF];

  @override
  MimeType get type => MimeType.jpeg;

  @override
  bool validFromBinary(List<int> fileData) => _compareMagicNumber(fileData, _magicNumber);

  @override
  bool validFromExtension(String extension) => _extensions.contains(extension);
}

class GIFParser extends Parser {
  const GIFParser();

  static const _extension = 'gif';
  static const _magicNumbers = [
    [0x47, 0x49, 0x46, 0x38, 0x37, 0x61],
    [0x47, 0x49, 0x46, 0x38, 0x39, 0x61],
  ];

  @override
  MimeType get type => MimeType.gif;

  @override
  bool validFromBinary(List<int> fileData) => _compareMagicNumbers(fileData, _magicNumbers);

  @override
  bool validFromExtension(String extension) => extension == _extension;
}

class HEIFParser extends Parser {
  const HEIFParser();

  static const _extensions = ['heif', 'heifs', 'heic', 'heics'];

  // Ftyp box: {
  //  unsigned int(32) size;
  //  unsigned int(32) type = 'ftyp';
  //  unsigned int(32) major_brand;
  //  unsigned int(32) minor_version;
  //  unsigned int(32) compatible_brands[]; -> to end of the box
  // }

  static const _ftyp = 0x66747970;
  static const _validBrands = [
    0x68656963, // heic
    0x6865696D, // heim
    0x68656973, // heis
    0x68656978, // heix
    0x68657663, // hevc
    0x6865766D, // hevm
    0x68657673, // hevs
    0x6D696631, // mif1
  ];

  @override
  MimeType get type => MimeType.heif;

  @override
  bool validFromBinary(List<int> fileData) {
    // not enough space for the ftyp box
    if (fileData.length < 16) return false;

    final blob = ByteData.sublistView(Uint8List.fromList(fileData));
    final size = blob.getUint32(0);

    // sanity check the size
    if (size < 16 || size > 128 || size > fileData.length) return false;

    // check the _ftyp value
    if (blob.getUint32(4) != _ftyp) return false;

    // check the major_brand
    if (_validBrands.contains(blob.getUint32(8))) return true;

    // check the compatible_brands
    for (int i = 12; i < size; i += 4) if (_validBrands.contains(blob.getUint32(i))) return true;

    return false;
  }

  @override
  bool validFromExtension(String extension) => _extensions.contains(extension);
}
