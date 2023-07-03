// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';

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
  int get hashCode => Object.hash(name, url, versionConstraint.hashCode);

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
