import 'package:get/get.dart';

class ControllerTwo extends GetxController {
  // ************************** Update Status Two **************************

  // متغير لتخزين الحالة المختارة (Completed أو Failed)
  var selectedStatus = 'failed'.obs; // القيمة الافتراضية كما في الصورة

  // متغير لتخزين نص سبب الفشل (عند اختيار Failed)
  var failureReason = ''.obs;

  // دالة لتغيير الحالة المختارة
  void changeStatus(String status) {
    selectedStatus.value = status;
    // إذا تم اختيار "Completed"، نقوم بمسح سبب الفشل
    if (status == 'completed') {
      failureReason.value = '';
    }
  }

  // دالة لتحديث سبب الفشل من المدخلات النصية
  void updateFailureReason(String reason) {
    failureReason.value = reason;
  }
}
