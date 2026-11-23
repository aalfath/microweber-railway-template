<?php
// Railway health check: Apache and PHP answer, and the install finished (the start script
// only starts Apache after that). No database call, so a short MySQL blip doesn't fail it.
header('Content-Type: text/plain');
header('Cache-Control: no-store');
$c = @include '/data/config/microweber.php';
if (is_array($c) && !empty($c['is_installed'])) {
    echo "ok\n";
} else {
    http_response_code(503);
    echo "not installed\n";
}
