// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'dependency.dart';

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
