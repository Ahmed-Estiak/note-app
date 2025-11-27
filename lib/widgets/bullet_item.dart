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
  bool _isUpdatingFromParsing = false;

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
        // Skip if we're in the middle of parsing from onSubmitted
        if (_isUpdatingFromParsing) {
          return;
        }
        
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
    // Don't update controller if we're in the middle of parsing
    if (!_isUpdatingFromParsing && widget.item.name != oldWidget.item.name) {
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
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: widget.item.done,
                onChanged: (_) => widget.onToggleDone(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    ),
                    style: TextStyle(
                      fontSize: 14,
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
                        // Set flag to prevent didUpdateWidget from interfering
                        _isUpdatingFromParsing = true;
                        
                        // IMPORTANT: Call onTextChanged FIRST to parse and save data
                        widget.onTextChanged(text);
                        
                        // Parse the text to update the display
                        final parsed = ItemParser.parse(text);
                        
                        if (parsed.isValid) {
                          // Update controller to show only the parsed name
                          _controller.text = parsed.name;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: parsed.name.length),
                          );
                        }
                        
                        // Reset flag after a brief delay to allow state to settle
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            setState(() {
                              _isUpdatingFromParsing = false;
                            });
                          }
                        });
                        
                        widget.onSubmitted(text);
                      }
                    },
                  ),
                  
                  // Item details (price, category, expiry)
                  if (!_isEditing && _hasDetails())
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2),
                      child: Text(
                        _getDetailsText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
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
                icon: const Icon(Icons.edit_outlined, size: 16),
                onPressed: widget.onEditDetails,
                tooltip: 'Edit details',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                onPressed: widget.onDelete,
                tooltip: 'Delete',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
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

