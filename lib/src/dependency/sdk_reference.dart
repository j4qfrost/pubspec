// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'dependency.dart';

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
