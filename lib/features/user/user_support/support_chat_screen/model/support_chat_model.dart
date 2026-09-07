class Message {
  final String sender;
  final String text;
  final bool isUser;

  Message({required this.sender, required this.text, this.isUser = false});
}
