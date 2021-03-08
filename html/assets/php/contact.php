<?php

// ENTER YOUR EMAIL
$emailTo = "yourmail@example.com";

// ENTER IDENTIFIER
$emailIdentifier =  "Message sent via contact form from " . $_SERVER["SERVER_NAME"];


if($_POST) {

    $name = addslashes(trim($_POST["name"]));
    $clientEmail = addslashes(trim($_POST["email"]));
    $message = addslashes(trim($_POST["message"]));
	$fhp_input = addslashes(trim($_POST["company"]));

    $array = array("nameMessage" => "", "emailMessage" => "", "messageMessage" => "","succesMessage" => "");

    if($name == "") {
    	$array["nameMessage"] = "x";
    }
	
    if(!filter_var($clientEmail, FILTER_VALIDATE_EMAIL)) {
        $array["emailMessage"] = "x";
    }
	
    if($message == "") {
        $array["messageMessage"] = "x";
    }
	
    if($name != "" && filter_var($clientEmail, FILTER_VALIDATE_EMAIL) && $message != "" && $fhp_input == "") {
		
		$array["succesMessage"] = "";
		
		$headers  = "MIME-Version: 1.0" . "\r\n";
        $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
		$headers .= "From: " . $name . " <" . $clientEmail .">\r\n";
		$headers .= "Reply-To: " . $clientEmail;
		
		mail($emailTo, $emailIdentifier, $message, $headers);
		
    }

    echo json_encode($array);

}

?>