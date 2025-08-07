
use /root/.config/nushell/scripts/xs.nu *

{
|req|

 let body = $in

  if $req.path in ["/audio-to-server" "/audio-to-server/"] and $req.method == "POST" {

    $body |  .append capture -c audio-capture


  	return "ok"
  }


.static "www" $req.path
}
