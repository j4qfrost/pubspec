import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'dependency/dependency.dart';
import 'json_utils.dart';

/// Defines an executable listed in the 'exectuables' section
/// of the pubspec.yaml.
///
/// Once the package is activated using pub global activate
/// each of the executables listed in the pubspec.yaml will
/// be exectuable.
/// The [name] is the name of the executable you run from the cli.
/// The optional [script] is the name of the dart library in the bin
/// directory. If the [script] isn't supplied this defaults to [name];
/// typing <name> executes bin/<script>.dart.

@immutable
class Executable extends Jsonable {
  Executable(this.name, this.script);
  Executable.fromJson(this.name, this.script);
  final String name;
  final String? script;

  /// returns the project relative path to the script.
  ///
  /// e.g.
  /// executables:
  ///   dcli_install: dcli_install
  ///
  /// scriptPath => bin/dcli_install.dart
  ///
  String get scriptPath => join('bin', '${script ?? name}.dart');

  @override
  Json toJson() => {name: script ?? ''};

  @override
  bool operator ==(Object other) =>
      other is Executable && other.script == script;

  @override
  int get hashCode => script.hashCode;
}
