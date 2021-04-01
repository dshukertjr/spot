class Profile {
  Profile({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  static Map<String, dynamic> toMap(
      {required String id,
      required String name,
      String? description,
      String? imageUrl}) {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
