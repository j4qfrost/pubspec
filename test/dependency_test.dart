import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec2/pubspec2.dart';
import 'package:test/test.dart';

void main() {
  group('external hosted dependency', () {
    test('fromYamlString ( sdk < 2.15 )', () {
      const pubspecString = 'name: my_test_lib\n'
          'version: 0.1.0\n'
          'description: for testing\n'
          'dependencies:\n'
          '    meta: ^1.0.0\n'
          '    self_hosted_lib:\n'
          '        hosted:\n'
          '            name: custom_lib\n'
          '            url: https://pub.mycompany.org\n'
          '        version: ^0.1.0';
      final p = PubSpec.fromYamlString(pubspecString);
      final dep = p.dependencies['self_hosted_lib']!;
      expect(dep, const TypeMatcher<ExternalHostedReference>());

      final exDep = dep as ExternalHostedReference;
      expect(exDep.name, 'custom_lib');
      expect(exDep.url, 'https://pub.mycompany.org');
      expect(exDep.versionConstraint.toString(), '^0.1.0');
    });

    test('fromYamlString ( sdk >= 2.15 )', () {
      const pubspecString = 'name: my_test_lib\n'
          'version: 0.1.0\n'
          'description: for testing\n'
          'dependencies:\n'
          '    meta: ^1.0.0\n'
          '    custom_lib:\n'
          '        hosted: https://pub.mycompany.org\n'
          '        version: ^0.1.0';
      final p = PubSpec.fromYamlString(pubspecString);
      final dep = p.dependencies['custom_lib']!;
      expect(dep, const TypeMatcher<ExternalHostedReference>());

      final exDep = dep as ExternalHostedReference;
      expect(exDep.url, 'https://pub.mycompany.org');
      expect(exDep.versionConstraint.toString(), '^0.1.0');
    });

    test('to json ( sdk >= 2.15 )', () {
      final exDep = ExternalHostedReference(
          'custom_lib',
          'https://pub.mycompany.org',
          VersionConstraint.parse('^0.1.0'),
          false);
      final json = exDep.toJson();
      expect(json['hosted'], 'https://pub.mycompany.org');
      expect(json['version'], '^0.1.0');
    });

    test('to json ( sdk < 2.15 )', () {
      final exDep = ExternalHostedReference('custom_lib',
          'https://pub.mycompany.org', VersionConstraint.parse('^0.1.0'));
      final json = exDep.toJson();
      expect(json['hosted']['url'], 'https://pub.mycompany.org');
      expect(json['hosted']['name'], 'custom_lib');
      expect(json['version'], '^0.1.0');
    });
  });

  /// According to https://www.dartlang.org/tools/pub/dependencies#version-constraints:
  ///
  /// The string any allows any version. This is equivalent to an empty
  /// version constraint, but is more explicit.
  test('dependency without the version constraint is "any" version', () {
    const pubspecString = 'name: my_test_lib\n'
        'version: 0.1.0\n'
        'description: for testing\n'
        'dependencies:\n'
        '    meta:\n';
    final p = PubSpec.fromYamlString(pubspecString);
    final dep = p.dependencies['meta']!;
    expect(dep, const TypeMatcher<HostedReference>());

    final exDep = dep as HostedReference;
    expect(exDep.versionConstraint.toString(), 'any');
  });

  test('sdk dependency', () {
    const pubspecString = 'name: my_test_lib\n'
        'version: 0.1.0\n'
        'description: for testing\n'
        'dependencies:\n'
        '    flutter:\n'
        '        sdk: flutter\n';
    final p = PubSpec.fromYamlString(pubspecString);
    final dep = p.dependencies['flutter']!;
    expect(dep, const TypeMatcher<SdkReference>());

    final sdkDep = dep as SdkReference;
    expect(sdkDep.sdk, 'flutter');
  });

  test('load from file', () async {
    final fromDir = await PubSpec.load(Directory('.'));
    final fromFile = await PubSpec.loadFile('./pubspec.yaml');
    expect(fromFile.toJson(), equals(fromDir.toJson()));
  });

  group('git dependency', () {
    test('fromYamlString', () {
      const pubspecString = 'name: my_test_lib\n'
          'version: 0.1.0\n'
          'description: for testing\n'
          'dependencies:\n'
          '    meta: ^1.0.0\n'
          '    git_lib:\n'
          '        git:\n'
          '            url: git://github.com/foo/bar.git\n'
          '            ref: master\n'
          '            path: packages/batz';
      final pubspec = PubSpec.fromYamlString(pubspecString);

      final dep = pubspec.dependencies['git_lib']!;
      expect(dep, const TypeMatcher<GitReference>());

      final gitDep = dep as GitReference;
      expect(gitDep.url, 'git://github.com/foo/bar.git');
      expect(gitDep.ref, 'master');
      expect(gitDep.path, 'packages/batz');
    });

    test('toJson url', () {
      const subject = GitReference('git://github.com/foo/bar.git');

      final jsonObj = subject.toJson();

      expect(jsonObj['git'], 'git://github.com/foo/bar.git');
    });

    test('toJson url, ref', () {
      const subject = GitReference('git://github.com/foo/bar.git', 'master');

      final jsonObj = subject.toJson();

      expect(jsonObj['git']['url'], 'git://github.com/foo/bar.git');
      expect(jsonObj['git']['ref'], 'master');
    });

    test('toJson url, ref, path', () {
      const subject = GitReference(
        'git://github.com/foo/bar.git',
        'master',
        'packages/batz',
      );

      final jsonObj = subject.toJson();

      expect(jsonObj['git']['url'], 'git://github.com/foo/bar.git');
      expect(jsonObj['git']['ref'], 'master');
      expect(jsonObj['git']['path'], 'packages/batz');
    });
  });

  test('fromYamlString ( odd order )', () {
    const pubspecString = 'name: my_test_lib\n'
        'version: 0.1.0\n'
        'description: for testing\n'
        'dependencies:\n'
        '    meta: ^1.0.0\n'
        '    self_hosted_lib:\n'
        '        version: ^0.1.0\n'
        '        hosted:\n'
        '            name: custom_lib\n'
        '            url: https://pub.mycompany.org\n';
    final p = PubSpec.fromYamlString(pubspecString);
    final dep = p.dependencies['self_hosted_lib']!;
    expect(dep, const TypeMatcher<ExternalHostedReference>());

    final exDep = dep as ExternalHostedReference;
    expect(exDep.name, 'custom_lib');
    expect(exDep.url, 'https://pub.mycompany.org');
    expect(exDep.versionConstraint.toString(), '^0.1.0');
  });
}
