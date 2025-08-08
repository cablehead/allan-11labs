# Web Server

HTTP server handler with structured matching and path normalization.

## Testing

```bash
cd tests
nu run.nu
```

Tests use stubbing pattern: `source serve.nu` → `def stubs` → `"body" | do $c request`