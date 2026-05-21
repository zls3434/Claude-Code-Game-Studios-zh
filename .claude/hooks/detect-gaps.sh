# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Hook: detect-gaps.sh
# 事件：SessionStart
# 用途：检测已有代码/原型但缺少文档的缺口
# 跨平台：兼容 Windows Git Bash（使用 grep -E，不使用 -P）

# 出错时不阻塞会话
set +e

echo "=== 文档缺口检查 ==="

# --- 检查 0：新项目检测（建议 /start）---
FRESH_PROJECT=true

# 检查引擎是否已配置
if [ -f ".claude/docs/technical-preferences.md" ]; then
  ENGINE_LINE=$(grep -E "^\- \*\*Engine\*\*:" .claude/docs/technical-preferences.md 2>/dev/null)
  if [ -n "$ENGINE_LINE" ] && ! echo "$ENGINE_LINE" | grep -q "TO BE CONFIGURED" 2>/dev/null; then
    FRESH_PROJECT=false
  fi
fi

# 检查游戏概念是否存在
if [ -f "design/gdd/game-concept.md" ]; then
  FRESH_PROJECT=false
fi

# 检查源代码是否存在
if [ -d "src" ]; then
  SRC_CHECK=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -1)
  if [ -n "$SRC_CHECK" ]; then
    FRESH_PROJECT=false
  fi
fi

if [ "$FRESH_PROJECT" = true ]; then
  echo ""
  echo "🚀 新项目：引擎未配置，无游戏概念，无源代码。"
  echo "   这看起来是个全新开始！执行：/start"
  echo ""
  echo "💡 如需全面的项目分析，执行：/project-stage-detect"
  echo "==================================="
  exit 0
fi

# --- 检查 1：大量代码但设计文档稀少 ---
if [ -d "src" ]; then
  # 统计源文件数（跨平台，兼容 Windows 路径）
  SRC_FILES=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)
else
  SRC_FILES=0
fi

if [ -d "design/gdd" ]; then
  DESIGN_FILES=$(find design/gdd -type f -name "*.md" 2>/dev/null | wc -l)
else
  DESIGN_FILES=0
fi

# 规范化 wc 输出的空白字符
SRC_FILES=$(echo "$SRC_FILES" | tr -d ' ')
DESIGN_FILES=$(echo "$DESIGN_FILES" | tr -d ' ')

if [ "$SRC_FILES" -gt 50 ] && [ "$DESIGN_FILES" -lt 5 ]; then
  echo "⚠️  缺口：代码量很大（$SRC_FILES 个源文件）但设计文档稀少（$DESIGN_FILES 个文件）"
  echo "    建议操作：/reverse-document design src/[系统]"
  echo "    或执行：/project-stage-detect 获取完整分析"
fi

# --- 检查 2：原型无文档 ---
if [ -d "prototypes" ]; then
  PROTOTYPE_DIRS=$(find prototypes -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  UNDOCUMENTED_PROTOS=()

  if [ -n "$PROTOTYPE_DIRS" ]; then
    while IFS= read -r proto_dir; do
      # 规范化 Windows 路径分隔符
      proto_dir=$(echo "$proto_dir" | sed 's|\\|/|g')

      # 检查 README.md 或 CONCEPT.md 是否存在
      if [ ! -f "${proto_dir}/README.md" ] && [ ! -f "${proto_dir}/CONCEPT.md" ]; then
        proto_name=$(basename "$proto_dir")
        UNDOCUMENTED_PROTOS+=("$proto_name")
      fi
    done <<< "$PROTOTYPE_DIRS"

    if [ ${#UNDOCUMENTED_PROTOS[@]} -gt 0 ]; then
      echo "⚠️  缺口：发现 ${#UNDOCUMENTED_PROTOS[@]} 个未文档化的原型："
      for proto in "${UNDOCUMENTED_PROTOS[@]}"; do
        echo "    - prototypes/$proto/（无 README 或 CONCEPT 文档）"
      done
      echo "    建议操作：/reverse-document concept prototypes/[名称]"
    fi
  fi
fi

# --- 检查 3：核心系统无架构文档 ---
if [ -d "src/core" ] || [ -d "src/engine" ]; then
  if [ ! -d "docs/architecture" ]; then
    echo "⚠️  缺口：存在核心引擎/系统，但没有 docs/architecture/ 目录"
    echo "    建议操作：创建 docs/architecture/ 并执行 /architecture-decision"
  else
    ADR_COUNT=$(find docs/architecture -type f -name "*.md" 2>/dev/null | wc -l)
    ADR_COUNT=$(echo "$ADR_COUNT" | tr -d ' ')

    if [ "$ADR_COUNT" -lt 3 ]; then
      echo "⚠️  缺口：存在核心系统但仅记录了 $ADR_COUNT 个 ADR"
      echo "    建议操作：/reverse-document architecture src/core/[系统]"
    fi
  fi
fi

# --- 检查 4：游戏性系统无设计文档 ---
if [ -d "src/gameplay" ]; then
  # 找到主要的游戏性子目录（包含 5 个以上文件的）
  GAMEPLAY_SYSTEMS=$(find src/gameplay -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

  if [ -n "$GAMEPLAY_SYSTEMS" ]; then
    while IFS= read -r system_dir; do
      system_dir=$(echo "$system_dir" | sed 's|\\|/|g')
      system_name=$(basename "$system_dir")
      file_count=$(find "$system_dir" -type f 2>/dev/null | wc -l)
      file_count=$(echo "$file_count" | tr -d ' ')

      # 如果系统有 5 个以上文件，检查是否有对应的设计文档
      if [ "$file_count" -ge 5 ]; then
        # 检查设计文档（允许多种变体：combat-system.md、combat.md）
        design_doc_1="design/gdd/${system_name}-system.md"
        design_doc_2="design/gdd/${system_name}.md"

        if [ ! -f "$design_doc_1" ] && [ ! -f "$design_doc_2" ]; then
          echo "⚠️  缺口：游戏性系统 'src/gameplay/$system_name/'（$file_count 个文件）没有设计文档"
          echo "    预期位置：design/gdd/${system_name}-system.md 或 design/gdd/${system_name}.md"
          echo "    建议操作：/reverse-document design src/gameplay/$system_name"
        fi
      fi
    done <<< "$GAMEPLAY_SYSTEMS"
  fi
fi

# --- 检查 5：生产规划 ---
if [ "$SRC_FILES" -gt 100 ]; then
  # 对于有大量代码的项目，检查生产规划
  if [ ! -d "production/sprints" ] && [ ! -d "production/milestones" ]; then
    echo "⚠️  缺口：代码量很大（$SRC_FILES 个文件）但没有生产规划"
    echo "    建议操作：/sprint-plan 或创建 production/ 目录"
  fi
fi

# --- 汇总 ---
echo ""
echo "💡 如需全面的项目分析，执行：/project-stage-detect"
echo "==================================="

exit 0
