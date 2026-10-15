cat << 'EOF' > /var/www/html/index.php
<?php
header('Content-Type: application/json');

$host = '10.64.4.11';
$db   = 'db_shibuya_k01';
$user = 'admin_shibuya';
$pass = 'admin123';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Koneksi DB gagal: " . $conn->connect_error]);
    exit();
}

$hostname = gethostname();
$pesan = "Request API diproses oleh: " . $hostname;

// Mengambil IP Klien Asli (X-Real-IP) dari header yang diteruskan oleh Geto
$client_ip = isset($_SERVER['HTTP_X_REAL_IP']) ? $_SERVER['HTTP_X_REAL_IP'] : $_SERVER['REMOTE_ADDR'];

// Query untuk menyimpan ke tabel request_logs beserta kolom client_ip
$sql = "INSERT INTO request_logs (pesan, client_ip) VALUES ('$pesan', '$client_ip')";

if ($conn->query($sql) === TRUE) {
    echo json_encode([
        "status" => "success", 
        "message" => "Log dicatat di DB oleh " . $hostname,
        "recorded_ip" => $client_ip
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mencatat log: " . $conn->error]);
}
$conn->close();
?>
EOF