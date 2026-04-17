[English](README.md) | [繁體中文](README.zh-TW.md)

# hydaelyn

一份個人 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 設定：rules、agents、skills、hooks，加上一套三層記憶。對應到 `~/.claude`，clone 過去調整幾項設定（權限、推播 hook）就能跑。

裡面的規則是陸續補出來的。每條背後都有一次具體的翻車：AI 在某個情境下做錯事，就補一條規則讓它別再犯。建議從 `CLAUDE.md` 加 `dev-workflow.md`、`session-management.md` 三個檔案起步，用到哪缺再加。

## 目錄結構

```
~/.claude/
├── CLAUDE.md                 # 5 條原則 + Context Check
├── settings.json             # 權限、hooks、語言設定
├── keybindings.json          # 自訂快捷鍵
├── CHANGELOG.md              # 規則變更紀錄
│
├── rules/                    # 行為規則（全域或依 paths: 條件載入）
│   ├── dev-workflow.md       # 任務啟動、commit 紀律、effort 模式、context 管理
│   ├── session-management.md # Session notes、待辦追蹤、MR 收斂
│   ├── knowledge-index.md    # 記憶分三層（Hot/Warm/Glacier）
│   ├── sdd.md                # Spec-driven：System Spec + Change Spec
│   ├── jira-sync.md          # JIRA 同步，共 5 個觸發點
│   ├── verification-loop.md  # Critic → Alignment → 驗收（最多 2 輪修正）
│   ├── ownership.md          # 基於 CODEOWNERS 的跨模組修改檢查
│   ├── subagent-strategy.md  # Fork / Teammate / Worktree 委派
│   ├── worktree-memory.md    # Worktree 記憶繼承規則
│   ├── web-fetch-safety.md   # 外部內容安全（prompt injection 防護）
│   ├── figma-workflow.md     # paths: UI 檔 — Figma MCP 四階段
│   ├── visual-ui-workflow.md # paths: UI 檔 — 視覺改動流程
│   ├── writing-style.md      # paths: README, docs — 行文風格
│   └── spec-template.md      # paths: specs — Change Spec 格式
│
├── agents/                   # Subagents（隔離 context）
│   ├── task-executor.md      # Builder — 實作單一 subtask（Sonnet）
│   ├── critic.md             # 對抗性審查，pattern 一致性優先（Opus）
│   ├── alignment-checker.md  # 外部參考對齊 — Figma/schema/spec（Opus）
│   ├── code-reviewer.md      # 邏輯、錯誤處理、程式碼模式（Opus）
│   ├── security-reviewer.md  # OWASP、權限、機密、注入（Opus）
│   └── code-simplifier.md    # 移除死碼、過度抽象（Sonnet）
│
├── skills/                   # 意圖觸發的工作流
│   ├── autopilot/            # 自動 build → critic → alignment → fix 迴圈
│   ├── git-commit/           # 產生並執行 git commit
│   ├── pr/                   # 從 commits 建立 MR/PR
│   └── review/               # Push 前平行三 agent 審查
│
├── commands/                 # Slash 指令（手動呼叫）
│   ├── plan.md               # /plan — 結構化規劃，產出 spec
│   ├── project-init.md       # /project-init — 專案初始化
│   ├── session.md            # /session — 進度快照 + 知識萃取
│   ├── housekeeping.md       # /housekeeping — 記憶清理與歸檔
│   ├── reflect.md            # /reflect — 回顧 session，偵測違規
│   ├── evolve.md             # /evolve — 基於 reflect 修改規則
│   ├── careful.md            # /careful — 啟用破壞性指令阻擋
│   └── freeze.md             # /freeze — 鎖定編輯範圍
│
└── scripts/                  # Hook 腳本
    ├── setup.sh
    ├── claude-notify-macos.sh
    └── claude-notify-linux.sh
```

## 架構

用的是 Claude Code 原生的擴充機制：

