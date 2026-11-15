import 'package:flutter/material.dart';

class CartNoteDialog extends StatefulWidget {
  const CartNoteDialog({super.key, required this.initialNote});

  final String initialNote;

  @override
  State<CartNoteDialog> createState() => _CartNoteDialogState();
}

class _CartNoteDialogState extends State<CartNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi chú dòng hàng'),
      content: SingleChildScrollView(
        child: TextField(
          key: const ValueKey('edit_cart_note'),
          controller: _controller,
          autofocus: true,
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: 'Ghi chú',
            hintText: 'Có thể để trống',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          key: const ValueKey('save_cart_note'),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
