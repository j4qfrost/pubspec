import 'package:meta/meta.dart';

import 'json_utils.dart';

/// Defines an platform listed in the 'platforms' section
/// of the pubspec.yaml.
///
/// The [name] is the name of the platform that you package
/// supports.
@immutable
class Platform extends Jsonable {
  Platform(this.name);
  Platform.fromJson(this.name);
  final String name;

  @override
  Map<String, Object> toJson() => <String, Object>{};

  @override
  bool operator ==(Object other) => other is Platform && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
