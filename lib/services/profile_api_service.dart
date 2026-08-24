
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../utils/image_url_helper.dart';
import 'api_client.dart';
import 'api_constants.dart';
import 'api_service.dart';
import 'auth_storage.dart';
import 'upload_helper.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ProfileApiService
/// ─────────────────────────────────────────────────────────────────────────────
class ProfileApiService {
ProfileApiService._(this._api);

static final ProfileApiService instance =
ProfileApiService._(ApiService.instance);

/// Constructor used by tests to inject a fake API client.
ProfileApiService._withApi(ApiClient api) : _api = api;

/// Creates a ProfileApiService backed by the supplied [ApiClient].
factory ProfileApiService.testInstance(ApiClient api) =>
ProfileApiService._withApi(api);

static ProfileApiService? _override;

/// Override the service during tests.
static void overrideForTest(ProfileApiService service) {
_override = service;
}

/// Remove the test override.
static void resetOverride() {
_override = null;
}

/// Service used by production code and tests.
///
/// Production:
///   ProfileApiService.effective == instance
///
/// Tests:
///   ProfileApiService.effective == injected fake instance
static ProfileApiService get effective => _override ?? instance;

final ApiClient _api;

// ───────────────────────────────────────────────────────────────────────────
// Auth / profile state
// ───────────────────────────────────────────────────────────────────────────

/// GET /api/auth/me/
///
/// Response:
/// {
///   "role": "refugee",
///   "profile_completed": true
/// }
Future<MeResult> checkMe() async {
final r = await _api.get(
ApiConstants.authMe,
requiresAuth: true,
);

if (!r.isSuccess) {
return MeResult.error(
r.errorMessage ?? 'Failed',
);
}

try {
final d = r.data as Map<String, dynamic>;

return MeResult.success(
role: d['role'] as String? ?? '',
profileCompleted:
d['profile_completed'] as bool? ?? false,
);
} catch (e) {
return MeResult.error(
'Parse error: $e',
);
}
}

/// PATCH /api/auth/refugees/complete-profile/
Future<CompleteProfileResult> completeProfile({
required String gender,
required String dateOfBirth,
required String location,
required bool consentGiven,
required List<Map<String, dynamic>> familyMembers,
}) async {
final r = await _api.patch(
ApiConstants.completeProfile,
requiresAuth: true,
body: {
'gender': gender,
'date_of_birth': dateOfBirth,
'location': location,
'consent_given': consentGiven,
'family_members': familyMembers,
},
);

if (!r.isSuccess) {
return CompleteProfileResult.error(
r.errorMessage ?? 'Failed',
);
}

return CompleteProfileResult.success();
}

/// GET /api/auth/profile/refugee/
Future<RefugeeProfileResult> fetchRefugeeProfile() async {
final r = await _api.get(
ApiConstants.refugeeProfile,
requiresAuth: true,
);

if (!r.isSuccess) {
return RefugeeProfileResult.error(
r.errorMessage ?? 'Failed',
);
}

try {
return RefugeeProfileResult.success(
RefugeeProfileModel.fromJson(
r.data as Map<String, dynamic>,
),
);
} catch (e) {
return RefugeeProfileResult.error(
'Parse error: $e',
);
}
}

// ───────────────────────────────────────────────────────────────────────────
// Profile image
// ───────────────────────────────────────────────────────────────────────────

/// PATCH /api/auth/profile/upload-image/
///
/// Web-compatible:
/// reads XFile bytes through [buildImageFile].
///
/// Native:
/// buildImageFile can use the native file path.
Future<UploadImageResult> uploadProfileImageXFile(
dynamic xfile,
) async {
try {
final url = Uri.parse(
'${ApiConstants.baseUrl}'
'${ApiConstants.uploadProfileImage}',
);

final token = AuthStorage.getAccessToken();

final request = http.MultipartRequest(
'PATCH',
url,
);

if (token != null && token.isNotEmpty) {
request.headers['Authorization'] =
'Bearer $token';
}

final file = await buildImageFile(
'profile_image',
xfile,
);

request.files.add(file);

debugPrint(
'📸 Uploading to $url field=profile_image',
);

final streamed = await request
    .send()
    .timeout(
const Duration(seconds: 30),
);

final response =
await http.Response.fromStream(streamed);

debugPrint(
'📸 Response ${response.statusCode}: '
'${response.body}',
);

if (response.statusCode >= 200 &&
response.statusCode < 300) {
final d =
jsonDecode(response.body)
as Map<String, dynamic>;

final raw =
d['profile_image'] as String? ?? '';

if (raw.isNotEmpty) {
return UploadImageResult.success(
ImageUrlHelper.fix(raw),
);
}

return UploadImageResult.error(
'No image URL in response',
);
}

return UploadImageResult.error(
'Upload failed '
'(${response.statusCode}): '
'${response.body}',
);
} catch (e) {
return UploadImageResult.error(
'Upload error: $e',
);
}
}

/// DELETE /api/auth/profile/upload-image/
Future<DeleteImageResult> deleteProfileImage() async {
final r = await _api.delete(
ApiConstants.uploadProfileImage,
requiresAuth: true,
);

if (r.isSuccess) {
return DeleteImageResult.success();
}

return DeleteImageResult.error(
r.errorMessage ??
'Failed to delete image',
);
}
}

