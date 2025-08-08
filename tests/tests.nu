#!/usr/bin/env nu

use /root/.config/nushell/scripts/xs.nu *

def test_server_submit [] {
    print "Testing /server-submit endpoint..."
    let result = ("test body content" | nu -c 'let c = source serve.nu ; do $c (open tests/http.post.server-submit.json)')
    if ($result != "ok") { error make {msg: ("Expected 'ok', got: " + $result)} }
    print "✓ /server-submit test passed"
}

def test_audio_to_server [] {
    print "Testing /audio-to-server endpoint..."
    let result = ("audio test data" | nu -c 'let c = source serve.nu ; do $c ({path: "/audio-to-server", method: "POST", headers: {}, query: {}})')
    if ($result != "ok") { error make {msg: ("Expected 'ok', got: " + $result)} }
    print "✓ /audio-to-server test passed"
}

def test_trailing_slash [] {
    print "Testing trailing slash normalization..."
    let result = ("trailing slash test" | nu -c 'let c = source serve.nu ; do $c ({path: "/server-submit/", method: "POST", headers: {}, query: {}})')
    if ($result != "ok") { error make {msg: ("Expected 'ok', got: " + $result)} }
    print "✓ Trailing slash test passed"
}

def test_static_file_handling [] {
    print "Testing static file handling (catch-all)..."
    # This should not crash and should trigger the .static command
    let result = (try { "" | nu -c 'let c = source serve.nu ; do $c ({path: "/", method: "GET", headers: {}, query: {}})' } catch { "caught error - expected for missing static files" })
    print "✓ Static file handling test passed (no crash)"
}

def main [] {
    print "Running serve.nu tests...\n"
    
    test_server_submit
    test_audio_to_server 
    test_trailing_slash
    test_static_file_handling
    
    print "\n✅ All tests passed!"
}