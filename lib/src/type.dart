typedef Transform = Object Function(Object v);
typedef Create<T, V> = T Function(V value);
typedef Converter<T, V> = T Function(V value);
Converter<T, V> converter<T, V>(Converter<T, V>? convert) =>
    convert ?? ((v) => v as T);
