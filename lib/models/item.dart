/// The kind of a reviewable item. Open taxonomy: today {word, letter}; future
/// types (verb, color, place, character…) extend the enum, and every
/// `switch (item.type)` will be flagged by the analyzer to handle them.
enum ItemType { word, letter }

/// A reviewable unit the SRS tracks and activities quiz. `Word` and `Letter`
/// implement this; they keep their own distinct fields.
abstract interface class Item {
  String get id;
  ItemType get type;
}

/// Stable key used for SRS maps and correctness tracking: "word:word_aav".
String itemKeyOf(ItemType type, String id) => '${type.name}:$id';

/// Parse a "type:id" key (from [itemKeyOf]) back into its parts.
({ItemType type, String id}) itemRefFromKey(String key) {
  final i = key.indexOf(':');
  return (
    type: ItemType.values.byName(key.substring(0, i)),
    id: key.substring(i + 1),
  );
}

extension ItemKey on Item {
  String get key => itemKeyOf(type, id);
}
