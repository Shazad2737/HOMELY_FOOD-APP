/// Extension for Set
extension ToggleExtension<T> on Set<T> {
  /// Toggles the element in the set.
  ///
  /// If the set contains the element, it is removed.
  /// If the set does not contain the element, it is added.
  ///
  /// ```
  /// var set = Set<int>();
  /// set.toggle(1); // Adds 1 to the set.
  /// set.toggle(1); // Removes 1 from the set.
  /// ```
  Set<T> toggle(T element) {
    final set = Set.of(this);

    if (set.contains(element)) {
      set.remove(element);
    } else {
      set.add(element);
    }
    return set;
  }
}