| 層 | 做什麼 | 何時載入 |
|---|---|---|
| `CLAUDE.md` | 全專案指令與原則 | 每次 session |
| `rules/` | 行為規則，一個主題一個檔 | 每次 session（全域）或符合 `paths:` 時才載入 |
| `agents/` | 隔離 context 的 subagent，各有模型和工具 | 委派時 |
| `skills/` | 意圖觸發的工作流 | 被呼叫或意圖匹配時 |
| `commands/` | 手動 slash 指令 | 被呼叫時 |
| Hooks（`settings.json`） | 生命週期事件觸發的 shell script — PreToolUse、Stop、PreCompact | 每次匹配的事件 |

### 依路徑載入的規則

沒有 frontmatter 的 rule 每次 session 都載入。加了 `paths:` 的 rule 只在 Claude 碰到匹配的檔案時才載入，省下領域規則佔用的 context。

```yaml
# rules/figma-workflow.md — 編輯 UI 或 spec 檔時才載入
---
paths:
  - "**/*.tsx"
  - "**/*.css"
  - "specs/**/figma*"
---
```

這套 playbook 有 4 個 rule 用了 `paths:`：`figma-workflow`、`visual-ui-workflow`、`writing-style`、`spec-template`。其餘全域載入。

### 治理層（自訂）

三個 pattern 超出官方擴充機制的範圍：

| Pattern | 加了什麼 | 用什麼組成 |
|---|---|---|
| 三層記憶 | Hot / Warm / Glacier 歸檔，在 auto memory 上面加分層 | `rules/knowledge-index.md` + `commands/housekeeping.md` |
| Spec-driven development | 每個模組分 System Spec（as-is）和 Change Spec（to-be） | `rules/sdd.md` + `rules/spec-template.md` + `commands/plan.md` |
| Builder-Critic 驗收 | task-executor → critic（全新 context）→ alignment-checker | `agents/` + `rules/verification-loop.md` + `skills/autopilot/` |

這些都是選配。L1 不需要任何一個就能跑。

## 怎麼開始

```bash
git clone https://github.com/rainoff/hydaelyn.git ~/.claude
```

不要整包套完。看下面的分級，挑現階段需要的。JIRA、Figma 這些不用的 rule 直接刪，不會影響其他部分。

### 分級

| 層 | 檔案 | 帶來什麼 |
|---|---|---|
| **L1 — 底** | `CLAUDE.md` + `rules/dev-workflow.md` + `rules/session-management.md` | Context Check、commit 紀律、session 交接 |
| **L2 — 自動** | L1 + `agents/` + `skills/` + `rules/verification-loop.md` | Builder-Critic 迴圈、自動 commit/review、`/plan` 流程 |
| **L3 — 自迭代** | L2 + `memory/` + `/reflect` + `/evolve` | 三層記憶、從實際失敗演進的規則、跨 session 學習 |

從 L1 開始。發現 AI 常犯「第二個人會抓到的錯」時往 L2 走。想要系統跨 session 自我改善時走 L3。

### 自訂

| 狀況 | 做法 |
|---|---|
| 不用 JIRA | 刪 `rules/jira-sync.md` |
| 不用 Figma | 刪 `rules/figma-workflow.md` |
| 有專案特定規則 | 放 `{project}/.claude/rules/`，不要塞進全域 |
| macOS | 用 `claude-notify-macos.sh` |
| Linux | 用 `claude-notify-linux.sh` |
| Windows | 自己寫 PowerShell 推播腳本 |
| 換 AI 回應語言 | 改 `settings.json` 的 `language`（預設 zh-TW） |

## 幾個關鍵設計

### 五條原則（CLAUDE.md）

1. **不要猜** — 找不到就查或問。
2. **Context Check** — 動手前先列：涉及哪些模組、讀過哪些記憶、類似程式碼長怎樣、上下游、還不確定什麼。
3. **跟著既有 pattern** — 一致性比聰明重要，不擅自引入新做法。
4. **Context 壓縮偏好** — 告訴 harness 壓縮時該先留什麼。
5. **何時問、何時查、何時動手** — 一張決策表。

### 兩種執行模式

| 模式 | 用在 | Pattern 一致性 |
|---|---|---|
| `conservative`（預設） | 既有專案 | 強制 |
| `rapid` | 新專案、快速迭代 | 放寬 |

