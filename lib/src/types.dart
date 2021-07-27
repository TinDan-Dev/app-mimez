enum MimeType {
  gif,
  jpeg,
  png,
  heif,
}

extension MimeTypeToString on MimeType {
  String toMimeTypeString() {
    switch (this) {
      case MimeType.gif:
        return 'image/gif';
      case MimeType.jpeg:
        return 'image/jpeg';
      case MimeType.png:
        return 'image/png';
      case MimeType.heif:
        return 'image/heif';
    }
  }
}
