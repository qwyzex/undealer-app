List<T> derangedShuffle<T>(List<T> list) {
  final shuffled = List<T>.from(list)..shuffle();

  for (int i = 0; i < shuffled.length; i++) {
    if (shuffled[i] == list[i]) {
      final swapIndex = (i + 1) % shuffled.length;
      final temp = shuffled[i];
      shuffled[i] = shuffled[swapIndex];
      shuffled[swapIndex] = temp;
    }
  }

  return shuffled;
}
