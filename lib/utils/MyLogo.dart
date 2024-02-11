import 'package:flutter/material.dart';
import 'package:flutter_any_logo/gen/assets.gen.dart';

class MyLogo {
  static const $AssetsCflGen cfl = $AssetsCflGen();

  /// This values variable can be accessed to display all logos
  /// available in the plugin package.
  static List<Widget> values = <Widget>[
    ...MyLogo.cfl.values.map((AssetGenImage e) => e.image()).toList(),
  ];
}

class $AssetsCflGen {
  const $AssetsCflGen();

  AssetGenImage get cflBCLions =>                 const AssetGenImage('assets/cfl/cfl-bc-lions.png');
  AssetGenImage get cflCalgaryStampeders =>       const AssetGenImage('assets/cfl/cfl-calgary-stampeders.png');
  AssetGenImage get cflEdmontonEsks =>            const AssetGenImage('assets/cfl/cfl-edmonton-elks.png');
  AssetGenImage get cflhamiltontigercats =>       const AssetGenImage('assets/cfl/cfl-hamilton-tiger-cats.png');
  AssetGenImage get cflmontrealalouettes =>       const AssetGenImage('assets/cfl/cfl-montreal-alouettes.png');
  AssetGenImage get cflottawaredblacks =>         const AssetGenImage('assets/cfl/cfl-ottawa-redblacks.png');
  AssetGenImage get cflsaskatchewanroughriders => const AssetGenImage('assets/cfl/cfl-saskatchewan-roughriders.png');
  AssetGenImage get cfltorontoargonauts =>        const AssetGenImage('assets/cfl/cfl-toronto-argonauts.png');
  AssetGenImage get cflwinnepegbluebombers =>     const AssetGenImage('assets/cfl/cfl-winnepeg-blue-bombers.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    cflBCLions,
    cflCalgaryStampeders,
    cflEdmontonEsks,
    cflhamiltontigercats,
    cflmontrealalouettes,
    cflottawaredblacks,
    cflsaskatchewanroughriders,
    cfltorontoargonauts,
    cflwinnepegbluebombers,
  ];
}
