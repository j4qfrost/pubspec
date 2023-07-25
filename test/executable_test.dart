import 'package:path/path.dart' hide equals;
import 'package:pubspec2/pubspec2.dart';
import 'package:test/test.dart';

void main() {
  test('executables ', () {
    const pubspecString = '''
name: my_test_lib
version: 0.1.0
description: for testing
dependencies:
  meta: ^1.0.0

executables:
  simple:
  explicit: explicit
  different: explicit
''';
    final p = PubSpec.fromYamlString(pubspecString);

    expect(p.executables.keys,
        unorderedEquals(['simple', 'explicit', 'different']));

    var exec = p.executables['simple']!;
    expect(exec, const TypeMatcher<Executable>());
    expect(exec.name, equals('simple'));
    expect(exec.script, isNull);
    expect(exec.scriptPath, join('bin', 'simple.dart'));

    exec = p.executables['explicit']!;
    expect(exec, const TypeMatcher<Executable>());
    expect(exec.name, equals('explicit'));
    expect(exec.script, 'explicit');
    expect(exec.scriptPath, join('bin', 'explicit.dart'));

    exec = p.executables['different']!;
    expect(exec, const TypeMatcher<Executable>());
    expect(exec.name, equals('different'));
    expect(exec.script, 'explicit');
    expect(exec.scriptPath, join('bin', 'explicit.dart'));
  });
}
