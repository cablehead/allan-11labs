#!/usr/bin/env nu

def test_original_vs_updated_path [] {
    print "Testing that static files use ORIGINAL path, not trimmed path..."
    
    # The issue: when someone requests "/some/dir/" we should serve that exact path
    # from the filesystem, not the trimmed version "/some/dir"
    
    let result = ("" | nu -c '
        use /root/.config/nushell/scripts/xs.nu *
        
        # Stub .static to show what path it receives
        def ".static" [root: string, path: string] {
          $"STATIC_CALLED_WITH: root=($root) path=($path)"
        }
        
        # Load the actual serve.nu logic but with our stub
        let closure = source serve.nu
        do $closure {path: "/assets/style.css/", method: "GET", headers: {}, query: {}}
    ')
    
    print $"Current behavior: ($result)"
    
    # What we SHOULD get
    print "Expected: STATIC_CALLED_WITH: root=www path=/assets/style.css/"
    print "Actual  : $result"
    
    if ($result | str contains "/assets/style.css/") {
        print "✓ GOOD: Using original path with trailing slash"
    } else {
        print "✗ BUG: Using trimmed path instead of original!"
    }
}

def main [] {
    test_original_vs_updated_path
}