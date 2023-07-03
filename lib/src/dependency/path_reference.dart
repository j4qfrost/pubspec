// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'dependency.dart';

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
