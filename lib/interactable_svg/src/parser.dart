import 'package:flutter/services.dart' show rootBundle;
import 'package:interactable_svg/interactable_svg/src/utils/utils.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:uuid/uuid.dart';

import './size_controller.dart';
import './constant.dart';
import './models/region.dart';

class Parser {
  static Parser? _instance;

  static Parser get instance {
    _instance ??= Parser._init();
    return _instance!;
  }

  final sizeController = SizeController.instance;

  Parser._init();

  Future<List<Region>> svgToRegionList(String svgAddress) async {
    final svgMain = await rootBundle.loadString(svgAddress);

    List<Region> regionList = [];

    // final regExp = RegExp(Constants.mapRegexp,
    //     multiLine: true, caseSensitive: false, dotAll: false);

    RegExp expPath = RegExp(r'<path\s+id="([^"]+)"?.*?(name="([^"]*)")?.*?d="([^"]+)?"');

    Iterable<Match> matchesPath = expPath.allMatches(svgMain);
    for (Match match in matchesPath) {
      final path = match.group(4);
      if (path != null) {
        final element = Region(
            id: match.group(1) ?? const Uuid().v4(),
            name: match.group(2) ?? '',
            path: parseSvgPath(
              path,
            ));
        sizeController.addBounds(element.path.getBounds());
        regionList.add(element);
      }
    }

    return regionList;
  }

  Future<List<Region>> svgToRegionListString(String svgAddress) async {
    final svgMain = svgAddress;

    List<Region> regionList = [];

    final regExp = RegExp(Constants.mapRegexp, multiLine: true, caseSensitive: false, dotAll: false);

    regExp.allMatches(svgMain).forEach((regionData) {
      final region =
          Region(id: regionData.group(1)!, name: regionData.group(2)!, path: parseSvgPath(regionData.group(3)!));

      sizeController.addBounds(region.path.getBounds());
      regionList.add(region);
    });
    return regionList;
  }

  Future<List<Region>> svgToRegionListNetwork(String svgAddress, String fileName) async {
    var temp = await httpGet(svgAddress, fileName);

    final String svgMain = temp.body;

    List<Region> regionList = [];

    final regExp = RegExp(Constants.mapRegexp, multiLine: true, caseSensitive: false, dotAll: false);

    regExp.allMatches(svgMain).forEach((regionData) {
      final region =
          Region(id: regionData.group(1)!, name: regionData.group(2)!, path: parseSvgPath(regionData.group(3)!));

      sizeController.addBounds(region.path.getBounds());
      regionList.add(region);
    });
    return regionList;
  }
}
