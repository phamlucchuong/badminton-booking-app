class ReviewDto {
  final String userName;
  final int rating;
  final String content;
  final String createdAt;

  const ReviewDto({
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return ReviewDto(
      userName: user['name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  String get initials {
    final name = userName.trim();
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get formattedDate => createdAt.split('T').first;
}
