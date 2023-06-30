// Copyright (c) 2015, Anders Holmgren. All rights reserved. Use of this
// source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:pubspec2/pubspec2.dart';

void main() async {
  // specify the directory
  final myDirectory = Directory('myDir');

  // load pubSpec
  final pubSpec = await PubSpec.load(myDirectory);

  // change the dependencies to a single path dependency on project 'foo'
  final newPubSpec =
      pubSpec.copy(dependencies: {'foo': const PathReference('../foo')});

  // save it
  await newPubSpec.save(myDirectory);
}
