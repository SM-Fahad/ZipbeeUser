import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/models/address_model.dart';
import 'package:get/get.dart';


class CollectFormController extends GetxController {
  // .obs makes variables reactive so UI updates automatically
  var selectedFilterIndex = 0.obs;
  var isLoading = false.obs;
  var addressList = <AddressModel>[].obs;
  var selectedAddress = Rxn<AddressModel>();

  // Filter names
  final List<String> filters = ["Recent", "Frequently Used", "Saved"];

  @override
  void onInit() {
    super.onInit();
    // Load initial data
    fetchAddresses();
  }

  // Change active filter tab
  void changeFilter(int index) {
    selectedFilterIndex.value = index;
    fetchAddresses();
  }

  // Fetch address data (simulate API call)
  Future<void> fetchAddresses() async {
    isLoading.value = true;

    // Simulated delay
    await Future.delayed(Duration(milliseconds: 500));

    // Clear previous list
    addressList.clear();

    // Load mock data based on selected filter
    switch (selectedFilterIndex.value) {
      case 0:
        addressList.addAll(_getRecentData());
        break;
      case 1:
        addressList.addAll(_getFrequentlyUsedData());
        break;
      case 2:
        addressList.addAll(_getSavedData());
        break;
    }

    isLoading.value = false;
  }

  // ✅ Centralized tap handler
  // void onAddressTap(AddressModel address) {
  //   selectedAddress.value = address;

  //   if (selectedFilterIndex.value == 0) {
  //     Get.to(() => SenderView(address: address));
  //   } else if (selectedFilterIndex.value == 1) {
  //     Get.to(() => RecipientView(address: address));
  //   }
  // }

  // ---------- MOCK DATA ----------

  List<AddressModel> _getRecentData() {
    return [
      AddressModel(
        title: 'Current location',
        subtitle: '420 Ang Mo Kio Ave 4, Singapore 560422',
        iconPath: IconPath.location,
      ),
      AddressModel(
        title: '778 Sengkang Ave 7',
        subtitle: '778 Sengkang Ave 7, Singapore 530778',
        iconPath: IconPath.history,
      ),
    ];
  }

  List<AddressModel> _getFrequentlyUsedData() {
    return [
      AddressModel(
        title: '560 Balestier Road',
        subtitle: '560 Balestier Road, Singapore 329876',
        iconPath: IconPath.history,
      ),
      AddressModel(
        title: '222 Sengkang Ave 2',
        subtitle: '222 Sengkang Ave 2, Singapore 530222',
        iconPath: IconPath.history,
      ),
    ];
  }

  List<AddressModel> _getSavedData() {
    return [
      AddressModel(
        title: 'Compass Apartment',
        subtitle: '50 Balestier Road, Singapore 330873',
        iconPath: IconPath.history,
      ),
    ];
  }
}
