import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/collect_form_controller.dart';

class FilterChipsWidget extends StatelessWidget {
  final CollectFormController controller;

  const FilterChipsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(controller.filters.length, (index) {
          bool isSelected = controller.selectedFilterIndex.value == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              child: FilterChip(
                label: Center(
                  child: Text(
                    controller.filters[index],
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
                  if (selected) controller.changeFilter(index);
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? Colors.yellow : Colors.transparent,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
