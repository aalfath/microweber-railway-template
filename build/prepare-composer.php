<?php
// Drops the optional theme that only lives on packages.microweberapi.com and points
// GitHub dist downloads at codeload.github.com (no API rate limit for anonymous builds).
$drop = 'microweber-templates/big-free';

$json = json_decode(file_get_contents('composer.json'), true, 512, JSON_THROW_ON_ERROR);
unset($json['require'][$drop]);
$json['repositories'] = array_values(array_filter($json['repositories'] ?? [],
    fn ($r) => !str_contains($r['url'] ?? '', 'microweberapi.com')));
if (!$json['repositories']) unset($json['repositories']);
file_put_contents('composer.json', json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n");

$lock = json_decode(file_get_contents('composer.lock'), true, 512, JSON_THROW_ON_ERROR);
$n = 0;
foreach (['packages', 'packages-dev'] as $k) {
    $lock[$k] = array_values(array_filter($lock[$k] ?? [], fn ($p) => $p['name'] !== $drop));
    foreach ($lock[$k] as &$p) {
        $u = $p['dist']['url'] ?? '';
        if (preg_match('#^https://api\.github\.com/repos/([^/]+)/([^/]+)/zipball/(.+)$#', $u, $m)) {
            $p['dist']['url'] = "https://codeload.github.com/{$m[1]}/{$m[2]}/legacy.zip/{$m[3]}";
            $n++;
        }
        if (str_contains($u, 'microweberapi.com')) {
            fwrite(STDERR, "package still on microweberapi.com: {$p['name']}\n");
            exit(1);
        }
    }
    unset($p);
}
file_put_contents('composer.lock', json_encode($lock, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n");
echo "prepare-composer: removed $drop, rewrote $n dist URLs\n";