### 記憶分三層

```
Hot    → MEMORY.md（永遠載入，≤50 行，知識地圖）
Warm   → memory/*.md（按需載入，用 frontmatter 的 description 快速掃描）
Glacier → 同目錄，frontmatter 加 archived: true（檔案不搬）
```

### Spec-driven development

每個模組分兩種 spec：

| 類型 | 做什麼 |
|---|---|
| **System Spec**（as-is） | 模組現在長什麼樣的 ground truth — Intent、Public API、Extension Points、Gotchas |
| **Change Spec**（to-be） | 本次要改什麼的 delta — AC、Pattern Compliance、測試對照 |

漸進式引入：改到哪個模組才寫 spec，沒寫不會擋流程。有 OpenSpec CLI 用 CLI 加速，沒有就手動寫，格式一樣。

System Spec 存放優先序：in-repo `openspec/specs/` → private fallback `~/.claude/projects/{key}/specs/system/` → memory fallback。第三者是過渡態，之後遷成 spec。

和記憶分工：spec 放結構性知識（API、依賴、擴充點），memory 放經驗性（踩過的坑）和狀態性（正在做什麼）。

### 驗收流程

```
task-executor（Sonnet）實作
        ↓
critic（Opus）— 全新 context，不繼承 builder 對話
        ↓ PASS
alignment-checker — 對齊外部參考（Figma/schema/spec）
        ↓ ALIGNED
主 session 驗收 → commit
```

每個步驟最多修 2 輪，超過代表切分粒度有問題，回去重切。

### 自我迭代

```
/plan → /autopilot → /session → /reflect → /evolve
```

`/reflect` 回顧最近幾個 session 找 pattern 和違規，`/evolve` 根據發現修規則（必須確認才改）。

### Hooks

| Hook | 何時觸發 | 做什麼 |
|---|---|---|
| PreToolUse (Edit/Write) | 每次寫檔前 | 提醒 Context Check + 讀 MEMORY.md |
| PreCompact | Context 壓縮前 | 提醒跑 `/session` |
| Stop (self-check) | AI 停下時 | 自問任務真完成了嗎 |
| Stop (uncommitted) | AI 停下時 | 警告有未 commit 的檔案 |

推播通知 hook 放在 `scripts/` 底下，有 macOS 和 Linux 版。Windows 用 PowerShell 的 `New-BurntToastNotification` 自行寫。

## 設計幾件事情的理由

**規則是踩出來的。** 例如 critic 必須在全新 context 跑——這條是發現 AI 審自己剛寫的程式碼時會合理化缺失之後加的。遇到一次，寫一條。

**能確定性就不靠 AI 自律。** Hooks 直接查 `git status`、echo 提醒，不是「請 AI 記得」。Bash 穩定，AI 記性不穩。

**記憶要分層歸檔。** 過時記憶會讓 AI 基於錯的假設下結論，比沒記憶更難修。所以用 description 快速掃、archived flag 歸檔、Hot memory 硬限制 50 行。

## 類似專案

| | 本 playbook | [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | [HumanLayer](https://github.com/humanlayer/humanlayer) |
|---|---|---|---|---|
| **類型** | 個人設定 | 最佳實踐文件 | 完整敏捷方法 | Human-in-the-loop SDK |
| **範圍** | 僅 `~/.claude` | 文件 + 範例 | 9 個 agent 角色、4 個階段 | MCP daemon + 雲端 |
| **規則來源** | 實際踩坑累積 | 社群策展 | 事先設計 | N/A |
| **自我迭代** | `/reflect` + `/evolve` | 無 | 無 | 無 |
| **記憶系統** | 三層 | 無 | 無 | 無 |
| **分量** | 中 | 輕 | 重 | 獨立層 |

可以一起用。HumanLayer 能處理審批閘門，shanraisshan 的範例可借鑑，BMAD 的階段結構也能疊在上面——這套 rules 和記憶不會跟它們衝突。

## 授權

MIT。自由 fork 和改。
