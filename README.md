# o3-video - HTML5 / Adobe Flash Video Player
========

> o3-video is a HTML5 video player built on the web browser's basic HTML5 player and a small Adobe Flash video player. It supports video playback on desktops and mobile devices.

## Features

* Lightweight, less than 40kb
* Works on desktops and mobile devices
* Plays mp4, with h264 codec, on all devices
* Supported web browsers: iOS (v3.0+), Android (v3.0+), Windows Mobile (v10+), Internet Explorer (v5.5+), Mozilla Firefox, Chrome, Safari, Opera 

## Usage

```html
<!DOCTYPE html>
<head>
	<title>o3-video usage</title>	
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
	<script src="//raw.githubusercontent.com/zoli-fischer/o3-video/master/o3-video.min.js"></script>
	<script type="text/javascript">
	    (function($) {
	        $(document).ready(function () {                             
	            $('video').o3video();        
	        });
	    })(jQuery);
	</script>
</head>
<body>
	<video width="540" height="380" controls poster="poster1.jpg">
		<source src="video1.mp4" type="video/mp4"> 
	</video>
</body>
</html>
```

## Requirements

[jQuery 1.6.0 or higher](http://jquery.com/download)

## License

o3-video is licensed under the MIT License. [View the license file](LICENSE)

Copyright 2014 Zoltan Fischer
