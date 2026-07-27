# دفتري - Notebook App

تطبيق دفتر ملاحظات متقدم ومخصص للغة العربية، مبني بـ Flutter مع دعم تصدير متعدد الصيغ وقوالب مخصصة.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)

## Flutter App (notebook_app/)

The main deliverable is a Flutter mobile app located at `notebook_app/`. To run it:

```bash
cd notebook_app
flutter pub get
flutter run
```

## Stack

- **Mobile:** Flutter + Dart
- **Local DB:** SQLite via sqflite
- **State Management:** Provider
- **Rich Text Editor:** flutter_quill
- **Export:** pdf, printing, csv, archive
- **Workspace:** pnpm monorepo, Node.js 24, TypeScript 5.9
- **API:** Express 5, PostgreSQL + Drizzle ORM

## Where things live

- `notebook_app/` — Flutter app (main deliverable)
- `notebook_app/lib/` — Dart source code
- `notebook_app/lib/models/` — NoteModel, TemplateModel
- `notebook_app/lib/screens/` — Home, Editor, Export, TemplateDesigner
- `notebook_app/lib/services/` — DatabaseService (SQLite)
- `notebook_app/lib/utils/` — ExportService, ImportService
- `notebook_app/lib/providers/` — NoteProvider (state management)
- `artifacts/api-server/` — Express API server
- `lib/api-spec/openapi.yaml` — API contracts source of truth

## Architecture decisions

- Clean Architecture: Presentation → Domain → Data layers
- Provider for state management (simpler than BLoC for this scope)
- SQLite for local-first storage (no backend required for core features)
- Quill Delta format for rich text storage (JSON-serializable)
- RTL-first design with Tajawal/Cairo/Amiri Arabic fonts

## Product

دفتري تطبيق دفتر ملاحظات يتيح:
- إنشاء وتحرير الملاحظات بتنسيقات نصية متقدمة
- تصدير الملاحظات بـ 7 صيغ (PDF, TXT, JSON, HTML, MD, CSV, ZIP)
- استيراد الملفات بجميع الصيغ المدعومة
- حماية الملاحظات بكلمة مرور
- تنظيم بالتصنيفات والألوان والوسوم
- قوالب مخصصة بحقول ديناميكية

## User preferences

_Populate as you build — explicit user instructions worth remembering across sessions._

## Gotchas

- Fonts (Tajawal, Cairo, Amiri) must be added manually to `notebook_app/assets/fonts/` before building
- Run `flutter pub get` before any flutter commands
- Android minSdkVersion is 21 (Android 5.0+)

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
- GitHub repo: https://github.com/alhlwqya-debug/Notebook
