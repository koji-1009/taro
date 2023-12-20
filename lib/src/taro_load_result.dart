/// The result of a load operation.
enum TaroLoadResultType {
  /// The load result came from the network.
  network,

  /// The load result came from storage.
  memory,

  /// The load result came from memory.
  storage,
}
