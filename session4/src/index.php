<?php
// src/index.php

header('Content-Type: text/plain');

echo "PHP Nomad Lab: Verifying MySQL Connection\n";
echo "========================================\n\n";

// These environment variables are populated by the Nomad 'template' stanza
$db_host     = getenv('DB_HOST');
$db_port     = getenv('DB_PORT');
$db_name     = getenv('DB_NAME');
$db_user     = getenv('DB_USER');
$db_password = getenv('DB_PASS');

echo "Database Configuration:\n";
echo "Host: $db_host\n";
echo "Port: $db_port\n";
echo "Database: $db_name\n";
echo "User: $db_user\n";
echo "Password: $db_password\n\n";