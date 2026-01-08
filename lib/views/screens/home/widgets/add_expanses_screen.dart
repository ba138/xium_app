import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/store_detail_controller.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class AddExpenseScreen extends StatefulWidget {
  final String docId;
  final String? storeName;
  final String? storeLogo;
  final int? documentCount;
  const AddExpenseScreen({
    super.key,
    required this.docId,
    this.storeName,
    this.storeLogo,
    this.documentCount,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String selectedCurrency = "USD";
  String amount = "0";
  bool showCursor = true;

  List<String> currencies = ["USD", "PKR", "EUR", "GBP"];
  var controller = Get.put(StoreDetailController());
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();

    /// blinking cursor
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        showCursor = !showCursor;
      });
    });
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() {
        showCursor = !showCursor;
      });
    });
  }

  void onKeyTap(String value) {
    setState(() {
      if (value == "back") {
        if (amount.length > 1) {
          amount = amount.substring(0, amount.length - 1);
        } else {
          amount = "0";
        }
      } else {
        if (amount == "0") {
          amount = value;
        } else {
          amount += value;
        }
      }
    });
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- HEADER ----------
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    MyText(text: "Create Expense", size: 16),
                  ],
                ),

                const SizedBox(height: 50),

                // ---------- CURRENCY + AMOUNT ----------
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$selectedCurrency ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: amount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: showCursor ? "|" : "",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ---------- CURRENCY DROPDOWN ----------
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1F2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        dropdownColor: Colors.black,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        items: currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedCurrency = v!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ---------- KEYPAD ----------
                // ---------- KEYPAD ----------
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      0.6, // adjust until all keys fit perfectly
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3, // makes buttons shorter or taller
                    children: [
                      for (var i = 1; i <= 9; i++) keypadButton(i.toString()),
                      keypadButton("."),
                      keypadButton("0"),
                      keypadButton("back"),
                    ],
                  ),
                ),
                // ---------- BUTTON ----------
                MyButton(
                  onTap: () {
                    controller.addOrUpdateAmount(
                      documentId: widget.docId,
                      amount: double.tryParse(amount)!,
                      currency: selectedCurrency,
                      storeName: widget.storeName,
                      storeLogo: widget.storeLogo,
                      documentCount: widget.documentCount,
                    );
                  },
                  buttonText: "Next",
                  radius: 12,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- KEYPAD BUTTON ----------
  Widget keypadButton(String value) {
    bool isBack = value == "back";

    return GestureDetector(
      onTap: () => onKeyTap(value),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isBack
              ? const Icon(Icons.backspace, color: Colors.white, size: 18)
              : Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
