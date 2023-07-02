// Copyright (c) 2015, Anders Holmgren. All rights reserved.
// Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' hide Platform;

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'dependency.dart';
import 'executable.dart';
import 'json_utils.dart';
import 'platform.dart';
import 'yaml_to_string.dart';
import 'yaml_util.dart';

/// Represents a [pubspec](https://www.dartlang.org/tools/pub/pubspec.html).
///
/// Example Usage:
///
///
///     // load it
///     var pubSpec = await PubSpec.load(myDirectory);
///
///     // change the dependencies to a single path dependency on project 'foo'
///     var PubSpec = pubSpec.copy(dependencies: { 'foo': PathReference('../foo') });
///
///     // save it
///     await PubSpec.save(myDirectory);
///
///
class PubSpec implements Jsonable {
  const PubSpec(
      {this.name,
      this.author,
      this.version,
      this.homepage,
      this.documentation,
      this.description,
      this.publishTo,
      this.environment,
      this.dependencies = const {},
      this.devDependencies = const {},
      this.dependencyOverrides = const {},
      this.executables = const {},
      this.platforms = const {},
      this.unParsedYaml = const {}});

  factory PubSpec.fromYaml(YamlMap yamlMap) {
    final p = parseYaml(yamlMap, consumeMap: true);

    return PubSpec(
        name: p.single('name') as String?,
        author: p.single('author') as String?,
        version: p.single('version', Version.parse),
        homepage: p.single('homepage') as String?,
        documentation: p.single('documentation') as String?,
        description: p.single('description') as String?,
        publishTo: p.single('publish_to', Uri.parse),
        environment: p.single('environment', Environment.fromJson),
        dependencies: p.getReferences('dependencies'),
        devDependencies: p.getReferences('dev_dependencies'),
        dependencyOverrides: p.getReferences('dependency_overrides'),
        executables: p.getPairs<Executable>('executables', Executable.fromJson),
        platforms:
            p.getPairs<Platform>('platforms', (k, v) => Platform.fromJson(k)),
        unParsedYaml: p.unconsumed);
  }

  factory PubSpec.fromYamlString(String yamlString) =>
      PubSpec.fromYaml(loadYaml(yamlString) as YamlMap);
  final String? name;

  final String? author;

  final Version? version;

  final String? homepage;

  final String? documentation;

  final String? description;

  final Uri? publishTo;

  final Environment? environment;

  final Map<String, DependencyReference> dependencies;

  final Map<String, DependencyReference> devDependencies;

  /// [dependencies] and [devDependencies] combined.
  /// Does not include [dependencyOverrides]
  Map<String, DependencyReference> get allDependencies {
    final all = <String, DependencyReference>{};

    dependencies.forEach((k, v) {
      all[k] = v;
    });

    devDependencies.forEach((k, v) {
      all[k] = v;
    });

    return all;
  }

  final Map<String, DependencyReference> dependencyOverrides;

  final Map<String, Executable> executables;

  final Map<String, Platform> platforms;

  final Json? unParsedYaml;

  /// loads the pubspec from the [projectDirectory]
  static Future<PubSpec> load(Directory projectDirectory) =>
      loadFile(p.join(projectDirectory.path, 'pubspec.yaml'));

  /// loads the pubspec from the [file]
  static Future<PubSpec> loadFile(String file) async =>
      PubSpec.fromYaml(loadYaml(await File(file).readAsString()) as YamlMap);

  /// creates a copy of the pubspec with the changes provided
  PubSpec copy({
    String? name,
    String? author,
    Version? version,
    String? homepage,
    String? documentation,
    String? description,
    Uri? publishTo,
    Environment? environment,
    Map<String, DependencyReference>? dependencies,
    Map<String, DependencyReference>? devDependencies,
    Map<String, DependencyReference>? dependencyOverrides,
    Map<String, Executable>? executables,
    Map<String, Platform>? platforms,
    Json? unParsedYaml,
  }) =>
      PubSpec(
          name: name ?? this.name,
          author: author ?? this.author,
          version: version ?? this.version,
          homepage: homepage ?? this.homepage,
          documentation: documentation ?? this.documentation,
          description: description ?? this.description,
          publishTo: publishTo ?? this.publishTo,
          environment: environment ?? this.environment,
          dependencies: dependencies ?? this.dependencies,
          devDependencies: devDependencies ?? this.devDependencies,
          dependencyOverrides: dependencyOverrides ?? this.dependencyOverrides,
          executables: executables ?? this.executables,
          platforms: platforms ?? this.platforms,
          unParsedYaml: unParsedYaml ?? this.unParsedYaml);

  /// saves the pubspec to the [projectDirectory]
  Future<dynamic> save(Directory projectDirectory) async {
    final ioSink =
        File(p.join(projectDirectory.path, 'pubspec.yaml')).openWrite();
    try {
      const YamlToString().writeYamlString(toJson(), ioSink);
    } finally {
      await ioSink.flush();
      await ioSink.close();
    }
  }

  /// Converts to a Map that can be serialised to Yaml or Json
  @override
  Json toJson() => (buildJson
        ..add('name', name)
        ..add('author', author)
        ..add('version', version)
        ..add('homepage', homepage)
        ..add('documentation', documentation)
        ..add('publish_to', publishTo)
        ..add('environment', environment)
        ..add('description', description)
        ..add('dependencies', dependencies)
        ..add('dev_dependencies', devDependencies)
        ..add('dependency_overrides', dependencyOverrides)
        ..add('executables', executables)
        ..add('platforms', platforms)
        ..addAll(unParsedYaml!))
      .json;
}

class Environment implements Jsonable {
  const Environment(this.sdkConstraint, this.unParsedYaml);

  factory Environment.fromJson(Json json) {
    final p = parseJson(json, consumeMap: true);
    return Environment(p.single('sdk', VersionConstraint.parse), p.unconsumed);
  }
  final VersionConstraint? sdkConstraint;
  final Json? unParsedYaml;

  @override
  Json toJson() => (buildJson
        ..add('sdk', '$sdkConstraint')
        ..addAll(unParsedYaml!))
      .json;
}
