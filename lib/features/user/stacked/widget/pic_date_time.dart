import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StackedScheduleController extends GetxController {
  var selectedDateTime = DateTime.now().obs;
  var isNow = true.obs;

  void setNow(bool value) {
    isNow.value = value;
    if (value) selectedDateTime.value = DateTime.now();
  }

  void setDateTime(DateTime dateTime) {
    selectedDateTime.value = dateTime;
    isNow.value = false;
  }
}

class StackedPickDateTimeDialog extends StatelessWidget {
  final StackedScheduleController controller = Get.put(StackedScheduleController());

  StackedPickDateTimeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            // Obx(
            //       () => ListTile(
            //     leading: Icon(Icons.access_time),
            //     title: Text('Now'),
            //     trailing: Radio(
            //       value: true,
            //       // ignore: deprecated_member_use
            //       groupValue: controller.isNow.value,
            //       // ignore: deprecated_member_use
            //       onChanged: (value) => controller.setNow(true),
            //     ),
            //     onTap: () => controller.setNow(true),
            //   ),
            // ),
            Obx(
                  () => ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.green),
                title: Text(
                  DateFormat(
                    'EEE, dd MMM, hh:mm a',
                  ).format(controller.selectedDateTime.value),
                  style: TextStyle(color: Colors.green),
                ),
                trailing: Obx(
                      () => controller.isNow.value
                      ? SizedBox.shrink()
                      : Icon(Icons.check_circle, color: Colors.green),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDateTime.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        controller.selectedDateTime.value,
                      ),
                    );

                    if (pickedTime != null) {
                      controller.setDateTime(
                        DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Get.back(result: controller.selectedDateTime.value);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
