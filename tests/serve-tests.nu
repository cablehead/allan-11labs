#!/usr/bin/env nu

# Helper to assert string contains
def assert_contains [haystack: string, needle: string, context: string = ""] {
    if not ($haystack | str contains $needle) {
        let msg = if ($context == "") {
            $"Expected to contain '($needle)', got: ($haystack)"
        } else {
            $"($context): Expected to contain '($needle)', got: ($haystack)"
        }
        error make {msg: $msg}
    }
}

# Test cases as closures
export def test_cases [] {
    [
        {||
            print "Testing POST /server-submit..."
            let output = (nu -c '
                let c = source ../serve.nu
                def ".append" [topic: string, --context-id (-c): string] {
                    print $"APPEND_CALL: topic=($topic) context=($context_id) body=($in)"
                    "ok"
                }
                def ".static" [root: string, path: string] {
                    print $"STATIC_CALL: root=($root) path=($path)"
                }
                "test body content" | do $c (open http.post.server-submit.json)
            ' | complete)
            let result = $output.stdout
            assert_contains $result "APPEND_CALL: topic=server-test context=audio-capture body=test body content" "server-submit append"
            assert_contains $result "ok" "server-submit response"
            print "✓ /server-submit test passed"
        },
        
        {||
            print "Testing POST /audio-to-server..."
            let output = (nu -c '
                let c = source ../serve.nu
                def ".append" [topic: string, --context-id (-c): string] {
                    print $"APPEND_CALL: topic=($topic) context=($context_id) body=($in)"
                    "ok"
                }
                def ".static" [root: string, path: string] {
                    print $"STATIC_CALL: root=($root) path=($path)"
                }
                "audio test data" | do $c (open http.post.audio-to-server.json)
            ' | complete)
            let result = $output.stdout
            assert_contains $result "APPEND_CALL: topic=capture context=audio-capture body=audio test data" "audio-to-server append"
            assert_contains $result "ok" "audio-to-server response"
            print "✓ /audio-to-server test passed"
        },

        {||
            print "Testing POST /server-submit/ (trailing slash)..."
            let output = (nu -c '
                let c = source ../serve.nu
                def ".append" [topic: string, --context-id (-c): string] {
                    print $"APPEND_CALL: topic=($topic) context=($context_id) body=($in)"
                    "ok"
                }
                def ".static" [root: string, path: string] {
                    print $"STATIC_CALL: root=($root) path=($path)"
                }
                "trailing slash test" | do $c ({path: "/server-submit/", method: "POST", headers: {}, query: {}})
            ' | complete)
            let result = $output.stdout
            assert_contains $result "APPEND_CALL: topic=server-test context=audio-capture body=trailing slash test" "trailing slash append"
            assert_contains $result "ok" "trailing slash response"
            print "✓ Trailing slash test passed"
        },

        {||
            print "Testing GET / (static files)..."
            let output = (nu -c '
                let c = source ../serve.nu
                def ".append" [topic: string, --context-id (-c): string] {
                    print $"APPEND_CALL: topic=($topic) context=($context_id) body=($in)"
                    "ok"
                }
                def ".static" [root: string, path: string] {
                    print $"STATIC_CALL: root=($root) path=($path)"
                }
                "" | do $c (open http.get.static.json)
            ' | complete)
            let result = $output.stdout
            assert_contains $result "STATIC_CALL: root=www path=/" "static file call"
            print "✓ Static file handling test passed"
        },

        {||
            print "Testing original path preservation for static files..."
            let output = (nu -c '
                let c = source ../serve.nu
                def ".append" [topic: string, --context-id (-c): string] {
                    print $"APPEND_CALL: topic=($topic) context=($context_id) body=($in)"
                    "ok"
                }
                def ".static" [root: string, path: string] {
                    print $"STATIC_CALL: root=($root) path=($path)"
                }
                "" | do $c ({path: "/assets/style.css/", method: "GET", headers: {}, query: {}})
            ' | complete)
            let result = $output.stdout
            assert_contains $result "STATIC_CALL: root=www path=/assets/style.css/" "original path preservation"
            print "✓ Original path preservation test passed"
        }
    ]
}