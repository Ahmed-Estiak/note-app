import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';
import '../utils/item_parser.dart';

class BulletItem extends StatefulWidget {
  final GroceryItem item;
  final Function(String text) onTextChanged;
  final VoidCallback onEditDetails;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;
  final Function(String text) onSubmitted;
  final Function(String text)? onFocusLost;
  final VoidCallback? onEmptySubmitted;
  final VoidCallback? onTextDeleted;
  final bool autoFocus;
  final FocusNode? focusNode;

  const BulletItem({
    super.key,
    required this.item,
    required this.onTextChanged,
    required this.onEditDetails,
    required this.onDelete,
    required this.onToggleDone,
    required this.onSubmitted,
    this.onFocusLost,
    this.onEmptySubmitted,
    this.onTextDeleted,
    this.autoFocus = false,
    this.focusNode,
  });

  @override
  State<BulletItem> createState() => _BulletItemState();
}

class _BulletItemState extends State<BulletItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.name);
    _previousText = widget.item.name;
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(() {
      setState(() {
        _isEditing = _focusNode.hasFocus;
      });
      
      // Save changes when focus is lost
      if (!_focusNode.hasFocus) {
        final text = _controller.text.trim();
        
        if (text.isEmpty) {
          // Empty text: revert to original name
          _controller.text = widget.item.name;
          return;
        }
        
        // Parse to check if name is valid
        final parsed = ItemParser.parse(text);
        
        if (!parsed.isValid) {
          // Invalid (e.g., only "# qty"): revert to original name
          _controller.text = widget.item.name;
          return;
        }
        
        // Valid: update controller to show only parsed name
        if (text != widget.item.name) {
          _controller.text = parsed.name;
          widget.onTextChanged(text);
          widget.onFocusLost?.call(text);
        }
      }
    });

    // Auto-focus if requested
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(BulletItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.name != oldWidget.item.name) {
      _controller.text = widget.item.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Only dispose if we created the focus node
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: widget.item.done,
              onChanged: (_) => widget.onToggleDone(),
            ),
            
            // Text field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autoFocus,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(
                      decoration: widget.item.done ? TextDecoration.lineThrough : null,
                      color: widget.item.done
                          ? Theme.of(context).colorScheme.outline
                          : null,
                    ),
                    onSubmitted: (_) {
                      final text = _controller.text.trim();
                      if (text.isEmpty) {
                        // Keep focus, do nothing - just refocus to keep blinking
                        _focusNode.requestFocus();
                        widget.onEmptySubmitted?.call();
                      } else {
                        // Parse the text
                        final parsed = ItemParser.parse(text);
                        
                        if (parsed.isValid) {
                          // Update controller to show only the parsed name
                          _controller.text = parsed.name;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: parsed.name.length),
                          );
                        }
                        
                        widget.onTextChanged(text);
                        widget.onSubmitted(text);
                      }
                    },
                  ),
                  
                  // Item details (price, category, expiry)
                  if (!_isEditing && _hasDetails())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _getDetailsText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.item.isExpiringSoon
                                  ? Colors.orange.shade700
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: widget.item.isExpiringSoon
                                  ? FontWeight.w500
                                  : null,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Edit and Delete buttons (hidden when editing)
            if (!_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: widget.onEditDetails,
                tooltip: 'Edit details',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: widget.onDelete,
                tooltip: 'Delete',
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasDetails() {
    return widget.item.quantity != null ||
        widget.item.price != null ||
        widget.item.category != 'Other' ||
        widget.item.expiry != null;
  }

  String _getDetailsText() {
    final parts = <String>[];
    
    if (widget.item.quantity != null && widget.item.quantity!.isNotEmpty) {
      parts.add('Qty: ${widget.item.quantity!}');
    }
    
    if (widget.item.price != null) {
      parts.add('\$${widget.item.price!.toStringAsFixed(2)}');
    }
    
    if (widget.item.category != 'Other') {
      parts.add(widget.item.category);
    }
    
    if (widget.item.expiry != null) {
      final expiryText = DateFormat('MMM dd').format(widget.item.expiry!);
      parts.add('Exp: $expiryText');
    }
    
    return parts.join(' • ');
  }
}

