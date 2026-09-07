import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/widget/vehicle_tab_page.dart';
import 'package:flutter/material.dart';


class VehicleSelectionPage extends StatelessWidget {
  const VehicleSelectionPage({super.key});

  Widget buildTabIcon(BuildContext context, String iconPath, int index) {
    final tabIndex = DefaultTabController.of(context).index;

    final isSelected = tabIndex == index;

    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: isSelected ? Colors.yellow : Colors.transparent,
          width: .01,
        ),
      ),
      child: Image.asset(iconPath, height: 80, width: 90, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.backgroungColor,

            appBar: AppBar(
              elevation: 0,
              title: Text(
                'Vehicle Type',
                style: getTextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              backgroundColor: AppColors.backgroungColor,

              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Container(
                  color: AppColors.backgroungColor,
                  margin: EdgeInsets.only(top: 5),

                  child: TabBar(
                    isScrollable: false,
                    indicator: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    tabs: [
                      Tab(icon: buildTabIcon(context, IconPath.bike2, 0)),
                      Tab(icon: buildTabIcon(context, IconPath.car2, 1)),
                      Tab(icon: buildTabIcon(context, IconPath.shipment, 2)),
                      Tab(icon: buildTabIcon(context, IconPath.shopcar, 3)),
                    ],
                  ),
                ),
              ),
            ),

            body: TabBarView(
              children: [
                VehicleTabPage(vehicleType: 'Courier'),
                VehicleTabPage(vehicleType: 'Car'),
                VehicleTabPage(vehicleType: 'Van'),
                VehicleTabPage(vehicleType: 'Truck'),
              ],
            ),
          );
        },
      ),
    );
  }
}
