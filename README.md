# Web Server

HTTP server handler with structured matching and path normalization.

## Testing

```bash
cd tests
nu serve-tests.nu
```

Tests use stubbing pattern: `source serve.nu` → `def stubs` → `"body" | do $c request`