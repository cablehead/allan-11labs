#!/usr/bin/env nu

use std/assert

# Test cases as closures
def test_cases [] {
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
            assert str contains $result "APPEND_CALL: topic=server-test context=audio-capture body=test body content"
            assert str contains $result "ok"
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
            assert str contains $result "APPEND_CALL: topic=capture context=audio-capture body=audio test data"
            assert str contains $result "ok"
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
            assert str contains $result "APPEND_CALL: topic=server-test context=audio-capture body=trailing slash test"
            assert str contains $result "ok"
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
            assert str contains $result "STATIC_CALL: root=www path=/"
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
            assert str contains $result "STATIC_CALL: root=www path=/assets/style.css/"
            print "✓ Original path preservation test passed"
        }
    ]
}

# Main function to run all tests
def main [] {
    print "Running serve.nu tests...\n"
    
    let test_list = (test_cases)
    let results = ($test_list | each {|test_case| 
        try {
            do $test_case
            {status: "pass"}
        } catch { |e|
            print $"✗ Test failed: ($e.msg)"
            {status: "fail", error: $e.msg}
        }
    })
    
    let passed = ($results | where status == "pass" | length)
    let failed = ($results | where status == "fail" | length)
    
    print $"\n📊 Results: ($passed) passed, ($failed) failed"
    
    if $failed > 0 {
        exit 1
    } else {
        print "✅ All tests passed!"
    }
}