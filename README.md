# Alpaca MCP Trading Server (patched)

Патченный MCP-сервер для [Alpaca Markets](https://alpaca.markets/) с поддержкой bracket и OCO ордеров (TP + SL одновременно).

## Что исправлено

Оригинальный `alpaca-mcp-server` не поддерживал вложенные объекты `take_profit` / `stop_loss` для bracket и OCO ордеров. Патч добавляет:

- `take_profit_limit_price` — лимитная цена для Take-Profit
- `stop_loss_stop_price` — стоп-цена для Stop-Loss
- `stop_loss_limit_price` — лимитная цена для Stop-Loss (опционально, для stop-limit ноги)
- Workaround: `trail_price` → `take_profit.limit_price`, `stop_price` → `stop_loss.stop_price` для bracket/OCO

## Использование

### Сборка образа

```bash
docker build -t mcp/alpaca:latest .
```

### Конфиг Claude Code (`~/.claude.json`)

```json
{
  "mcpServers": {
    "alpaca-docker": {
      "type": "stdio",
      "command": "docker",
      "args": ["run", "-i", "--rm",
        "-e", "ALPACA_API_KEY",
        "-e", "ALPACA_SECRET_KEY",
        "-e", "ALPACA_PAPER_TRADE",
        "mcp/alpaca:latest"
      ],
      "env": {
        "ALPACA_API_KEY": "YOUR_KEY",
        "ALPACA_SECRET_KEY": "YOUR_SECRET",
        "ALPACA_PAPER_TRADE": "True"
      }
    }
  }
}
```

### Bracket ордер (вход + TP + SL)

```python
place_stock_order(
    symbol="AAPL", side="buy", quantity=10,
    type="limit", time_in_force="gtc",
    order_class="bracket",
    limit_price=150.00,   # цена входа
    trail_price=165.00,   # Take-Profit
    stop_price=140.00     # Stop-Loss
)
```

### OCO ордер (TP + SL для открытой позиции)

```python
place_stock_order(
    symbol="AAPL", side="sell", quantity=10,
    type="limit", time_in_force="gtc",
    order_class="oco",
    limit_price=165.00,   # Take-Profit (основная нога)
    trail_price=165.00,   # Take-Profit (workaround для патча)
    stop_price=140.00     # Stop-Loss
)
```

### Важные нюансы

- OCO/bracket ордера **не размещать параллельно** — коллизия `client_order_id`. Размещать последовательно.
- `cancel_order_by_id` возвращает NoneType error при успехе (HTTP 204) — это нормально, cancel выполнен.

## Файлы

| Файл | Описание |
|------|----------|
| `server.py` | Патченный MCP-сервер |
| `Dockerfile` | Сборка образа поверх оригинального `mcp/alpaca:latest` |
| `CLAUDE.md` | Инструкции для LLM-трейдера (EOD цикл, guardrails) |