// ─────────────────────────────────────────────────────────────────────────────
// Result types
// ─────────────────────────────────────────────────────────────────────────────

class MeResult {
final bool isSuccess;
final String role;
final bool profileCompleted;
final String? errorMessage;

const MeResult._({
required this.isSuccess,
this.role = '',
this.profileCompleted = false,
this.errorMessage,
});

factory MeResult.success({
required String role,
required bool profileCompleted,
}) {
return MeResult._(
isSuccess: true,
role: role,
profileCompleted: profileCompleted,
);
}

factory MeResult.error(String msg) {
return MeResult._(
isSuccess: false,
errorMessage: msg,
);
}
}

class CompleteProfileResult {
final bool isSuccess;
final String? errorMessage;

const CompleteProfileResult._({
required this.isSuccess,
this.errorMessage,
});

factory CompleteProfileResult.success() {
return const CompleteProfileResult._(
isSuccess: true,
);
}

factory CompleteProfileResult.error(String msg) {
return CompleteProfileResult._(
isSuccess: false,
errorMessage: msg,
);
}
}

class RefugeeProfileResult {
final bool isSuccess;
final RefugeeProfileModel? data;
final String? errorMessage;

const RefugeeProfileResult._({
required this.isSuccess,
this.data,
this.errorMessage,
});

factory RefugeeProfileResult.success(
RefugeeProfileModel d,
) {
return RefugeeProfileResult._(
isSuccess: true,
data: d,
);
}

factory RefugeeProfileResult.error(String msg) {
return RefugeeProfileResult._(
isSuccess: false,
errorMessage: msg,
);
}
}

class UploadImageResult {
final bool isSuccess;
final String imageUrl;
final String? errorMessage;

const UploadImageResult._({
required this.isSuccess,
this.imageUrl = '',
this.errorMessage,
});

factory UploadImageResult.success(String url) {
return UploadImageResult._(
isSuccess: true,
imageUrl: url,
);
}

factory UploadImageResult.error(String msg) {
return UploadImageResult._(
isSuccess: false,
errorMessage: msg,
);
}
}

class DeleteImageResult {
final bool isSuccess;
final String? errorMessage;

const DeleteImageResult._({
required this.isSuccess,
this.errorMessage,
});

factory DeleteImageResult.success() {
return const DeleteImageResult._(
isSuccess: true,
);
}

factory DeleteImageResult.error(String msg) {
return DeleteImageResult._(
isSuccess: false,
errorMessage: msg,
);
}
}

// ─────────────────────────────────────────────────────────────────────────────
// Refugee profile model
// ─────────────────────────────────────────────────────────────────────────────

class RefugeeProfileModel {
final String refugeeId;
final String? profileImage;
final String fullName;
final String location;
final String sectorName;
final int childrenCount;
final int elderlyCount;
final int disabledCount;
final int womenCount;
final int totalFamilyMembers;

const RefugeeProfileModel({
required this.refugeeId,
required this.fullName,
required this.location,
required this.sectorName,
required this.childrenCount,
required this.elderlyCount,
required this.disabledCount,
required this.womenCount,
required this.totalFamilyMembers,
this.profileImage,
});

factory RefugeeProfileModel.fromJson(
Map<String, dynamic> j,
) {
final fixedImage =
ImageUrlHelper.fix(
j['profile_image'] as String?,
);

return RefugeeProfileModel(
refugeeId:
j['refugee_id'] as String? ?? '',
profileImage:
fixedImage.isEmpty ? null : fixedImage,
fullName:
j['full_name'] as String? ?? '',
location:
j['location'] as String? ?? '',
sectorName:
j['sector_name'] as String? ?? '',
childrenCount:
(j['children_count'] as num? ?? 0).toInt(),
elderlyCount:
(j['elderly_count'] as num? ?? 0).toInt(),
disabledCount:
(j['disabled_count'] as num? ?? 0).toInt(),
womenCount:
(j['women_count'] as num? ?? 0).toInt(),
totalFamilyMembers:
(j['total_family_members'] as num? ?? 0)
    .toInt(),
);
}
}
