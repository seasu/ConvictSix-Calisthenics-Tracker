# Task Log

Current and completed tasks. Updated each session.

---

## Session 2026-07-07 — Android/iOS CI/CD + Firebase Crashlytics（參考 Magic-Sticker）

### Plan
- [x] 安裝 Flutter SDK 到 /opt/flutter（環境內原本沒有工具鏈）
- [x] `flutter create --platforms=android,ios --org com.convictsix .` 產生並提交 android/ ios/
- [x] applicationId / bundle ID 統一為 com.convictsix.calisthenics_tracker
- [x] 加入 firebase_core + firebase_crashlytics，main.dart 接上全域錯誤處理（僅 native，web 跳過）
- [x] 產出 assets/app_icon.png 佔位圖示（沿用 kBgBase/kPrimary/tier 色票）+ flutter_launcher_icons 設定
- [x] android/app/build.gradle.kts、settings.gradle.kts 接上 Firebase Gradle plugin + release keystore 簽章
- [x] 建立 google-services.json / GoogleService-Info.plist 佔位檔（CI 用 secret 覆寫）
- [x] 新增 .github/workflows/mobile_ci_cd.yml：dart-analyze → android-build（簽章 APK/AAB）→ GitHub Release + Firebase App Distribution；ios-build（TestFlight + Firebase App Distribution）
- [x] CLAUDE.md 補上 Firebase 技術棧、repo layout、CI/CD 章節與所需 GitHub Secrets 清單
- [x] 版本 bump v1.6.0 → v1.7.0（+18 → +19）

### Outcome
比對 Magic-Sticker 的 main_build.yml 架構後裁減：ConvictSix 沒有帳號系統/Google Sign-In/
ML Kit，所以不需要 REVERSED_CLIENT_ID 注入與 Sign-in-with-Apple entitlement 檢查。使用者
確認尚未建立 Play Console 上架資料，因此 Play Store 自動上傳先不接（workflow 內留了說明
如何比照 Magic-Sticker 補上）。本地驗證：`dart analyze --fatal-infos` 0 issue、
`flutter test` 全過、以本地 Gradle 8.14.3 嘗試 evaluate build.gradle.kts / settings.gradle.kts
確認語法正確（實際卡在 sandbox 環境無法下載 GitHub release 版的 Gradle 9.1.0，非設定檔問題，
GitHub Actions runner 上不會有此限制）。web 版 CI（deploy-pages.yml）未受影響，Firebase 初始化
用 `kIsWeb` 排除。

## Session 2026-06-26 — 精簡訓練規劃以提升持續率

### Plan
- [x] 預設排程從一週 5 天改成 CC「Good Behavior」一週 3 天、每天 2 招
- [x] 新使用者預設訓練強度從「晉級（最難）」改為「入門」
- [x] 計畫設定頁強度三選一重新框定為「今日目標 + 升式門檻」階梯
- [x] 計畫設定頁每招加上「下一式」預覽（最高式顯示 🏆）
- [x] 版本 bump v1.5.8 → v1.6.0（+16 → +17）

### Outcome
從「降低起點門檻、減少決策摩擦、隨時看得到下一個目標」三個方向精簡。
改動集中在 training_schedule.dart / user_progression.dart /
program_setup_screen.dart，未動 60 招資料與 workout 流程，相依面風險低。
Flutter 工具鏈在 remote 環境不可用，analyze/test 交由 CI 驗證。

<!-- Add new tasks here using the format below.

## Session YYYY-MM-DD — <short description>

### Plan
- [ ] Step 1
- [ ] Step 2

### Outcome
Summary of what was done and any follow-up notes.

-->
