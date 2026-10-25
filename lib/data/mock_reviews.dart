import 'models/review_model.dart';

/// Seed owner reviews standing in for the reviews backend.
///
/// Two per product, deliberately mixed: one owner who is happy and one with
/// a real caveat, so the page reads like a decision aid rather than a pitch.
abstract final class MockReviews {
  static List<Review> forProduct(String productId) => _all[productId] ?? [];

  static Review _r(
    String author,
    int rating,
    String ownedFor,
    DateTime date,
    String body, {
    String? title,
  }) => Review(
    author: author,
    rating: rating,
    title: title,
    body: body,
    ownedFor: ownedFor,
    date: date,
  );

  static final Map<String, List<Review>> _all = {
    'bp_atlas': [
      _r(
        'Ananya R.',
        5,
        '8 months',
        DateTime(2026, 9, 14),
        'Carries a 15" laptop, lunch and a jacket on a packed local train '
            'without pulling at my shoulders. The load-lifters genuinely help.',
        title: 'Survived a monsoon commute',
      ),
      _r(
        'Kabir M.',
        4,
        '3 months',
        DateTime(2026, 8, 2),
        'Well made and comfortable, but it is heavier than it looks. If you '
            'only carry a tablet, the Metro is enough.',
      ),
    ],
    'bp_metro': [
      _r(
        'Riya S.',
        5,
        '5 months',
        DateTime(2026, 9, 1),
        'Light enough that I forget I am wearing it. Fits my 15.6" laptop '
            'with a little room to spare.',
        title: 'Light and sensible',
      ),
      _r(
        'Dev P.',
        3,
        '1 year',
        DateTime(2026, 6, 20),
        'Good for the price, but the base fabric started to fray after a '
            'year of daily use. Only a one-year warranty.',
      ),
    ],
    'hp_pro': [
      _r(
        'Meera K.',
        5,
        '6 months',
        DateTime(2026, 9, 22),
        'The noise cancelling turns a noisy hostel room into a library. '
            'Battery lasts me a full week of evenings.',
        title: 'My focus switch',
      ),
      _r(
        'Arjun T.',
        4,
        '2 months',
        DateTime(2026, 8, 30),
        'Great isolation, but they get warm after two hours and are a bit '
            'heavy. I wish I had tried the Core Edition first.',
      ),
    ],
    'hp_core': [
      _r(
        'Sana F.',
        5,
        '4 months',
        DateTime(2026, 9, 10),
        'Ninety percent of the Pro for less money. For studying I cannot '
            'tell the difference.',
        title: 'The sensible pick',
      ),
      _r(
        'Rohan D.',
        4,
        '7 months',
        DateTime(2026, 7, 18),
        'Good ANC and battery. There is a small delay with videos over '
            'Bluetooth, so not ideal for gaming.',
      ),
    ],
    'sling_field': [
      _r(
        'Ishaan V.',
        5,
        '10 months',
        DateTime(2026, 8, 12),
        'Phone, wallet, keys, earbuds and a charger, all with their own '
            'pocket. I stopped carrying a backpack on weekends.',
        title: 'Everything has a place',
      ),
      _r(
        'Nisha G.',
        4,
        '2 months',
        DateTime(2026, 9, 5),
        'Beautifully organised, but 6 L really is small. A water bottle does '
            'not fit inside.',
      ),
    ],
    'lamp_halo': [
      _r(
        'Tanvi J.',
        5,
        '6 months',
        DateTime(2026, 8, 25),
        'No flicker and the warm setting is easy on the eyes during late '
            'study sessions. The arm stays exactly where I put it.',
      ),
      _r(
        'Varun N.',
        4,
        '3 months',
        DateTime(2026, 9, 18),
        'Lovely light, but it needs to be plugged in. A battery would have '
            'made it perfect for a shared room.',
      ),
    ],
    'org_kova': [
      _r(
        'Pooja L.',
        4,
        '4 months',
        DateTime(2026, 7, 30),
        'Tidied my desk in twenty minutes. The adhesive clips have held so '
            'far.',
      ),
      _r(
        'Aman C.',
        3,
        '1 month',
        DateTime(2026, 9, 26),
        'Does the job, but honestly a few velcro ties would have done most '
            'of it. Nice to have, not essential.',
      ),
    ],
    'kb_loom': [
      _r(
        'Neel A.',
        5,
        '9 months',
        DateTime(2026, 8, 8),
        'Quiet enough to type at night while my roommate sleeps, and still '
            'satisfying to type on. Solid aluminium case.',
        title: 'Quiet but not mushy',
      ),
      _r(
        'Shreya B.',
        4,
        '2 months',
        DateTime(2026, 9, 12),
        'Excellent keyboard. It is a lot of money for a student, though: '
            'wait for a dip if you can.',
      ),
    ],
    'mouse_glide': [
      _r(
        'Karan H.',
        4,
        '5 months',
        DateTime(2026, 8, 19),
        'The silent clicks are real, and one AA lasts months. Fine for '
            'small hands.',
      ),
      _r(
        'Divya M.',
        4,
        '1 year',
        DateTime(2026, 6, 2),
        'Reliable and quiet. After long sessions my wrist aches; it is not '
            'an ergonomic mouse.',
      ),
    ],
    'mouse_ergo': [
      _r(
        'Farhan Q.',
        5,
        '6 months',
        DateTime(2026, 9, 3),
        'My wrist pain went away within two weeks. Takes a few days to get '
            'used to, then you never want to go back.',
        title: 'Worth the learning curve',
      ),
      _r(
        'Leena W.',
        3,
        '1 month',
        DateTime(2026, 9, 28),
        'Comfortable, but I am still slower with it than a normal mouse. '
            'Give it more than a week before deciding.',
      ),
    ],
    'bottle_thermo': [
      _r(
        'Aditi Y.',
        5,
        '1 year',
        DateTime(2026, 7, 7),
        'Ice still clinking at 6 pm in May. No leaks in my bag so far.',
      ),
      _r(
        'Manav E.',
        4,
        '3 months',
        DateTime(2026, 9, 9),
        'Keeps tea hot for hours. It is heavy when full, and the paint '
            'chipped after one drop.',
      ),
    ],
    'notebook_dot': [
      _r(
        'Kriti O.',
        4,
        '4 months',
        DateTime(2026, 8, 15),
        'Fountain pen does not bleed through. Three notebooks lasted me a '
            'whole semester.',
      ),
      _r(
        'Siddharth U.',
        4,
        '2 months',
        DateTime(2026, 9, 21),
        'Nice paper, but if you take notes on a tablet you will not use '
            'these much.',
      ),
    ],
    'pb_volt': [
      _r(
        'Zoya I.',
        5,
        '8 months',
        DateTime(2026, 8, 1),
        'Charges my phone four times and my laptop once in a pinch. '
            'Fast-charge works as promised.',
        title: 'Weekend-proof',
      ),
      _r(
        'Rahul K.',
        4,
        '5 months',
        DateTime(2026, 9, 6),
        'Plenty of power, but it is a brick. Not something you carry every '
            'day.',
      ),
    ],
    'stand_lift': [
      _r(
        'Ira V.',
        5,
        '7 months',
        DateTime(2026, 8, 27),
        'Screen at eye level made a real difference to my neck. Sturdy, no '
            'wobble while typing.',
      ),
      _r(
        'Omkar S.',
        4,
        '3 months',
        DateTime(2026, 9, 15),
        'Solid stand, but it does not fold flat, so it stays on the desk. '
            'You also need a separate keyboard.',
      ),
    ],
    'earb_pulse': [
      _r(
        'Naina P.',
        4,
        '6 months',
        DateTime(2026, 8, 9),
        'Comfortable for hours and the case lasts all week. Calls are clear '
            'outdoors.',
      ),
      _r(
        'Yash R.',
        3,
        '4 months',
        DateTime(2026, 9, 2),
        'Good sound, weak noise cancelling on the train. For focus, the '
            'over-ear options do much better.',
      ),
    ],
    'cam_clear': [
      _r(
        'Prachi D.',
        4,
        '3 months',
        DateTime(2026, 9, 11),
        'Much sharper than my laptop camera for online classes. The '
            'microphone is only average.',
      ),
      _r(
        'Tushar A.',
        3,
        '2 months',
        DateTime(2026, 9, 24),
        'Fine in daylight, grainy in a dim room. Pair it with a desk lamp.',
      ),
    ],
    'cushion_lumbar': [
      _r(
        'Rhea N.',
        5,
        '5 months',
        DateTime(2026, 8, 21),
        'My lower back no longer aches after long study days. The cover '
            'washes well.',
      ),
      _r(
        'Vikram L.',
        3,
        '1 month',
        DateTime(2026, 9, 29),
        'Helps, but the foam is firm and the strap slips on my chair. '
            'Check your chair shape first.',
      ),
    ],
  };
}
