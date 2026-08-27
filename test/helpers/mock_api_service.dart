// ignore_for_file: subtype_of_sealed_class
import 'package:mockito/annotations.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/services/organization_service.dart';
import 'package:aidora/services/profile_api_service.dart';

@GenerateMocks([
  ApiService,
  AuthService,
  RequestsApiService,
  OrganizationService,
  ProfileApiService,
])
void main() {}
