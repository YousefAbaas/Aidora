/// fixtures.dart
///
/// Centralised, production-realistic fake data used across the entire test
/// suite.  Every value matches the exact JSON shape the Django backend sends.
library fixtures;

// ─────────────────────────────────────────────────────────────────────────────
// Auth
// ─────────────────────────────────────────────────────────────────────────────

const loginSuccessJson = {
  'access':  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test_access',
  'refresh': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test_refresh',
  'role':    'refugee',
  'email':   'ahmed@example.com',
};

const loginVolunteerJson = {
  'access':  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.vol_access',
  'refresh': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.vol_refresh',
  'role':    'volunteer',
  'email':   'volunteer@example.com',
};

const loginOrgJson = {
  'access':  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.org_access',
  'refresh': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.org_refresh',
  'role':    'organization',
  'email':   'org@ngo.com',
};

const registerSuccessJson = {
  'email': 'newuser@example.com',
  'message': 'OTP sent to email.',
};

const loginErrorJson = {
  'detail': 'No active account found with the given credentials',
};

// ─────────────────────────────────────────────────────────────────────────────
// Profile
// ─────────────────────────────────────────────────────────────────────────────

const refugeeProfileJson = {
  'full_name':         'Ahmed Al-Masri',
  'email':             'ahmed@example.com',
  'phone_number':      '+970599000001',
  'profile_image':     'http://127.0.0.1:8000/media/profiles/ahmed.jpg',
  'nationality':       'Palestinian',
  'date_of_birth':     '1990-05-15',
  'unhcr_number':      'UNH-123456',
  'household_size':    4,
  'arrival_date':      '2023-01-10',
};

const uploadImageSuccessJson = {
  'message':       'Profile image updated successfully',
  'profile_image': 'http://127.0.0.1:8000/media/profiles/new_photo.jpg',
};

// ─────────────────────────────────────────────────────────────────────────────
// Requests list  (GET /api/requests/list/)
// ─────────────────────────────────────────────────────────────────────────────

const requestsListJson = {
  'counts': {
    'All':       8,
    'Approved':  3,
    'Rejected':  3,
    'Pending':   1,
    'Completed': 1,
  },
  'data': {
    'Approved': [
      {
        'id':          20,
        'status':      'approved',
        'ref':         'REF: 6',
        'service_name':'Child Protection',
        'sector':      'Center A',
        'approved_at': '14 days ago',
      },
      {
        'id':          25,
        'status':      'approved',
        'ref':         'REF: 6',
        'service_name':'Education',
        'sector':      'Center A',
        'approved_at': '10 days ago',
      },
    ],
    'Rejected': [
      {
        'id':              24,
        'status':          'rejected',
        'ref':             'REF: 6',
        'service_name':    'Psychological Support',
        'rejection_reason':'Missing documents',
      },
    ],
    'Pending': [
      {
        'id':         27,
        'status':     'pending',
        'ref':        'REF: 6',
        'service_name':'Child Protection',
        'created_at': 'Submitted 10d ago',
      },
    ],
    'Completed': [
      {
        'id':         23,
        'status':     'completed',
        'ref':        'REF: 6',
        'service_name':'Education',
        'received_at':'Pickup 21d ago, 05 PM',
      },
    ],
  },
};

const requestsListFilteredApprovedJson = {
  'counts': {
    'All': 8, 'Approved': 3, 'Rejected': 3, 'Pending': 1, 'Completed': 1,
  },
  'data': [
    {
      'id':          20,
      'status':      'approved',
      'ref':         'REF: 6',
      'service_name':'Child Protection',
      'sector':      'Center A',
      'approved_at': '14 days ago',
    },
  ],
};

const requestDetailsJson = {
  'ref':               '#REF-6',
  'organization_name': 'UNICEF',
  'organization_logo': 'http://127.0.0.1:8000/media/organizations/logos/UNICEF.png',
  'service_name':      'Education',
  'status':            'completed',
  'service_type':      'Education',
  'family_members':    3,
  'created_at':        '21d ago, April 11th, 2026',
  'received_at':       '05:26 PM',
  'sector':            'Center A',
};

const submitRequestSuccessJson = {
  'message': 'Request submitted successfully',
};

// ─────────────────────────────────────────────────────────────────────────────
// Organizations
// ─────────────────────────────────────────────────────────────────────────────

const orgCardsJson = {
  'count':    2,
  'next':     null,
  'previous': null,
  'results': [
    {
      'id':   1,
      'name': 'UNICEF',
      'logo': 'http://127.0.0.1:8000/media/organizations/logos/UNICEF.png',
    },
    {
      'id':   2,
      'name': 'World Food Programme',
      'logo': 'http://127.0.0.1:8000/media/organizations/logos/WFP.png',
    },
  ],
};

const orgDetailJson = {
  'name':             'UNICEF',
  'title':            'United Nations Children\'s Fund',
  'logo':             'http://127.0.0.1:8000/media/organizations/logos/UNICEF.png',
  'about':            'UNICEF works for children\'s rights worldwide.',
  'official_website': 'https://unicef.org',
  'contact_email':    'info@unicef.org',
  'impact_image_1':   null,
  'impact_image_2':   null,
  'services': [
    {'id': 1, 'name': 'Child Protection', 'icon': 'shield'},
    {'id': 2, 'name': 'Education',        'icon': 'school'},
  ],
  'target_groups': ['Children', 'Women', 'Families'],
};

const orgServicesJson = [
  {'id': 1, 'name': 'Child Protection', 'icon': 'shield'},
  {'id': 2, 'name': 'Education',        'icon': 'school'},
  {'id': 3, 'name': 'Water and Sanitation', 'icon': 'water_drop'},
];

// ─────────────────────────────────────────────────────────────────────────────
// Volunteer
// ─────────────────────────────────────────────────────────────────────────────

const volunteerStateJson = {
  'profile_completed':   true,
  'application_status':  'approved',
};

const volunteerQrJson = {
  'display_name':     'Alex Rivera',
  'qr_image_base64':  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
};

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Single approved [RequestModel]-compatible JSON object.
const singleApprovedRequestJson = {
  'id':           20,
  'status':       'approved',
  'ref':          'REF: 6',
  'service_name': 'Child Protection',
  'sector':       'Center A',
  'approved_at':  '14 days ago',
};

const singleRejectedRequestJson = {
  'id':              24,
  'status':          'rejected',
  'ref':             'REF: 6',
  'service_name':    'Psychological Support',
  'rejection_reason':'Missing documents',
};

const singlePendingRequestJson = {
  'id':          27,
  'status':      'pending',
  'ref':         'REF: 6',
  'service_name':'Child Protection',
  'created_at':  'Submitted 10d ago',
};
