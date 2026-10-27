# استودیو محتوا و جدول — Flutter Starter

این پروژه یک اسکلت اولیه فارسی (RTL) برای اندروید و وب است و workflow آماده GitHub Pages دارد.

## انتشار در GitHub و بررسی با Chrome

1. فایل ZIP را استخراج کنید.
2. در GitHub یک مخزن جدید **Public** بسازید، مثلاً `content-puzzle-studio`.
3. فایل‌های داخل پوشه پروژه را به مخزن اضافه کنید؛ پوشه مخفی `.github/workflows/deploy.yml` را هم حتماً اضافه کنید.
4. در مخزن به **Settings → Pages → Build and deployment → Source** بروید و `GitHub Actions` را انتخاب کنید.
5. به زبانه **Actions** بروید و منتظر بمانید workflow با نام `Build and deploy Flutter Web to GitHub Pages` موفق شود.
6. در **Settings → Pages** آدرس سایت منتشرشده را باز کنید. آدرس معمولاً شبیه `https://USERNAME.github.io/REPOSITORY/` است.

هر بار که روی شاخه `main` تغییرات push کنید، GitHub Actions نسخه وب را می‌سازد و منتشر می‌کند. Workflow مسیر base-href را از نام مخزن می‌سازد تا برنامه در GitHub Pages درست بارگذاری شود.

## اجرای محلی

پیش‌نیاز: Flutter stable و Chrome نصب باشد.

```bash
flutter create --platforms=android,web .
flutter pub get
flutter run -d chrome
```

برای ساخت نسخه release وب:
```bash
flutter build web --release
```

## امکانات پیاده‌سازی‌شده در این اسکلت
- داشبورد فارسی و راست‌چین
- ثبت، ویرایش و حذف محتوا
- دسته‌بندی و برچسب‌ها
- دو حالت ورودی: متن پایه با نشانه‌گذاری ساده و ویرایشگر بلوکی
- بلوک‌های متن، تصویر با URL، لینک و جدول توصیفی
- ثبت نوع جدول: کلمات متقاطع، پیدا کردن کلمات، سودوکو و جدول اختصاصی
- ذخیره محلی بین اجراها با `shared_preferences` (اندروید و وب)

## محدودیت‌های صریح نسخه اولیه
- ویرایشگر «متن غنی» در این اسکلت، ویرایشگر پایه با چند میانبر متنی است، نه ویرایشگر کامل WYSIWYG.
- بلوک تصویر/لینک/جدول فعلاً داده و URL را ثبت می‌کند؛ پیش‌نمایش بصری فایل‌ها هنوز پیاده‌سازی نشده است.
- ثبت جدول در حال حاضر مشخصات جدول را ذخیره می‌کند؛ الگوریتم تولید خودکار جدول کلمات متقاطع، جست‌وجوی کلمات، حل تعاملی سودوکو، راهنما، امتیاز و زمان‌سنج باید در مرحله بعد اضافه شوند.
- ذخیره‌سازی فعلی محلی و مناسب نمونه اولیه است؛ برای همگام‌سازی بین دستگاه‌ها، ورود کاربران و پشتیبان‌گیری، یک API و پایگاه‌داده سرور لازم است.
- GitHub Pages میزبان استاتیک است؛ برای استفاده از داده‌های مشترک بین کاربران یا دستگاه‌ها باید بک‌اند اضافه شود.

## معماری
- `lib/models/`: مدل‌های داده
- `lib/services/local_store.dart`: لایه ذخیره‌سازی قابل جایگزینی
- `lib/screens/home_screen.dart`: داشبورد، فهرست‌ها، فرم محتوا و فرم جدول
- `lib/main.dart`: تنظیمات برنامه، تم و جهت RTL
- `.github/workflows/deploy.yml`: ساخت خودکار نسخه وب و انتشار در GitHub Pages

## Schema پیشنهادی برای نسخه دیتابیس
- `contents(id, title, category, mode, body_json, created_at, updated_at)`
- `content_blocks(id, content_id, position, type, payload_json)`
- `content_tags(content_id, tag)`
- `puzzles(id, title, type, source_content_id, config_json, created_at)`
- `puzzle_entries(id, puzzle_id, answer, clue, direction, row, col)`
- `puzzle_attempts(id, puzzle_id, user_id, answers_json, score, duration_seconds, completed_at)`

این schema منطقی است و در نسخه فعلی به‌عنوان migration اجرا نشده؛ ذخیره‌سازی فعلی با SharedPreferences و JSON انجام می‌شود.
