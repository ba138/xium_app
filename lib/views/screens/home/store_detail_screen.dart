import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
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
  final List<String> tags = ["All", "Receipts", "Invoices", "Warranties"];
  int selectedIndex = 0; // default = All selected
  String selectedValue = "Newest";

  final List<String> options = ["Newest", "Oldest", "A–Z", "Z–A"];

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
                    CommonImageView(
                      url:
                          widget.storeLogo ??
                          "https://c8.alamy.com/comp/P2D424/store-vector-icon-isolated-on-transparent-background-store-logo-concept-P2D424.jpg",
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
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
                    text: "23 docs Found",
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis
                          .horizontal, // horizontal scroll to prevent overflow
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
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Source',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'View',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Invoice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '20/04/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Receipt',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '22/05/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$15',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'OCR',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Warranty',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '10/06/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$50',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Bank',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Invoice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '20/04/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Invoice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '20/04/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Invoice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '20/04/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Invoice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '20/04/2020',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => DocViewScreen());
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
