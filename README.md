# o3-video - HTML5 / Adobe Flash Video Player

> o3-video is a HTML5 video player built on the web browser's basic HTML5 player and a small Adobe Flash video player. It supports video playback on desktops and mobile devices.

## Features

* Plays mp4 ( with h264 codec ) on all devices
* Works on desktops and mobile devices
* Supported web browsers: iOS (v3.0+), Android (v3.0+), Windows Mobile (v10+), Internet Explorer (v5.5+), Mozilla Firefox, Chrome, Safari, Opera 
* Lightweight, less than 40kb
* Multi language interface with auto-detect of web browser's language (Supported languages: English, Danish, Hungarian)

## Demo

[Click here for live demo](//o3-video.s3.amazonaws.com/demo.html)

Scan this QR code for live demo on your phone or table:

![](http://o3-video.s3.amazonaws.com/qr.png)

## Sample Code

```html
<!DOCTYPE html>
<head>
	<title>o3-video Sample Code</title>	
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
	<script src="o3-video/o3-video.min.js"></script>
	<script type="text/javascript">
	    (function($) {
	        $(document).ready(function () {                             
	            $('#video1').o3video();        
	        });
	    })(jQuery);
	</script>
</head>
<body>
	<video width="540" height="380" controls poster="poster1.jpg" id="video1">
		<source src="video1.mp4" type="video/mp4"> 
	</video>
</body>
</html>
```

#Compatibility

Confirmed as working with iOS (v4.0+), Android (v3.0+), Windows Mobile (v10+), Internet Explorer (v5.5+), Mozilla Firefox, Chrome, Safari, Opera. Web browsers without HTML 5 video tag support or mp4 (h264 codec) codec needs Adobe Flash Player v9.0+. 

## Requirements

[jQuery 1.6.0 or higher](http://jquery.com/download)

## Download

[Click here for download](https://github.com/zoli-fischer/o3-video/raw/master/o3-video.1.1.0.zip)

## License

o3-video is licensed under the MIT License. [View the license file](LICENSE)

Copyright 2014 Zoltan Fischer
