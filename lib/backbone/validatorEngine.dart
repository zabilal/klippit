import 'package:photo_manager/photo_manager.dart';

enum ReportType { POST, COMMENT, REPLY, EVENT }

///for validating the Post type before posting
int validateAssetType(AssetType type) {
  switch (type) {
    case AssetType.other:
      return 0;
    case AssetType.image:
      return 1;
    case AssetType.video:
      return 2;
  }
  return -1;
}

retrieveAssetType(int type) {
  if (type == 0) return AssetType.other;
  if (type == 1) return AssetType.image;
  if (type == 2) return AssetType.video;
}

int validateReport(ReportType type) {
  switch (type) {
    case ReportType.POST:
      // TODO: Handle this case.
      return 0;
      break;
    case ReportType.COMMENT:
      // TODO: Handle this case.
      return 1;
      break;
    case ReportType.REPLY:
      // TODO: Handle this case.
      return 2;
      break;
    case ReportType.EVENT:
      // TODO: Handle this case.
      return 3;
      break;
  }
  return -1;
}
