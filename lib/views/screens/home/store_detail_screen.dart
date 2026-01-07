import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/store_detail_controller.dart';
import 'package:xium_app/views/screens/home/doc_view_screen.dart';
import 'package:xium_app/views/screens/home/widgets/dynamic_container.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/glassy_container.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class StoreDetailScreen extends StatefulWidget {
  final String? storeName;
  final String? storeLogo;
  final int? documentCount;
  const StoreDetailScreen({
    super.key,
    this.storeName,
    this.storeLogo,
    this.documentCount,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final List<String> tags = ["All", "Receipt", "invoice", "Warrantie"];
  int selectedIndex = 0; // default = All selected
  String selectedValue = "Newest";

  final List<String> options = ["Newest", "Oldest", "A–Z", "Z–A"];
  final controller = Get.put(StoreDetailController());
  String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String formatAmount(double? amount, String? currency) {
    if (amount == null) return "N/A";
    return "${currency ?? ''} ${amount.toStringAsFixed(2)}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.listenStoreDocuments(widget.storeName!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
                  MyText(text: "Back", size: 16),
                ],
              ),
              const SizedBox(height: 20),
              GlassContainer(
                height: 120,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.storeLogo != null && widget.storeLogo!.isNotEmpty
                        ? CommonImageView(
                            url: widget.storeLogo!,
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.store,
                            color: AppColors.onPrimary,
                            size: 40,
                          ),
                    const SizedBox(width: 10),

                    /// ⭐ THIS IS THE FIX ⭐
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                            text: widget.storeName ?? "Unknown",
                            size: 20,
                            maxLines: 2, // FULL NAME WITH WRAP
                            textOverflow: TextOverflow.visible,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.article_sharp,
                                color: AppColors.buttonColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              MyText(
                                text:
                                    "${widget.documentCount ?? 0} documents found",
                                size: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          controller.filterByType(tags[index]);
                        });
                      },
                      child: DynamicContainer(
                        text: tags[index],
                        isSelected: selectedIndex == index,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemCount: tags.length,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    text: "Sort Results",
                    size: 12,
                    color: AppColors.grayColor,
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      MyText(text: "Sort By:", size: 12),

                      Container(
                        height: 30,
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.onPrimary,
                            width: 0.6,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedValue,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            dropdownColor: Colors.black87,
                            items: options
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedValue = newValue!;
                                controller.sortByOption(selectedValue);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Glassy container with table
              Expanded(
                child: GlassContainer(
                  width: double.infinity,
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.documents.isEmpty) {
                      return const Center(
                        child: MyText(text: "No documents found"),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowHeight: 35,
                          dividerThickness: 0.6,
                          dataRowHeight: 50,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Doc Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Source',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: controller.documents.map((doc) {
                            return DataRow(
                              cells: [
                                /// Doc Type
                                DataCell(
                                  Text(
                                    doc.documentType ?? "N/A",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),

                                /// Date
                                DataCell(
                                  Text(
                                    formatDate(doc.createdAt?.toDate()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),

                                /// Amount (NULL SAFE)
                                DataCell(
                                  Text(
                                    doc.amount == null
                                        ? "N/A"
                                        : "${doc.currency ?? ''} ${doc.amount!.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),

                                /// Source
                                DataCell(
                                  Text(
                                    doc.source ?? "N/A",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),

                                /// View
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => DocViewScreen(
                                          document: doc,
                                          storeLogo: widget.storeLogo,
                                          storeName: widget.storeName,
                                          documentCount: widget.documentCount,
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.remove_red_eye,
                                      size: 16,
                                      color: AppColors.buttonColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
