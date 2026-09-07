class SupportOption {
  final String title;
  final String description;
  final String icon;
  final Function()? onTap;

  SupportOption({
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });
}
