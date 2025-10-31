# MCP（Model Context Protocol）設定ガイド

## 概要

MCP（Model Context Protocol）は、アプリケーションがLLMにコンテキストを提供するための標準プロトコルです。Amazon Q DevContainer環境では、NotionやChrome DevToolsなどの外部サービスとの連携を可能にします。

## 設定ファイル

### agents/default.json

`q/.amazonq/agents/default.json`でMCPサーバーの設定を管理：

```json
{
  "mcpServers": {
    "notion2": {
      "type": "stdio",
      "command": "notion-mcp-server",
      "args": [],
      "env": {
        "NOTION_TOKEN": "${AMAZON_Q_NOTION_TOKEN}"
      },
      "autoAllowReadonly": false,
      "autoAllowWrite": true
    },
    "notion1": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.notion.com/mcp"
      ]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest"
      ]
    }
  }
}
```

## サポートされるMCPサーバー

### 1. Notion MCP Server

**機能**: Notionページの読み取り・書き込み

**設定**:
1. Notion APIトークンを取得
2. `.env`ファイルに設定:
```bash
AMAZON_Q_NOTION_TOKEN="secret_your-token"
```

**使用例**:
```bash
q chat
# Notionページの内容を読み取り、編集が可能
```

### 2. Chrome DevTools MCP

**機能**: ブラウザの開発者ツールとの連携

**設定**: 追加設定不要（自動インストール）

**使用例**:
```bash
q chat
# ブラウザのデバッグ情報を取得・操作が可能
```

## トラブルシューティング

### MCP接続エラー

```bash
# MCPサーバーの状態確認
npx notion-mcp-server --version

# 環境変数の確認
echo $AMAZON_Q_NOTION_TOKEN

# 手動テスト
npx notion-mcp-server
```

### 権限エラー

Notion APIトークンに必要な権限：
- Read content
- Update content
- Insert content

### パフォーマンス最適化

```json
{
  "mcpServers": {
    "notion2": {
      "type": "stdio",
      "command": "notion-mcp-server",
      "args": ["--cache-ttl", "300"],
      "env": {
        "NOTION_TOKEN": "${AMAZON_Q_NOTION_TOKEN}"
      },
      "autoAllowReadonly": true,
      "autoAllowWrite": false
    }
  }
}
```

## セキュリティ考慮事項

- APIトークンは環境変数で管理
- 読み取り専用モードの活用
- 必要最小限の権限設定
- 定期的なトークンローテーション
