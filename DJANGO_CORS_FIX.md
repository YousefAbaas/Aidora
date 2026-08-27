# حل مشاكل CORS في Django — دليل شامل

## المشاكل التي يحلها هذا الدليل
- ❌ API calls تُعيد خطأ أو لا تعمل من المتصفح
- ❌ الصور لا تظهر في Chrome / Edge
- ❌ Endpoint not found عند الضغط على الأزرار

---

## الخطوة 1: تثبيت django-cors-headers

```bash
pip install django-cors-headers
```

---

## الخطوة 2: تعديل settings.py

```python
INSTALLED_APPS = [
    'corsheaders',     # ← أضف هذا قبل django.contrib.staticfiles
    ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',   # ← يجب أن يكون الأول
    'django.middleware.common.CommonMiddleware',
    ...
]

# ── CORS للتطوير المحلي ────────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# ── إضافة CORS headers على ملفات الميديا (الصور) ──────────────
# هذا ضروري لإظهار صور البروفايل في المتصفح
CORS_URLS_REGEX = r'^.*$'  # يطبق CORS على جميع المسارات بما فيها /media/

# ── Headers المسموح بها ────────────────────────────────────────
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'origin',
    'x-requested-with',
]

CORS_ALLOW_METHODS = [
    'DELETE', 'GET', 'OPTIONS', 'PATCH', 'POST', 'PUT',
]
```

---

## الخطوة 3: إضافة CORS على ملفات الميديا (للصور)

في `urls.py` الرئيسي:

```python
from django.conf import settings
from django.conf.urls.static import static
from corsheaders.signals import check_request_enabled
from corsheaders.middleware import ACCESS_CONTROL_ALLOW_ORIGIN

# أضف هذا لملفات الميديا
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

---

## الخطوة 4: إعادة تشغيل Django

```bash
python manage.py runserver
```

---

## جدول العناوين حسب المنصة

| المنصة | عنوان Django الصحيح |
|--------|---------------------|
| Flutter Web (Chrome) | `http://127.0.0.1:8000` |
| Android Emulator | `http://10.0.2.2:8000` |
| iOS Simulator | `http://127.0.0.1:8000` |
| Real Device (WiFi) | `http://192.168.x.x:8000` |

لتغيير العنوان: `lib/services/api_constants.dart` → `_realDeviceIp`
