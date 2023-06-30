@Skip('not a real test')
library;

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec2/pubspec2.dart';
import 'package:test/test.dart';

void main() async {
  final pubSpec = PubSpec(name: 'fred', dependencies: {
    'foo': const PathReference('../foo'),
    'fred': HostedReference(VersionRange(min: Version(1, 2, 3)))
  });

  await pubSpec.save(await Directory.systemTemp.createTemp('delme'));
}
