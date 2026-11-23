# Kellaf Chat — کلاف چت

یک پیام‌رسان مدرن دوکاربره و گروهی برای **Android** و **Windows**، با هویت بصری بنفش-صورتی و لوگوی حرف **K**.

## امکانات نسخه فعلی
- رابط کاربری اختصاصی و واکنش‌گرا
- تم روشن، تیره و سیستم
- انتخاب رنگ اصلی و ذخیره تنظیمات
- لیست گفتگو، مخاطب‌ها، تماس‌ها و تنظیمات
- نمای چت دونفره و ارسال پیام نما��شی
- معماری آماده برای اتصال به سرور WebSocket

## اجرای برنامه

> نیاز است Flutter با پشتیبانی Android و Windows نصب باشد.

```bash
flutter pub get
flutter create --platforms=android,windows .
flutter run -d windows
flutter run -d android
```

## ساخت APK و exe

```bash
flutter build apk --release
flutter build windows --release
```

محصول‌های خروجی در `build/app/outputs/flutter-apk/` و `build/windows/x64/runner/Release/` قرار می‌گیرند.
