// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';

@immutable
class HostedReference extends DependencyReference {
  const HostedReference(this.versionConstraint);

  HostedReference.fromJson(String json) : this(VersionConstraint.parse(json));
  final VersionConstraint versionConstraint;

  @override
  String toJson() => versionConstraint.toString();

  @override
  bool operator ==(Object other) =>
      other is HostedReference && other.versionConstraint == versionConstraint;

  @override
  int get hashCode => versionConstraint.hashCode;
}
