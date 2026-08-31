class Organization {
  final String id;
  final String name;
  final String subtitle;
  final List<String> categories;

  Organization({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.categories,
  });

  String get logo {
    switch (id) {
      case '1':
        return 'https://aidora-z01k.onrender.com/media/organizations/logos/DIV.png';
      case '2':
        return 'https://aidora-z01k.onrender.com/media/organizations/logos/DIV2.png';
      case '3':
        return 'https://aidora-z01k.onrender.com/media/organizations/logos/Image.png';
      case '4':
        return 'https://aidora-z01k.onrender.com/media/organizations/logos/Image4.png';
      case '5':
        return 'https://aidora-z01k.onrender.com/media/organizations/logos/Image5.png';
      case '6':
        return 'https://aidora-z01k.onrender.com/media/organizations/logos/Image6.png';
      default:
        return '';
    }
  }
}
