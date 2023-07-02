// Copyright (c) 2015, Anders Holmgren. All rights reserved.
//Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dependency.dart';
import 'type.dart';

// ignore: one_member_abstracts
abstract class Jsonable {
  Json toJson();
}

JsonBuilder get buildJson => JsonBuilder();
JsonParser parseJson(Map<String, dynamic>? j, {bool consumeMap = false}) =>
    JsonParser(j, consumeMap: consumeMap);

class JsonBuilder {
  JsonBuilder({bool stringEmpties = true}) : _stringEmpties = stringEmpties;
  final bool _stringEmpties;

  final Map<String, dynamic> json = {};

//  void addObject(String fieldName, o) {
//    if (o != null) {
//      json[fieldName] = o.toJson();
//    }
//  }

  void add(String fieldName, Object? v, [Transform? transform]) {
    if (v != null) {
      final transformed = _transformValue(v, transform);
      json[fieldName] = transformed;
    }
  }

  void addAll(Map<String, dynamic> map) {
    json.addAll(map);
  }

  Object? _transformValue(Object value, [Transform? transform]) {
    if (transform != null) {
      return transform(value);
    }
    if (value is Jsonable) {
      return value.toJson();
    }
    if (value is Map) {
      final result = <String, Object?>{};
      value.forEach((k, v) {
        final transformedValue = _transformValue(v as Object);
        final transformedKey = _transformValue(k as String) as String?;
        result[transformedKey!] = transformedValue;
      });
      return result.isNotEmpty || !_stringEmpties ? result : null;
    }
    if (value is Iterable) {
      final list = value.map((v) => _transformValue(v as Object)).toList();
      return list.isNotEmpty || !_stringEmpties ? list : null;
    }
    if (value is RegExp) {
      return value.pattern;
    }
    // if (value is UriTemplate) {
    //   return value.template;
    // }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is bool || value is num) {
      return value;
    }
    return value.toString();
  }
}

class JsonParser {
  JsonParser(Map<String, dynamic>? json, {required bool consumeMap})
      : _json = consumeMap ? Map.from(json!) : json,
        _consumeMap = consumeMap;
  final Json? _json;
  final bool _consumeMap;

  List<T> list<T>(String fieldName, [Converter<T, List<T>>? create]) {
    final l = _getField(fieldName) as List?;
    return l != null
        ? l.map((v) => converter(create)).toList(growable: false) as List<T>
        : <T>[];
  }

  T? single<T, V>(String fieldName, [Create<T, V>? create]) {
    final j = _getField(fieldName) as V?;
    return j != null ? converter<T, V>(create)(j) : null;
  }

  Map<String, DependencyReference> getReferences(String fieldName) {
    final dependencies = _getField(fieldName) as Json?;

    if (dependencies == null) {
      return {};
    }

    final map = <String, DependencyReference>{};
    for (final key in dependencies.keys) {
      final reference = DependencyReference.fromJson(dependencies[key]);
      map.putIfAbsent(key, () => reference);
    }
    return map;
  }

  Map<K, DependencyReference> mapValues<K>(String fieldName,
      [Converter<K, DependencyReference>? convertValue,
      Converter<K, DependencyReference>? convertKey]) {
    final m = _getField(fieldName) as Map<K, DependencyReference>?;

    if (m == null) {
      return {};
    }

    final _convertKey = converter(convertKey);
    final _convertValue = converter(convertValue);

    final result = <K, DependencyReference>{};
    m.forEach((k, v) {
      result[_convertKey(k as DependencyReference)] =
          _convertValue(v) as DependencyReference;
    });

    return result;
  }

  Map<K, V> mapEntries<K, V, T>(
      String fieldName, V Function(K k, T v) convert) {
    final m = _getField(fieldName) as Map<K, V>?;

    if (m == null) {
      return {};
    }

    final result = <K, V>{};
    m.forEach((k, v) {
      result[k] = convert(k, v as T);
    });

    return result;
  }

  T? _getField<T>(String fieldName) =>
      (_consumeMap ? _json!.remove(fieldName) : _json![fieldName]) as T?;

  Json? get unconsumed {
    if (!_consumeMap) {
      throw StateError('unconsumed called on non consuming parser');
    }

    return _json;
  }
}
