// Copyright (c) 2015, Anders Holmgren. All rights reserved.
//Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// ignore: one_member_abstracts
abstract class Jsonable {
  Map<String, Object> toJson();
}

JsonBuilder get buildJson => JsonBuilder();
JsonParser parseJson(Map<String, dynamic>? j, {bool consumeMap = false}) =>
    JsonParser(j, consumeMap);

class JsonBuilder {
  JsonBuilder({bool stringEmpties = true}) : _stringEmpties = stringEmpties;
  final bool _stringEmpties;

  final Map<String, dynamic> json = {};

//  void addObject(String fieldName, o) {
//    if (o != null) {
//      json[fieldName] = o.toJson();
//    }
//  }

  void add(String fieldName, v, [transform(v)?]) {
    if (v != null) {
      final transformed = _transformValue(v, transform);
      if (transformed != null) {
        json[fieldName] = transformed;
      }
    }
  }

  void addAll(Map<String, dynamic> map) {
    json.addAll(map);
  }

  dynamic _transformValue(value, [transform(v)?]) {
    if (transform != null) {
      return transform(value);
    }
    if (value is Jsonable) {
      return value.toJson();
    }
    if (value is Map) {
      final result = {};
      value.forEach((k, v) {
        final transformedValue = _transformValue(v);
        final transformedKey = _transformValue(k);
        if (transformedValue != null && transformedKey != null) {
          result[transformedKey] = transformedValue;
        }
      });
      return result.isNotEmpty || !_stringEmpties ? result : null;
    }
    if (value is Iterable) {
      final list = value.map(_transformValue).toList();
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

typedef Converter<T> = T Function(dynamic value);

Converter<T> _converter<T>(Converter<T>? convert) => convert ?? ((v) => v as T);

class JsonParser {
  JsonParser(Map<String, dynamic>? json, bool consumeMap)
      : _json = consumeMap ? Map.from(json!) : json,
        _consumeMap = consumeMap;
  final Map<String, dynamic>? _json;
  final bool _consumeMap;

  List<T> list<T>(String fieldName, [Converter<T>? create]) {
    final l = _getField(fieldName);
    return l != null ? l.map(_converter(create)).toList(growable: false) : [];
  }

  T? single<T>(String fieldName, [T create(i)?]) {
    final j = _getField(fieldName);
    return j != null ? _converter(create)(j) : null;
  }

  Map<K, V> mapValues<K, V>(String fieldName,
      [Converter<V>? convertValue, Converter<K>? convertKey]) {
    final m = _getField(fieldName);

    if (m == null) {
      return {};
    }

    final _convertKey = _converter(convertKey);
    final _convertValue = _converter(convertValue);

    final result = <K, V>{};
    m.forEach((k, v) {
      result[_convertKey(k)] = _convertValue(v);
    });

    return result;
  }

  Map<K, V> mapEntries<K, V, T>(
      String fieldName, V Function(K k, T v) convert) {
    final m = _getField(fieldName);

    if (m == null) {
      return {};
    }

    final result = <K, V>{};
    m.forEach((k, v) {
      result[k] = convert(k, v);
    });

    return result;
  }

  T? _getField<T>(String fieldName) =>
      (_consumeMap ? _json!.remove(fieldName) : _json![fieldName]);

  Map? get unconsumed {
    if (!_consumeMap) {
      throw StateError('unconsumed called on non consuming parser');
    }

    return _json;
  }
}
