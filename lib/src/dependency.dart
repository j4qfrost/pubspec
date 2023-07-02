// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:quiver/core.dart';

import 'json_utils.dart';

typedef Json = Map<String, Object?>;

abstract class DependencyReference implements Jsonable {
  const DependencyReference();

  factory DependencyReference.fromJson(Object? json) {
    if (json is Json) {
      final type = getKnownType(json.keys);
      switch (type) {
        case 'path':
          return PathReference.fromJson(json);
        case 'git':
          return GitReference.fromJson(json);
        case 'hosted':
          return ExternalHostedReference.fromJson(json);
        case 'sdk':
          return SdkReference.fromJson(json);
        default:
          throw StateError('unexpected dependency type ${json.keys.first}');
      }
    } else if (json is String) {
      return HostedReference.fromJson(json);
    } else if (json == null) {
      return HostedReference(VersionConstraint.any);
    } else {
      throw StateError('Unable to parse dependency $json');
    }
  }

  @override
  String toString() => json.encode(this);
}

/// The dependency type by convention is the first key
/// however there is no require that it is the first
/// so we need to search the map of keys to see if
/// a know type exits.
String getKnownType(Iterable<String> keys) {
  if (keys.contains('path')) {
    return 'path';
  }
  if (keys.contains('git')) {
    return 'git';
  }
  if (keys.contains('hosted')) {
    return 'hosted';
  }
  if (keys.contains('sdk')) {
    return 'sdk';
  }

  return '';
}

@immutable
class GitReference extends DependencyReference {
  const GitReference(this.url, [this.ref, this.path]);

  factory GitReference.fromJson(Json json) {
    final git = json['git'];
    if (git is String) {
      return GitReference(git);
    } else if (git is Map) {
      final m = git;
      return GitReference(
          m['url'] as String, m['ref'] as String, m['path'] as String);
    } else {
      throw StateError('Unexpected format for git dependency $git');
    }
  }
  final String url;
  final String? ref;
  final String? path;

  @override
  Json toJson() {
    if (ref == null && path == null) {
      return {'git': url};
    }

    final arguments = {'url': url};

    if (ref != null) {
      arguments['ref'] = ref!;
    }
    if (path != null) {
      arguments['path'] = path!;
    }

    return {'git': arguments};
  }

  @override
  bool operator ==(Object other) =>
      other is GitReference && other.url == url && other.ref == ref;

  @override
  int get hashCode => ref.hashCode;
}

@immutable
class PathReference extends DependencyReference {
  const PathReference(this.path);

  PathReference.fromJson(Json json) : this(json['path'] as String?);
  final String? path;

  @override
  Json toJson() => {'path': path ?? ''};

  @override
  bool operator ==(Object other) =>
      other is PathReference && other.path == path;

  @override
  int get hashCode => path.hashCode;
}

@immutable
class HostedReference extends DependencyReference {
  const HostedReference(this.versionConstraint);

  HostedReference.fromJson(String json) : this(VersionConstraint.parse(json));
  final VersionConstraint versionConstraint;

  @override
  Json toJson() => {'version': versionConstraint.toString()};

  @override
  bool operator ==(Object other) =>
      other is HostedReference && other.versionConstraint == versionConstraint;

  @override
  int get hashCode => versionConstraint.hashCode;
}

@immutable
class ExternalHostedReference extends DependencyReference {
  const ExternalHostedReference(this.name, this.url, this.versionConstraint,
      {this.verboseFormat = true});

  ExternalHostedReference.fromJson(Json json)
      : this(
            json['hosted'] is String
                ? null
                : (json['hosted']! as Json?)!['name'] as String?,
            json['hosted'] is String
                ? json['hosted'] as String?
                : (json['hosted'] as Json?)!['url'] as String?,
            VersionConstraint.parse((json['version'] as String?)!),
            verboseFormat: json['hosted']! is String);
  final String? name;
  final String? url;
  final VersionConstraint versionConstraint;
  final bool verboseFormat;

  @override
  bool operator ==(Object other) =>
      other is ExternalHostedReference &&
      other.name == name &&
      other.url == url &&
      other.versionConstraint == versionConstraint;

  @override
  int get hashCode =>
      hash3(name.hashCode, url.hashCode, versionConstraint.hashCode);

  @override
  Json toJson() {
    if (verboseFormat) {
      return {
        'hosted': {'name': name, 'url': url},
        'version': versionConstraint.toString()
      };
    } else {
      return {'hosted': url, 'version': versionConstraint.toString()};
    }
  }
}

@immutable
class SdkReference extends DependencyReference {
  const SdkReference(this.sdk);

  SdkReference.fromJson(Json json) : this(json['sdk'] as String?);
  final String? sdk;

  @override
  bool operator ==(Object other) => other is SdkReference && other.sdk == sdk;

  @override
  Map<String, String?> toJson() => {'sdk': sdk};

  @override
  int get hashCode => sdk.hashCode;
}
