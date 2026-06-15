import 'package:bambaruush/models/constellation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips all fields through JSON', () {
    const c = Constellation(
      id: 'doloon_burhan',
      nameEn: 'The Big Dipper',
      nameMn: 'Долоон бурхан',
      order: 1,
      slots: [Offset(0.2, 0.3), Offset(0.7, 0.4)],
      shapeImage: 'assets/images/ladle.png',
      trivia: 'It looks like a ladle.',
    );
    final back = Constellation.fromJson(c.toJson());
    expect(back.id, 'doloon_burhan');
    expect(back.order, 1);
    expect(back.nameEn, 'The Big Dipper');
    expect(back.nameMn, 'Долоон бурхан');
    expect(back.slots, hasLength(2));
    expect(back.slots.first, const Offset(0.2, 0.3));
    expect(back.shapeImage, 'assets/images/ladle.png');
    expect(back.trivia, 'It looks like a ladle.');
  });
}
