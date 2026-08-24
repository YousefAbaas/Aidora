import 'package:get/get.dart';

class ControllerTwo extends GetxController {
  // ************************** Update Status Two **************************

  // Ù…ØªØºÙŠØ± Ù„ØªØ®Ø²ÙŠÙ† Ø§Ù„Ø­Ø§Ù„Ø© Ø§Ù„Ù…Ø®ØªØ§Ø±Ø© (Completed Ø£Ùˆ Failed)
  var selectedStatus = 'failed'
      .obs; // Ø§Ù„Ù‚ÙŠÙ…Ø© Ø§Ù„Ø§ÙØªØ±Ø§Ø¶ÙŠØ© ÙƒÙ…Ø§ ÙÙŠ Ø§Ù„ØµÙˆØ±Ø©

  // Ù…ØªØºÙŠØ± Ù„ØªØ®Ø²ÙŠÙ† Ù†Øµ Ø³Ø¨Ø¨ Ø§Ù„ÙØ´Ù„ (Ø¹Ù†Ø¯ Ø§Ø®ØªÙŠØ§Ø± Failed)
  var failureReason = ''.obs;

  // Ø¯Ø§Ù„Ø© Ù„ØªØºÙŠÙŠØ± Ø§Ù„Ø­Ø§Ù„Ø© Ø§Ù„Ù…Ø®ØªØ§Ø±Ø©
  void changeStatus(String status) {
    selectedStatus.value = status;
    // Ø¥Ø°Ø§ ØªÙ… Ø§Ø®ØªÙŠØ§Ø± "Completed"ØŒ Ù†Ù‚ÙˆÙ… Ø¨Ù…Ø³Ø­ Ø³Ø¨Ø¨ Ø§Ù„ÙØ´Ù„
    if (status == 'completed') {
      failureReason.value = '';
    }
  }

  // Ø¯Ø§Ù„Ø© Ù„ØªØ­Ø¯ÙŠØ« Ø³Ø¨Ø¨ Ø§Ù„ÙØ´Ù„ Ù…Ù† Ø§Ù„Ù…Ø¯Ø®Ù„Ø§Øª Ø§Ù„Ù†ØµÙŠØ©
  void updateFailureReason(String reason) {
    failureReason.value = reason;
  }
}
