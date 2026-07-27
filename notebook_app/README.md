# دفتري - تطبيق دفتر الملاحظات المتقدم

<div dir="rtl">

## 📱 نظرة عامة

**دفتري** تطبيق دفتر ملاحظات متكامل ومخصص للغة العربية، مبني بـ Flutter.

### المميزات الرئيسية

- ✏️ **محرر نصوص غني** - تنسيق متقدم مع دعم RTL الكامل
- 🎨 **ألوان وقوالب** - تخصيص الملاحظات بالألوان والقوالب
- 📤 **تصدير متعدد الصيغ** - PDF, TXT, JSON, HTML, Markdown, CSV, ZIP
- 📥 **استيراد الملفات** - استيراد من JSON, TXT, CSV, ZIP, Markdown
- 🔒 **حماية بكلمة مرور** - تأمين الملاحظات الحساسة
- 📌 **تثبيت وتفضيل** - تنظيم الملاحظات المهمة
- 🏷️ **تصنيفات ووسوم** - تنظيم الملاحظات بسهولة
- 🌙 **وضع ليلي** - دعم الوضع الداكن
- 🔍 **بحث متقدم** - البحث في العنوان والمحتوى والوسوم
- 📋 **قوالب مخصصة** - إنشاء قوالب بحقول ديناميكية

## 🏗️ هيكل المشروع

```
lib/
├── main.dart                          # نقطة الدخول
├── constants/
│   ├── app_colors.dart               # نظام الألوان
│   └── app_themes.dart               # الثيمات
├── models/
│   ├── note_model.dart               # نموذج الملاحظات
│   └── template_model.dart           # نموذج القوالب
├── providers/
│   └── note_provider.dart            # إدارة الحالة
├── services/
│   └── database_service.dart         # قاعدة البيانات SQLite
├── utils/
│   ├── exporters/
│   │   └── export_service.dart       # خدمة التصدير
│   └── importers/
│       └── import_service.dart       # خدمة الاستيراد
├── screens/
│   ├── home_screen.dart              # الشاشة الرئيسية
│   ├── editor/
│   │   └── rich_note_editor_screen.dart  # محرر النصوص
│   ├── export/
│   │   └── export_screen.dart        # شاشة التصدير
│   └── template_designer/
│       └── template_designer_screen.dart # مصمم القوالب
└── widgets/
    ├── note_card.dart                # بطاقة الملاحظة
    └── custom_app_bar.dart           # شريط العنوان
```

## 🚀 تشغيل المشروع

### المتطلبات
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### خطوات التشغيل

```bash
# 1. استنساخ المستودع
git clone https://github.com/alhlwqya-debug/Notebook.git
cd Notebook/notebook_app

# 2. تثبيت التبعيات
flutter pub get

# 3. تشغيل التطبيق
flutter run
```

## 📦 المكتبات المستخدمة

| المكتبة | الاستخدام |
|---------|-----------|
| `sqflite` | قاعدة بيانات SQLite محلية |
| `provider` | إدارة الحالة |
| `flutter_quill` | محرر النصوص الغني |
| `pdf` + `printing` | توليد وتصدير PDF |
| `file_picker` | اختيار الملفات |
| `share_plus` | مشاركة الملفات |
| `archive` | ضغط/فك ضغط ZIP |
| `csv` | قراءة وكتابة CSV |
| `flutter_colorpicker` | منتقي الألوان |
| `flutter_staggered_grid_view` | عرض شبكي متناسق |

## 🗄️ قاعدة البيانات

يستخدم التطبيق SQLite محلياً مع ثلاثة جداول:
- **notes** - الملاحظات
- **categories** - التصنيفات
- **custom_templates** - القوالب المخصصة

## 🎨 الخطوط المدعومة

- **Tajawal** - الخط الافتراضي
- **Cairo** - خط العناوين
- **Amiri** - خط أكاديمي

</div>
