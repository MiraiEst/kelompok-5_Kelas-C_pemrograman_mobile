/// Bid increment table in Rupiah, based on the current price.
///
/// Adapted from the spec's USD table to sensible IDR steps.
/// Advanced Dart: a const list of named records + record destructuring
/// in a `for` loop.
const List<({int below, int step})> incrementTiers = [
  (below: 10000, step: 500),
  (below: 50000, step: 1000),
  (below: 100000, step: 2000),
  (below: 500000, step: 5000),
  (below: 1000000, step: 10000),
  (below: 5000000, step: 25000),
  (below: 10000000, step: 50000),
];

const int topIncrement = 100000;

int bidIncrement(int price) {
  for (final (:below, :step) in incrementTiers) {
    if (price < below) return step;
  }
  return topIncrement;
}
