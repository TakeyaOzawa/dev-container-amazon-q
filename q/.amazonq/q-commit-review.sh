#!/bin/bash
# Amazon Q自動コミットレビュースクリプト

set -e

# 設定
AGENT="commit-reviewer"
TEMP_DIR="/tmp/q-review-$$"
REVIEW_LOG="$TEMP_DIR/review.log"

# 一時ディレクトリ作成
mkdir -p "$TEMP_DIR"

# クリーンアップ関数
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🔍 Amazon Q コミットレビューを開始..."

# 変更統計を取得
git diff --cached --stat > "$TEMP_DIR/stats.txt"
git diff --cached --name-only > "$TEMP_DIR/files.txt"

# 変更ファイル数と行数を計算
file_count=$(wc -l < "$TEMP_DIR/files.txt")
line_count=$(git diff --cached --numstat | awk '{sum += $1 + $2} END {print sum}')

echo "変更ファイル数: $file_count"
echo "変更行数: $line_count"

# 大量変更の場合のみレビュー実行
if [ "$file_count" -gt 10 ] || [ "$line_count" -gt 500 ]; then
    echo "📊 大量変更を検出。詳細レビューを実行中..."
    
    # Amazon Q CLIでレビュー実行
    q chat --agent "$AGENT" > "$REVIEW_LOG" 2>&1 << EOF
以下のGit変更をレビューしてください：

変更統計:
$(cat "$TEMP_DIR/stats.txt")

変更ファイル一覧:
$(cat "$TEMP_DIR/files.txt")

以下のコマンドで詳細を確認し、不自然な修正を検出してください：
1. git diff --cached --stat
2. git diff --cached | head -100
3. 各ファイルの変更内容を確認

問題があれば「❌ REJECT」で始まる行で報告してください。
問題なければ「✅ APPROVE」で始まる行で承認してください。
EOF

    # レビュー結果を表示
    echo "📋 レビュー結果:"
    cat "$REVIEW_LOG"
    
    # 拒否判定をチェック
    if grep -q "❌ REJECT" "$REVIEW_LOG"; then
        echo ""
        echo "🚨 Amazon Qがコミットを拒否しました。"
        echo "上記の問題を修正してから再度コミットしてください。"
        exit 1
    elif grep -q "✅ APPROVE" "$REVIEW_LOG"; then
        echo ""
        echo "✅ Amazon Qがコミットを承認しました。"
    else
        echo ""
        echo "⚠️  明確な判定が得られませんでした。手動で確認してください。"
        read -p "コミットを続行しますか？ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo "✅ 変更量が適切です。レビューをスキップします。"
fi

echo "🎉 レビュー完了。コミットを続行してください。"
