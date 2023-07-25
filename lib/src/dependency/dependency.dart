// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:pub_semver/pub_semver.dart';

import '../json_utils.dart';
import 'external_hosted_reference.dart';
import 'git_reference.dart';
import 'hosted_reference.dart';
import 'path_reference.dart';
import 'sdk_reference.dart';

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
