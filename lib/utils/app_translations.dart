import 'package:get/get.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// AppTranslations  â€” bilingual strings for every screen.
/// Add new keys to BOTH maps to keep them in sync.
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': _en,
        'ar': _ar,
      };

  // â”€â”€ English â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Map<String, String> _en = {
    // â”€â”€ App â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'app_name': 'Aidora',

    // â”€â”€ Home / Org list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'supporting_orgs': 'Supporting Organizations\nfor the Application',
    'search_hint': "Describe your needs (e.g. 'I need food')",
    'filter_by_service': 'Filter by Service',
    'view_details': 'View Details',
    'request_help': 'Request Help',
    'volunteer': 'Volunteer',
    'no_orgs': 'No organizations found.',
    'retry': 'Retry',
    'no_results_filter': 'No organizations found for this category.',

    // â”€â”€ Filter sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'filter_title': 'Filter by Service',

    // â”€â”€ Org Details â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'about_mission': 'About Mission',
    'target_groups': 'Target Groups',
    'services_provided': 'Services Provided',
    'key_areas': 'Key Areas',
    'our_impact': 'Our Impact',
    'official_website': 'Official Website',

    // â”€â”€ Auth â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'login': 'Login',
    'create_account': 'Create Account',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'full_name': 'Full Name',
    'phone_number': 'Phone Number',
    'forgot_password': 'Forgot password?',
    'sign_in_google': 'Sign in with Google',
    'are_you_new': 'Are you new?',
    'already_account': 'Already have an account? Login',
    'fill_info': 'Fill in the information below to register',
    'create_refugee': 'Create your\nRefugee Account',
    'terms_consent':
        'I consent to use my personal data for humanitarian assistance purposes and accept the Terms & Conditions',

    // â”€â”€ Complete Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'complete_info': 'Please complete your\npersonal information',
    'gender': 'Gender',
    'select_gender': 'Select gender',
    'family_categories': 'Family categories',
    'select_category': 'Select category',
    'birthday': 'Birthday',
    'location': 'Location',
    'city_region': 'City or Region',
    'sector_name': 'Sector name',
    'sector_hint': 'e.g. Sector B',
    'consent_text':
        'Consent to use personal data for humanitarian assistance purposes',
    'done': 'Done',
    'family_members': 'Family Members',
    'confirm': 'Confirm',
    'children': 'Children',
    'elderly': 'Elderly',
    'with_disabilities': 'With disabilities',
    'women': 'Women',

    // â”€â”€ Requests Dashboard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'welcome_back': 'Welcome back,',
    'my_requests': 'My Requests',
    'total': 'Total',
    'approved': 'Approved',
    'rejected': 'Rejected',
    'pending': 'Pending',
    'completed': 'Completed',
    'approved_requests': 'Approved Requests',
    'rejected_requests': 'Rejected Requests',
    'view_all': 'View All',
    'scan_qr': 'Scan QR to Collect',
    'details': 'Details',
    'reason': 'Reason',

    // â”€â”€ Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'profile': 'Profile',
    'current_location': 'Current Location',
    'household': 'Household',
    'total_family': 'Total Family',
    'log_out': 'Log out',
    'log_out_confirm': 'Are you sure you want to log out?',
    'cancel': 'Cancel',
    'safe': 'Safe',
    'tap_photo': 'Tap photo to change or remove',
    'profile_photo': 'Profile Photo',
    'upload_device': 'Upload from Device',
    'choose_gallery': 'Choose from Gallery',
    'take_photo': 'Take a Photo',
    'remove_photo': 'Remove Photo',
    'select_image': 'Select an image file',
    'pick_gallery': 'Pick from gallery',
    'use_camera': 'Use your camera',
    'delete_photo': 'Delete your current photo',

    // â”€â”€ Settings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'settings': 'Settings',
    'appearance': 'Appearance',
    'language': 'Language',
    'language_sub': 'Switch between Arabic and English',
    'dark_mode': 'Dark Mode',
    'dark_mode_sub': 'Toggle dark / light appearance',
    'privacy_mode': 'Privacy Mode',
    'privacy_mode_sub': 'Blur sensitive data on screen',
    'current_lang': 'English',
    'switch_to': 'Switch to Arabic',

    // â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'notifications': 'Notifications',

    // â”€â”€ AI Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'ai_searching': 'AI is searchingâ€¦',
    'ai_no_match': 'No match found. Showing all organizations.',
    // â”€â”€ Forgot / Reset Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'forgot_password_title': 'Forgot Password',
    'forgot_password_sub': 'Enter your email and we\'ll send you a reset link.',
    'send_reset_link': 'Send Reset Link',
    'check_email': 'Check your email',
    'check_email_sub': 'Click the link in the email to reset your password.',
    'resend_link': 'Didn\'t receive it? Try again',
    'back_to_login': 'Back to Login',
    'create_new_password': 'Create New Password',
    'new_password': 'New Password',
    'save_password': 'Save Password',
    'enter_email_hint': 'Enter your email address',
    'min_6_chars': 'Min 6 characters',
    'repeat_password': 'Repeat new password',

    // â”€â”€ OTP â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'verify_account': 'Verify Your Account',
    'otp_sent_to': 'We sent a 6-digit code to',
    'verify_btn': 'Verify Account',
    'resend_in': 'Resend in',
    'resend': 'Resend',
    'no_code': 'Didn\'t receive the code? ',

    // â”€â”€ QR Scanner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'scan_qr_title': 'Scan QR Code',
    'scan_qr_hint': 'Point your camera at the QR code\nto verify your request',
    'verifying_qr': 'Verifying QR codeâ€¦',
    'qr_success': 'Request completed successfully!',
    'done_completed': 'Done â€” Request Completed',
    'waiting_scan': 'Waiting for scanâ€¦',

    // â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'no_notifications': 'No notifications yet.',
    'mark_all_read': 'Mark all as read',
  };

  // â”€â”€ Arabic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Map<String, String> _ar = {
    'app_name': 'Ø£ÙŠØ¯ÙˆØ±Ø§',
    'supporting_orgs': 'Ø§Ù„Ù…Ù†Ø¸Ù…Ø§Øª Ø§Ù„Ø¯Ø§Ø¹Ù…Ø©\nÙ„Ù„ØªØ·Ø¨ÙŠÙ‚',
    'search_hint': "ØµÙ Ø§Ø­ØªÙŠØ§Ø¬Ø§ØªÙƒ (Ù…Ø«Ù„: Ø£Ø­ØªØ§Ø¬ Ø·Ø¹Ø§Ù…Ø§Ù‹)",
    'filter_by_service': 'ØªØµÙÙŠØ© Ø­Ø³Ø¨ Ø§Ù„Ø®Ø¯Ù…Ø©',
    'view_details': 'Ø¹Ø±Ø¶ Ø§Ù„ØªÙØ§ØµÙŠÙ„',
    'request_help': 'Ø·Ù„Ø¨ Ù…Ø³Ø§Ø¹Ø¯Ø©',
    'volunteer': 'ØªØ·ÙˆØ¹',
    'no_orgs': 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ù†Ø¸Ù…Ø§Øª.',
    'retry': 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©',
    'no_results_filter': 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ù†Ø¸Ù…Ø§Øª Ù„Ù‡Ø°Ù‡ Ø§Ù„ÙØ¦Ø©.',
    'filter_title': 'ØªØµÙÙŠØ© Ø­Ø³Ø¨ Ø§Ù„Ø®Ø¯Ù…Ø©',
    'about_mission': 'Ø¹Ù† Ø§Ù„Ù…Ù‡Ù…Ø©',
    'target_groups': 'Ø§Ù„ÙØ¦Ø§Øª Ø§Ù„Ù…Ø³ØªÙ‡Ø¯ÙØ©',
    'services_provided': 'Ø§Ù„Ø®Ø¯Ù…Ø§Øª Ø§Ù„Ù…Ù‚Ø¯Ù…Ø©',
    'key_areas': 'Ø§Ù„Ù…Ø¬Ø§Ù„Ø§Øª Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©',
    'our_impact': 'ØªØ£Ø«ÙŠØ±Ù†Ø§',
    'official_website': 'Ø§Ù„Ù…ÙˆÙ‚Ø¹ Ø§Ù„Ø±Ø³Ù…ÙŠ',
    'login': 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„',
    'create_account': 'Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨',
    'email': 'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
    'password': 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
    'confirm_password': 'ØªØ£ÙƒÙŠØ¯ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
    'full_name': 'Ø§Ù„Ø§Ø³Ù… Ø§Ù„ÙƒØ§Ù…Ù„',
    'phone_number': 'Ø±Ù‚Ù… Ø§Ù„Ù‡Ø§ØªÙ',
    'forgot_password': 'Ù†Ø³ÙŠØª ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±ØŸ',
    'sign_in_google': 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ø¨Ù€ Google',
    'are_you_new': 'Ù…Ø³ØªØ®Ø¯Ù… Ø¬Ø¯ÙŠØ¯ØŸ',
    'already_account': 'Ù„Ø¯ÙŠÙƒ Ø­Ø³Ø§Ø¨ Ø¨Ø§Ù„ÙØ¹Ù„ØŸ Ø³Ø¬Ù‘Ù„ Ø¯Ø®ÙˆÙ„Ùƒ',
    'fill_info': 'Ø£Ø¯Ø®Ù„ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø£Ø¯Ù†Ø§Ù‡ Ù„Ù„ØªØ³Ø¬ÙŠÙ„',
    'create_refugee': 'Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨\nÙ„Ø§Ø¬Ø¦',
    'terms_consent':
        'Ø£ÙˆØ§ÙÙ‚ Ø¹Ù„Ù‰ Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø¨ÙŠØ§Ù†Ø§ØªÙŠ Ø§Ù„Ø´Ø®ØµÙŠØ© Ù„Ø£ØºØ±Ø§Ø¶ Ø§Ù„Ù…Ø³Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¥Ù†Ø³Ø§Ù†ÙŠØ© ÙˆØ£Ù‚Ø¨Ù„ Ø§Ù„Ø´Ø±ÙˆØ· ÙˆØ§Ù„Ø£Ø­ÙƒØ§Ù…',
    'complete_info': 'ÙŠØ±Ø¬Ù‰ Ø¥ÙƒÙ…Ø§Ù„\nÙ…Ø¹Ù„ÙˆÙ…Ø§ØªÙƒ Ø§Ù„Ø´Ø®ØµÙŠØ©',
    'gender': 'Ø§Ù„Ø¬Ù†Ø³',
    'select_gender': 'Ø§Ø®ØªØ± Ø§Ù„Ø¬Ù†Ø³',
    'family_categories': 'ÙØ¦Ø§Øª Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©',
    'select_category': 'Ø§Ø®ØªØ± Ø§Ù„ÙØ¦Ø©',
    'birthday': 'ØªØ§Ø±ÙŠØ® Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯',
    'location': 'Ø§Ù„Ù…ÙˆÙ‚Ø¹',
    'city_region': 'Ø§Ù„Ù…Ø¯ÙŠÙ†Ø© Ø£Ùˆ Ø§Ù„Ù…Ù†Ø·Ù‚Ø©',
    'sector_name': 'Ø§Ø³Ù… Ø§Ù„Ù‚Ø·Ø§Ø¹',
    'sector_hint': 'Ù…Ø«Ø§Ù„: Ø§Ù„Ù‚Ø·Ø§Ø¹ Ø¨',
    'consent_text':
        'Ø£ÙˆØ§ÙÙ‚ Ø¹Ù„Ù‰ Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø¨ÙŠØ§Ù†Ø§ØªÙŠ Ø§Ù„Ø´Ø®ØµÙŠØ© Ù„Ø£ØºØ±Ø§Ø¶ Ø§Ù„Ù…Ø³Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¥Ù†Ø³Ø§Ù†ÙŠØ©',
    'done': 'ØªÙ…',
    'family_members': 'Ø£ÙØ±Ø§Ø¯ Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©',
    'confirm': 'ØªØ£ÙƒÙŠØ¯',
    'children': 'Ø£Ø·ÙØ§Ù„',
    'elderly': 'Ù…Ø³Ù†ÙˆÙ†',
    'with_disabilities': 'Ø°ÙˆÙˆ Ø¥Ø¹Ø§Ù‚Ø§Øª',
    'women': 'Ù†Ø³Ø§Ø¡',
    'welcome_back': 'Ù…Ø±Ø­Ø¨Ø§Ù‹ Ø¨Ø¹ÙˆØ¯ØªÙƒØŒ',
    'my_requests': 'Ø·Ù„Ø¨Ø§ØªÙŠ',
    'total': 'Ø§Ù„Ù…Ø¬Ù…ÙˆØ¹',
    'approved': 'Ù…ÙˆØ§ÙÙ‚ Ø¹Ù„ÙŠÙ‡',
    'rejected': 'Ù…Ø±ÙÙˆØ¶',
    'pending': 'Ù‚ÙŠØ¯ Ø§Ù„Ø§Ù†ØªØ¸Ø§Ø±',
    'completed': 'Ù…ÙƒØªÙ…Ù„',
    'approved_requests': 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ù…ÙˆØ§ÙÙ‚ Ø¹Ù„ÙŠÙ‡Ø§',
    'rejected_requests': 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ù…Ø±ÙÙˆØ¶Ø©',
    'view_all': 'Ø¹Ø±Ø¶ Ø§Ù„ÙƒÙ„',
    'scan_qr': 'Ø§Ù…Ø³Ø­ QR Ù„Ù„Ø§Ø³ØªÙ„Ø§Ù…',
    'details': 'Ø§Ù„ØªÙØ§ØµÙŠÙ„',
    'reason': 'Ø§Ù„Ø³Ø¨Ø¨',
    'profile': 'Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ',
    'current_location': 'Ø§Ù„Ù…ÙˆÙ‚Ø¹ Ø§Ù„Ø­Ø§Ù„ÙŠ',
    'household': 'Ø§Ù„Ø£Ø³Ø±Ø©',
    'total_family': 'Ø¥Ø¬Ù…Ø§Ù„ÙŠ Ø§Ù„Ø£Ø³Ø±Ø©',
    'log_out': 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬',
    'log_out_confirm': 'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬ØŸ',
    'cancel': 'Ø¥Ù„ØºØ§Ø¡',
    'safe': 'Ø¢Ù…Ù†',
    'tap_photo': 'Ø§Ù†Ù‚Ø± Ø§Ù„ØµÙˆØ±Ø© Ù„Ù„ØªØºÙŠÙŠØ± Ø£Ùˆ Ø§Ù„Ø­Ø°Ù',
    'profile_photo': 'ØµÙˆØ±Ø© Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ',
    'upload_device': 'Ø±ÙØ¹ Ù…Ù† Ø§Ù„Ø¬Ù‡Ø§Ø²',
    'choose_gallery': 'Ø§Ø®ØªÙŠØ§Ø± Ù…Ù† Ø§Ù„Ù…Ø¹Ø±Ø¶',
    'take_photo': 'Ø§Ù„ØªÙ‚Ø§Ø· ØµÙˆØ±Ø©',
    'remove_photo': 'Ø­Ø°Ù Ø§Ù„ØµÙˆØ±Ø©',
    'select_image': 'Ø§Ø®ØªØ± Ù…Ù„Ù ØµÙˆØ±Ø©',
    'pick_gallery': 'Ø§Ø®ØªØ± Ù…Ù† Ø§Ù„Ù…Ø¹Ø±Ø¶',
    'use_camera': 'Ø§Ø³ØªØ®Ø¯Ù… Ø§Ù„ÙƒØ§Ù…ÙŠØ±Ø§',
    'delete_photo': 'Ø§Ø­Ø°Ù ØµÙˆØ±ØªÙƒ Ø§Ù„Ø­Ø§Ù„ÙŠØ©',
    'settings': 'Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª',
    'appearance': 'Ø§Ù„Ù…Ø¸Ù‡Ø±',
    'language': 'Ø§Ù„Ù„ØºØ©',
    'language_sub':
        'Ø§Ù„ØªØ¨Ø¯ÙŠÙ„ Ø¨ÙŠÙ† Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© ÙˆØ§Ù„Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©',
    'dark_mode': 'Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„Ø¯Ø§ÙƒÙ†',
    'dark_mode_sub': 'ØªØ¨Ø¯ÙŠÙ„ Ø§Ù„Ù…Ø¸Ù‡Ø± Ø§Ù„Ø¯Ø§ÙƒÙ† / Ø§Ù„ÙØ§ØªØ­',
    'privacy_mode': 'ÙˆØ¶Ø¹ Ø§Ù„Ø®ØµÙˆØµÙŠØ©',
    'privacy_mode_sub':
        'Ø¥Ø®ÙØ§Ø¡ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø­Ø³Ø§Ø³Ø© Ø¹Ù„Ù‰ Ø§Ù„Ø´Ø§Ø´Ø©',
    'current_lang': 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©',
    'switch_to': 'Switch to English',
    'notifications': 'Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª',
    'ai_searching': 'Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ ÙŠØ¨Ø­Ø«â€¦',
    'ai_no_match':
        'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù†ØªØ§Ø¦Ø¬. Ø¹Ø±Ø¶ Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ù†Ø¸Ù…Ø§Øª.',
    // â”€â”€ Forgot / Reset Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'forgot_password_title': 'Ù†Ø³ÙŠØª ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
    'forgot_password_sub':
        'Ø£Ø¯Ø®Ù„ Ø¨Ø±ÙŠØ¯Ùƒ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ ÙˆØ³Ù†Ø±Ø³Ù„ Ù„Ùƒ Ø±Ø§Ø¨Ø· Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„ØªØ¹ÙŠÙŠÙ†.',
    'send_reset_link': 'Ø¥Ø±Ø³Ø§Ù„ Ø±Ø§Ø¨Ø· Ø§Ù„Ø§Ø³ØªØ¹Ø§Ø¯Ø©',
    'check_email': 'ØªØ­Ù‚Ù‚ Ù…Ù† Ø¨Ø±ÙŠØ¯Ùƒ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
    'check_email_sub':
        'Ø§Ù†Ù‚Ø± Ø§Ù„Ø±Ø§Ø¨Ø· ÙÙŠ Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ Ù„Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ† ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±.',
    'resend_link': 'Ù„Ù… ØªØ³ØªÙ„Ù…Ù‡ØŸ Ø­Ø§ÙˆÙ„ Ù…Ø¬Ø¯Ø¯Ø§Ù‹',
    'back_to_login': 'Ø§Ù„Ø¹ÙˆØ¯Ø© Ù„ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„',
    'create_new_password': 'Ø¥Ù†Ø´Ø§Ø¡ ÙƒÙ„Ù…Ø© Ù…Ø±ÙˆØ± Ø¬Ø¯ÙŠØ¯Ø©',
    'new_password': 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©',
    'save_password': 'Ø­ÙØ¸ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
    'enter_email_hint': 'Ø£Ø¯Ø®Ù„ Ø¨Ø±ÙŠØ¯Ùƒ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
    'min_6_chars': 'Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ø¯Ù†Ù‰ 6 Ø£Ø­Ø±Ù',
    'repeat_password': 'Ø£Ø¹Ø¯ Ø¥Ø¯Ø®Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',

    // â”€â”€ OTP â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'verify_account': 'ØªØ­Ù‚Ù‚ Ù…Ù† Ø­Ø³Ø§Ø¨Ùƒ',
    'otp_sent_to':
        'Ø£Ø±Ø³Ù„Ù†Ø§ Ø±Ù…Ø²Ø§Ù‹ Ù…ÙƒÙˆÙ†Ø§Ù‹ Ù…Ù† 6 Ø£Ø±Ù‚Ø§Ù… Ø¥Ù„Ù‰',
    'verify_btn': 'ØªØ­Ù‚Ù‚ Ù…Ù† Ø§Ù„Ø­Ø³Ø§Ø¨',
    'resend_in': 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ø¥Ø±Ø³Ø§Ù„ Ø¨Ø¹Ø¯',
    'resend': 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ø¥Ø±Ø³Ø§Ù„',
    'no_code': 'Ù„Ù… ØªØ³ØªÙ„Ù… Ø§Ù„Ø±Ù…Ø²ØŸ ',

    // â”€â”€ QR Scanner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'scan_qr_title': 'Ø§Ù…Ø³Ø­ Ø±Ù…Ø² QR',
    'scan_qr_hint':
        'ÙˆØ¬Ù‘Ù‡ Ø§Ù„ÙƒØ§Ù…ÙŠØ±Ø§ Ù†Ø­Ùˆ Ø±Ù…Ø² QR\nÙ„Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø·Ù„Ø¨Ùƒ',
    'verifying_qr': 'Ø¬Ø§Ø±ÙŠ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§Ù„Ø±Ù…Ø²â€¦',
    'qr_success': 'ØªÙ… Ø¥ÙƒÙ…Ø§Ù„ Ø§Ù„Ø·Ù„Ø¨ Ø¨Ù†Ø¬Ø§Ø­!',
    'done_completed': 'ØªÙ… â€” Ø§ÙƒØªÙ…Ù„ Ø§Ù„Ø·Ù„Ø¨',
    'waiting_scan': 'Ø¨Ø§Ù†ØªØ¸Ø§Ø± Ø§Ù„Ù…Ø³Ø­â€¦',

    // â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'no_notifications': 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø¨Ø¹Ø¯.',
    'mark_all_read': 'ØªØ­Ø¯ÙŠØ¯ Ø§Ù„ÙƒÙ„ ÙƒÙ…Ù‚Ø±ÙˆØ¡',
  };
}
