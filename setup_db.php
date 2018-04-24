#!/usr/bin/env php
<?php

$confpath = '/var/www/html/ttrss/config.php';

$config = array();

// path to ttrss
$config['HOST_URL'] = env('HOST_URL', 'http://localhost');

// database type and port
if (getenv('DB_TYPE') !== false) {
    $config['DB_TYPE'] = getenv('DB_TYPE');
} else {
    error('The env DB_TYPE does not exist. Can run with either "mysql" or "pgsql"');
}

if (empty($config['DB_PORT'])) {
    switch ($config['DB_TYPE']) {
        case 'mysql':
            $eport = 3306;
            break;
        case 'pgsql':
            $eport = 5432;
            break;
        default:
            error('Database is neither mysql or pgsql, and DB_PORT is not present');
    }
} else {
    $config['DB_PORT'] = getenv('DB_PORT');
}


// database credentials for this instance
//   database host (DB_HOST) can be supplied or detaults to "localhost"
//   database name (DB_NAME) can be supplied or detaults to "ttrss"
//   database user (DB_USER) can be supplied or defaults to database name
//   database pass (DB_PASS) can be supplied or defaults to database user
$config['DB_HOST'] = env('DB_HOST', 'localhost');
$config['DB_NAME'] = env('DB_NAME', 'ttrss');
$config['DB_USER'] = env('DB_USER', $config['DB_NAME']);
$config['DB_PASS'] = env('DB_PASS', $config['DB_USER']);

if (!dbcheck($config)) {
    echo 'Database login failed, trying to create...' . PHP_EOL;
    // superuser account to create new database and corresponding user account
    //   username (SU_USER) can be supplied or defaults to "docker"
    //   password (SU_PASS) can be supplied or defaults to username

    $super = $config;

    $super['DB_NAME'] = null;
    $super['DB_USER'] = $config['DB_USER'];
    $super['DB_PASS'] = $config['DB_PASS'];
    
    $pdo = dbconnect($super);

    if ($super['DB_TYPE'] === 'mysql') {
        $pdo->exec('CREATE DATABASE ' . ($config['DB_NAME']));
        $pdo->exec('GRANT ALL PRIVILEGES ON ' . ($config['DB_NAME']) . '.* TO ' . $pdo->quote($config['DB_USER']) . '@"%" IDENTIFIED BY ' . $pdo->quote($config['DB_PASS']));
    } else {
        $pdo->exec('CREATE ROLE ' . ($config['DB_USER']) . ' WITH LOGIN PASSWORD ' . $pdo->quote($config['DB_PASS']));
        $pdo->exec('CREATE DATABASE ' . ($config['DB_NAME']) . ' WITH OWNER ' . ($config['DB_USER']));
    }

    unset($pdo);
    
    if (dbcheck($config)) {
        echo 'Database login created and confirmed' . PHP_EOL;
    } else {
        error('Database login failed, trying to create login failed as well');
    }
}

$pdo = dbconnect($config);
try {
    $pdo->query('SELECT 1 FROM ttrss_feeds');
    // reached this point => table found, assume db is complete
}
catch (PDOException $e) {
    echo 'Database table not found, applying schema... ' . PHP_EOL;
    $schema = file_get_contents('/var/www/html/ttrss/schema/ttrss_schema_' . $config['DB_TYPE'] . '.sql');
    $schema = preg_replace('/--(.*?);/', '', $schema);
    $schema = preg_replace('/[\r\n]/', ' ', $schema);
    $schema = trim($schema, ' ;');
    foreach (explode(';', $schema) as $stm) {
        $pdo->exec($stm);
    }
    unset($pdo);
}

$contents = file_get_contents($confpath);
foreach ($config as $name => $value) {
    $contents = preg_replace('/(define\s*\(\'' . $name . '\',\s*)(.*)(\);)/', '$1"' . $value . '"$3', $contents);
}
file_put_contents($confpath, $contents);

function env($name, $default = null)
{
    $v = getenv($name) ?: $default;
    
    if ($v === null) {
        error('The env ' . $name . ' does not exist');
    }
    
    return $v;
}

function error($text)
{
    echo 'Error: ' . $text . PHP_EOL;
    exit(1);
}

function dbconnect($config)
{
    $map = array('host' => 'HOST', 'port' => 'PORT', 'dbname' => 'NAME');
    $dsn = $config['DB_TYPE'] . ':';
    foreach ($map as $d => $h) {
        if (isset($config['DB_' . $h])) {
            $dsn .= $d . '=' . $config['DB_' . $h] . ';';
        }
    }
    $pdo = new PDO($dsn, $config['DB_USER'], $config['DB_PASS']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $pdo;
}

function dbcheck($config)
{
    try {
        dbconnect($config);
        return true;
    }
    catch (PDOException $e) {
        return false;
    }
}

