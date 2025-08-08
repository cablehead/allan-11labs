use /root/.config/nushell/scripts/xs.nu *

def trim_trailing_slash [] {
  let trimmed = $in | str trim --right --char '/'
  if ($trimmed | is-empty) {
    '/'
  } else {
    $trimmed
  }
}

{|req|
  match ($req | update path { trim_trailing_slash }) {
    {path: "/audio-to-server" , method: "POST"} => {
      $in | .append capture -c audio-capture
      "ok"
    }
    {path: "/server-submit" , method: "POST"} => {
      $in | .append server-test -c audio-capture
      "ok"
    }
    _ => {
      .static "www" $req.path
    }
  }
}
