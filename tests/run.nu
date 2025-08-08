#!/usr/bin/env nu

# Simple test runner
def main [] {
    print "Running serve.nu tests...\n"
    
    use serve-tests.nu
    
    let test_cases = (serve-tests test_cases)
    let results = ($test_cases | each {|test_case| 
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