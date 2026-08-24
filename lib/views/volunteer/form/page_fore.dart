import 'package:aidora/views/volunteer/form/page_five.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Pagefore extends StatefulWidget {
  const Pagefore({super.key});

  @override
  State<StatefulWidget> createState() => _Pagefore();
}

class _Pagefore extends State<Pagefore> {
  final FormController controller = Get.find();
  // ignore: prefer_typing_uninitialized_variables
  var respons;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final res = await ApiService.instance.get(
      "${ApiConstants.volunteerPageFour}${controller.idOrganization.value}/services/",
      requiresAuth: true,
    );

    if (!mounted) return;

    if (!res.isSuccess) {
      setState(() {
        _isLoading = false;
        _loadError = res.errorMessage;
      });
      return;
    }

    controller.categories.clear();
    final list = (res.data is List) ? res.data as List : <dynamic>[];
    setState(() {
      for (var item in list) {
        controller.categories.add(
          CategoryItem(
            name: item['service_name'],
            isSelected: false.obs,
            id: item['id'],
          ),
        );
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(_loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _init, child: const Text('Retry')),
          ]),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xffF4F4F4),
        body: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: _formCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header() {
    return Container(
      height: 300,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: Color(0xff7AD081),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 90),
              Text(
                "Volunteer Portal",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
          SizedBox(height: 30),
          Text(
            "Where can\nyou help?",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Step 4 of 5: Identity & Residence",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= FORM =================
  Widget _formCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select all categories that match your skills or interest:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              return Obx(
                () => Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controller.categories[index].isSelected.value
                              ? Color(0xff7AD081)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            controller.categories[index].name,
                            style: const TextStyle(fontSize: 15),
                          ),
                          trailing: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: controller
                                        .categories[index].isSelected.value
                                    ? Color(0xff7AD081)
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: controller.categories[index].isSelected.value
                                ? const Icon(
                                    Icons.circle,
                                    size: 18,
                                    color: Color(0xff7AD081),
                                  )
                                : null,
                          ),
                          onTap: () {
                            controller.toggleSelection(index);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Obx(
            () => Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xff7AD081),
                borderRadius: BorderRadius.circular(30),
              ),
              child: MaterialButton(
                onPressed: () {
                  Get.to(
                    () => Pagefive(),
                    arguments: controller.categories
                        .where((item) => item.isSelected.value)
                        .map((item) => item.id)
                        .toList(),
                  );
                },
                child: controller.isLoading.value
                    ? CircularProgressIndicator()
                    : Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
