#!/usr/bin/env nu

# Stub for .static command (for testing only)
def ".static" [root: string, path: string] {
  $"serving static file: ($root)($path)"
}

def test_static_path_bug [] {
    print "Testing static file path handling..."
    
    # Test with original path
    let test_req = {path: "/some/path/", method: "GET", headers: {}, query: {}}
    print $"Original request path: ($test_req.path)"
    
    # Load and test the serve.nu logic
    let result = ("" | nu -c '
        use /root/.config/nushell/scripts/xs.nu *
        
        # Stub .static
        def ".static" [root: string, path: string] {
          $"serving static file: ($root)($path)"
        }
        
        def trim_trailing_slash [] {
          let trimmed = $in | str trim --right --char "/"
          if ($trimmed | is-empty) {
            "/"
          } else {
            $trimmed
          }
        }
        
        let req = {path: "/some/path/", method: "GET", headers: {}, query: {}}
        
        match ($req | update path { trim_trailing_slash }) {
          {path: "/audio-to-server" , method: "POST"} => {
            "audio endpoint"
          }
          {path: "/server-submit" , method: "POST"} => {
            "submit endpoint"  
          }
          $updated_req => {
            print $"updated_req variable contains: ($updated_req)"
            print $"updated_req.path is: ($updated_req.path)"
            print $"original req.path was: ($req.path)"
            .static "www" $updated_req.path
          }
        }
    ')
    
    print $"Result: ($result)"
    print "✓ Static path bug test completed"
}

def main [] {
    test_static_path_bug
}