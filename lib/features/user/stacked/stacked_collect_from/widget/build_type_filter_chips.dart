import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';

class StackedTypeFilterChipsWidget extends StatelessWidget {
  final StackedCollectFormController controller;

  const StackedTypeFilterChipsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Type',
            style: getTextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(controller.typeFilters.length, (index) {
              bool isSelected = 
                  (index == 0 && controller.selectedTypeFilter.value == 'ALL') ||
                  (index == 1 && controller.selectedTypeFilter.value == 'SENDER') ||
                  (index == 2 && controller.selectedTypeFilter.value == 'RECEIVER');

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  child: FilterChip(
                    label: Center(
                      child: Text(
                        controller.typeFilters[index],
                        style: getTextStyle(
                          color: isSelected ? Colors.black : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) controller.changeTypeFilter(index);
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
