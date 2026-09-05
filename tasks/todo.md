# Task Log

Current and completed tasks. Updated each session.

---

## Session 2026-09-05 — 動作偵測驗證實驗室（Motion Lab）

### Plan
- [x] 討論「動作辨識 + RPG 打怪」構想，評估後決定先做最小可驗證的偵測 spike，
      RPG 遊戲層（角色/怪物/地圖/戰鬥）全部延後，等真機驗證通過再規劃
- [x] 確認 Google ML Kit Pose Detection 完全離線（Android/iOS 都是 build time 靜態打包模型，
      無需 Google Play Services 動態下載）
- [x] 新增 `camera ^0.12.1`、`google_mlkit_pose_detection ^0.16.1`
- [x] `lib/features/motion_lab/detection/`：6 個動作（深蹲/伏地挺身/仰臥起坐/開合跳/抬膝/
      原地衝拳）的姿勢偵測邏輯，純 Dart 無 Flutter/Camera/ML Kit 依賴，共用一個
      hysteresis 計數狀態機（`HysteresisRepCounter`），全部可單元測試
- [x] `lib/features/motion_lab/camera/`：`CameraImage`→ML Kit `InputImage` 轉換、
      ML Kit `Pose`→本專案 `PoseFrame` 轉換
- [x] `MotionLabScreen`：獨立分頁（不用 IndexedStack，避免相機在其他分頁時就被建立/啟動）、
      相機預覽 + 骨架疊加 + 即時計數 HUD，純 `StatefulWidget`，不接 Riverpod、不寫入
      `WorkoutSession`/`WorkoutSet`、不做任何持久化
- [x] Android `minSdk` 24（camera 需求）、`AndroidManifest.xml` 加相機權限；
      iOS `IPHONEOS_DEPLOYMENT_TARGET` 13.0→15.5（ML Kit 需求）、`Info.plist` 加
      `NSCameraUsageDescription`
- [x] `test/unit/motion_lab/`：`HysteresisRepCounter` 狀態機測試（正常循環計數、
      閾值抖動不重複計數、半程未達閾值不計數、null 訊號不誤判、reset）+ 6 個
      detector 的訊號抽取方向測試
- [x] CLAUDE.md 新增 Motion Lab 章節，明確標註「實驗性、與正式六招/訓練紀錄完全脫鉤」
- [x] 版本 bump v1.7.0 → v1.8.0（+19 → +20）

### Outcome
原本討論方向是完整版 RPG（世界地圖+角色養成，動作次數同步寫入正式訓練紀錄），
評估後認為核心風險（手機鏡頭姿勢辨識準不準）完全無法在開發環境驗證、只能真機測試，
若先蓋好整套遊戲系統風險過高，因此大幅縮小這次範圍，只做偵測驗證本身，且完全獨立
於現有六招介面（新分頁、無資料同步、無持久化），把「值不值得做成 RPG」這個更大的
產品決定延後到真機驗證之後。6 個目標動作特意跟 ConvictSix 原本六招脫鉤（深蹲/伏地
挺身重疊，其餘 4 個是全新動作），因為引體向上/舉腿需要單槓、橋式/倒立推對靜態鏡頭
不友善。`CameraImage`→`InputImage` 轉換與骨架疊加座標映射是全案風險最高的部分，
在無相機硬體的 sandbox 裡完全無法驗證，需要透過既有 `mobile_ci_cd.yml` 出的測試版
在真機上實測；6 個動作的角度/比例閾值也都是初始猜測值，預期實測後要調整。

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
