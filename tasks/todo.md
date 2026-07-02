# Task Log

Current and completed tasks. Updated each session.

---

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
