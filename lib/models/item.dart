class Item {
  String title; // Remova o '?'
  bool done;

  Item({required this.title, required this.done}); // Use 'required' para evitar nulos

  Item.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '', // Garante que title nunca seja null
        done = json['done'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }
}
