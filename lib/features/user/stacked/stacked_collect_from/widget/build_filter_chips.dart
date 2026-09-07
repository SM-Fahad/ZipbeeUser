import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';

class StackedFilterChipsWidget extends StatelessWidget {
  final StackedCollectFormController controller;
  final VoidCallback? onNewTap;

  const StackedFilterChipsWidget({
    super.key,
    required this.controller,
    this.onNewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.filters.length, (index) {
            bool isSelected = controller.selectedFilterIndex.value == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                showCheckmark: false,
                label: Text(
                  controller.filters[index],
                  style: getTextStyle(
                    color: isSelected ? Colors.black : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    if (controller.filters[index] == "New") {
                      if (onNewTap != null) {
                        onNewTap!();
                      }
                    } else {
                      controller.changeFilter(index);
                    }
                  }
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.yellow,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? Colors.yellow : Colors.transparent,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
