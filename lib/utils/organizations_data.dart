import '../models/organization.dart';

/// Service-name â†’ filter-key mapping.
/// Used in FilterScreen and OrganizationsListScreen to find matching orgs.
const Map<String, String> kServiceToFilterKey = {
  'Child Protection': 'protection',
  'Education': 'education',
  'Water and Sanitation': 'water',
  'Protection and safety': 'protection',
  'Healthcare and medical services': 'health',
  'Food assistance and essential needs': 'food',
  'Emergency shelter and crisis support': 'shelter',
  'Assistance for children and vulnerable groups': 'protection',
  'Food Assistance': 'food',
  'Malnutrition Prevention': 'health',
  'Logistics Support': 'logistics',
  'Maternal Nutrition': 'health',
  'Food Security & Development': 'food',
  'Emergency Response': 'emergency',
  'Disease Control': 'health',
  'Healthcare Systems': 'health',
  'Vaccination': 'vaccination',
  'Mental Health': 'health',
  'Health Education': 'education',
  'Medical Assistance': 'health',
  'Food Distribution': 'food',
  'Psychological Support': 'health',
  'Disaster Response': 'emergency',
  'Health Services': 'health',
  'Refugee & IDP Protection': 'protection',
  'Temporary Shelter': 'shelter',
  'Legal Assistance': 'legal',
  'Emergency Relief': 'emergency',
  // INTERSOS specific
  'Protection Services': 'protection',
  'Health Assistance': 'health',
  'Shelter Support': 'shelter',
  'Legal Aid': 'legal',
  'Emergency Food Assistance': 'food',
};

/// Each org's categories are derived from its actual services
/// (one key per distinct service type it provides).
final List<Organization> organizationsData = [
  Organization(
    id: 'unicef',
    name: 'UNICEF',
    subtitle: 'Child protection - Education',
    // Services: Child Protectionâ†’protection, Educationâ†’education,
    //           Water and Sanitationâ†’water, Health Educationâ†’education
    categories: ['protection', 'education', 'water', 'health'],
  ),
  Organization(
    id: 'intersos',
    name: 'INTERSOS',
    subtitle: 'Emergency response - Protection - Health',
    // Services: Protection Servicesâ†’protection, Health Assistanceâ†’health,
    //           Shelter Supportâ†’shelter, Emergency Reliefâ†’emergency,
    //           Legal Aidâ†’legal, Emergency Food Assistanceâ†’food
    categories: [
      'protection',
      'health',
      'shelter',
      'emergency',
      'legal',
      'food'
    ],
  ),
  Organization(
    id: 'wfp',
    name: 'World Food Programme',
    subtitle: 'World Food Programme',
    // Services: Food Assistanceâ†’food, Malnutrition Preventionâ†’health,
    //           Logistics Supportâ†’logistics, Maternal Nutritionâ†’health,
    //           Food Security & Developmentâ†’food
    categories: ['food', 'health', 'logistics'],
  ),
  Organization(
    id: 'unhcr',
    name: 'UNHCR',
    subtitle: 'United Nations High Commissioner for Refugees',
    // Services: Refugee & IDP Protectionâ†’protection, Temporary Shelterâ†’shelter,
    //           Legal Assistanceâ†’legal, Emergency Reliefâ†’emergency
    categories: ['protection', 'shelter', 'legal', 'emergency'],
  ),
  Organization(
    id: 'who',
    name: 'World Health Organization',
    subtitle: 'World Health Organization',
    // Services: Emergency Responseâ†’emergency, Disease Controlâ†’health,
    //           Healthcare Systemsâ†’health, Vaccinationâ†’vaccination,
    //           Mental Healthâ†’health
    categories: ['emergency', 'health', 'vaccination'],
  ),
  Organization(
    id: 'red_crescent',
    name: 'Red Crescent',
    subtitle: 'Emergency aid - community support - disaster response',
    // Services: Medical Assistanceâ†’health, Food Distributionâ†’food,
    //           Psychological Supportâ†’health, Disaster Responseâ†’emergency,
    //           Health Servicesâ†’health
    categories: ['health', 'food', 'emergency'],
  ),
];
