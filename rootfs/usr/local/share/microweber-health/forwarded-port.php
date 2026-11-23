<?php
// Railway's edge takes requests on 443 (or 80) and forwards them to $PORT. Microweber builds the
// current URL from SERVER_PORT when the Host header has no port, so "https://site/" became
// "https://site:8080/", matched no page and returned 404. Use the client-side port instead.
if (isset($_SERVER['HTTP_HOST']) && !str_contains($_SERVER['HTTP_HOST'], ':')) {
    $port = $_SERVER['HTTP_X_FORWARDED_PORT'] ?? '';
    if (!ctype_digit((string) $port)) {
        $port = strtolower($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https' ? '443' : '80';
    }
    $_SERVER['SERVER_PORT'] = $port;
}
