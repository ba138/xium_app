import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/constants/app_fonts.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class MyTextField extends StatefulWidget {
  final String? label, hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool? isObSecure, haveLabel, isReadOnly;
  final double? marginBottom, radius;
  final int? maxLines;
  final double? labelSize, hintsize;
  final FocusNode? focusNode;
  final Color? filledColor, focusedFillColor, hintColor, labelColor;
  final Widget? prefix, suffix;
  final FontWeight? labelWeight, hintWeight;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final double? height;
  final double? width;
  final FormFieldValidator<String>? validator;
  final bool? showVisibilityToggle; // NEW: show/hide password icon

  const MyTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 16.0,
    this.maxLines = 1,
    this.filledColor,
    this.focusedFillColor,
    this.hintColor,
    this.labelColor,
    this.haveLabel = true,
    this.labelSize,
    this.hintsize,
    this.prefix,
    this.suffix,
    this.labelWeight,
    this.hintWeight,
    this.keyboardType,
    this.isReadOnly,
    this.onTap,
    this.focusNode,
    this.radius,
    this.height = 48,
    this.width,
    this.validator,
    this.showVisibilityToggle = false, // NEW: default false
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isFocused = false;
  bool _obscureText = false; // NEW: for password visibility

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
    _obscureText = widget.isObSecure ?? false; // NEW: initialize
  }

  void _onFocusChange() {
    setState(() {
      isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: Duration(milliseconds: 500)),
        MoveEffect(
          curve: Curves.ease,
          duration: Duration(milliseconds: 500),
          transformHitTests: F,
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.marginBottom ?? 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              MyText(
                text: widget.label ?? '',
                size: widget.labelSize ?? 12,
                paddingBottom: 5,
                color: AppColors.primary,
                fontFamily: AppFonts.satoshi,
                weight: widget.labelWeight ?? FontWeight.w400,
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius ?? 12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius ?? 12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ⬇️ Your TextFormField stays EXACT (no changes to inner logic)
                        TextFormField(
                          focusNode: widget.focusNode,
                          onTap: widget.onTap,
                          textAlignVertical: TextAlignVertical.center,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: widget.keyboardType,
                          cursorColor: AppColors.buttonColor,
                          maxLines: widget.maxLines,
                          readOnly: widget.isReadOnly ?? false,
                          controller: widget.controller,
                          onChanged: (val) {
                            if (widget.onChanged != null) {
                              widget.onChanged!(val);
                            }
                            final ctl = widget.controller;
                            if (ctl != null) {
                              final v = ctl.value;
                              if (v.composing != TextRange.empty) {
                                ctl.value = v.copyWith(
                                  composing: TextRange.empty,
                                );
                              }
                            }
                          },
                          textInputAction: TextInputAction.next,
                          obscureText: widget.showVisibilityToggle == true
                              ? _obscureText
                              : (widget.isObSecure ?? false),
                          obscuringCharacter: '*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFonts.satoshi,
                            decoration: TextDecoration.none,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                widget.radius ?? 25,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.02),
                            prefixIcon: widget.prefix,
                            suffixIcon: widget.showVisibilityToggle == true
                                ? IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  )
                                : widget.suffix,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: widget.hint != null
                                ? widget.hint!.tr
                                : '',
                            hintStyle: TextStyle(
                              fontSize: widget.hintsize ?? 14,
                              fontFamily: AppFonts.satoshi,
                              color: Colors.grey.withValues(alpha: 0.6),
                              fontWeight: widget.hintWeight ?? FontWeight.w400,
                            ),
                            errorStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              height: 1.2,
                            ),
                          ),
                          validator: widget.validator,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
