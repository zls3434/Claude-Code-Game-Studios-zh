# 翻译修改：2026-05-20, 修改人: zls3434
#!/usr/bin/env bash
# Claude Code Game Studios — 状态栏
# 从 stdin 接收 JSON，输出单行状态。
#
# 分段：ctx% | model | 生产阶段 [| Epic > Feature > Task]

input=$(cat)

# --- 解析 JSON（jq，备用 grep）---
if command -v jq &>/dev/null; then
  model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
  used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
  cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
else
  model=$(echo "$input" | grep -oE '"display_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')
  used_pct=$(echo "$input" | grep -oE '"used_percentage"\s*:\s*[0-9]+' | head -1 | sed 's/.*: *//')
  cwd=$(echo "$input" | grep -oE '"current_dir"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')
  [ -z "$model" ] && model="Unknown"
fi

# 规范化 Windows 路径
cwd=$(echo "$cwd" | sed 's|\\|/|g')
[ -z "$cwd" ] && cwd="."

# --- 上下文使用率 ---
if [ -n "$used_pct" ]; then
  ctx_label="ctx: ${used_pct}%"
else
  ctx_label="ctx: --"
fi

# --- 生产阶段 ---
# 优先级 1：stage.txt 中的显式阶段
stage_file="$cwd/production/stage.txt"
stage=""
if [ -f "$stage_file" ]; then
  stage=$(head -1 "$stage_file" | tr -d '\r\n')
fi

# 优先级 2：从产物自动检测
if [ -z "$stage" ]; then
  concept_file="$cwd/design/gdd/game-concept.md"
  systems_file="$cwd/design/gdd/systems-index.md"
  tech_prefs="$cwd/.claude/docs/technical-preferences.md"

  has_concept=false
  has_systems=false
  engine_configured=false
  src_count=0

  [ -f "$concept_file" ] && has_concept=true
  [ -f "$systems_file" ] && has_systems=true

  # 检查引擎是否已配置（非占位符）
  if [ -f "$tech_prefs" ]; then
    engine_line=$(grep -m1 '^\*\*Engine\*\*:' "$tech_prefs" 2>/dev/null || true)
    if [ -n "$engine_line" ] && ! echo "$engine_line" | grep -q "TO BE CONFIGURED"; then
      engine_configured=true
    fi
  fi

  # 统计源文件数（语言无关）
  if [ -d "$cwd/src" ]; then
    src_count=$(find "$cwd/src" -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.h" -o -name "*.py" -o -name "*.rs" -o -name "*.lua" -o -name "*.tscn" -o -name "*.tres" \) 2>/dev/null | wc -l | tr -d ' ')
  fi

  # 检查 ADR（信号：预生产阶段）
  has_adrs=false
  if ls "$cwd/docs/architecture/"adr-*.md 2>/dev/null | head -1 | grep -q .; then
    has_adrs=true
  fi

  # 确定阶段（从最高级到最低级检查）
  if [ "$src_count" -ge 10 ] 2>/dev/null; then
    stage="生产"
  elif [ "$has_adrs" = true ]; then
    stage="预生产"
  elif [ "$engine_configured" = true ]; then
    stage="技术准备"
  elif [ "$has_systems" = true ]; then
    stage="系统设计"
  elif [ "$has_concept" = true ]; then
    stage="概念"
  else
    stage="概念"
  fi
fi

# --- Epic/Feature/Task 面包屑（仅生产+阶段）---
breadcrumb=""
if [ "$stage" = "生产" ] || [ "$stage" = "打磨" ] || [ "$stage" = "发布" ]; then
  state_file="$cwd/production/session-state/active.md"
  if [ -f "$state_file" ]; then
    # 解析结构化 STATUS 块
    in_block=false
    epic="" feature="" task=""
    while IFS= read -r line; do
      case "$line" in
        *"<!-- STATUS -->"*) in_block=true; continue ;;
        *"<!-- /STATUS -->"*) break ;;
      esac
      if [ "$in_block" = true ]; then
        case "$line" in
          Epic:*) epic=$(echo "$line" | sed 's/^Epic: *//') ;;
          Feature:*) feature=$(echo "$line" | sed 's/^Feature: *//') ;;
          Task:*) task=$(echo "$line" | sed 's/^Task: *//') ;;
        esac
      fi
    done < "$state_file"

    # 根据已设置的内容构建面包屑
    parts=""
    [ -n "$epic" ] && parts="$epic"
    [ -n "$feature" ] && parts="${parts:+$parts > }$feature"
    [ -n "$task" ] && parts="${parts:+$parts > }$task"
    [ -n "$parts" ] && breadcrumb=" | $parts"
  fi
fi

# --- 组装 ---
printf "%s" "${ctx_label} | ${model} | ${stage}${breadcrumb}"
