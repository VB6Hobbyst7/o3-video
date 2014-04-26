# o3-video - HTML5 Video Player
========

> o3-video is a web video player built on the web browser's basic HTML5 player and a tiny Flash video player. It supports video playback on desktops and mobile devices.

## Features

* Lightweight, less than 20kb
* Works on desktops and mobile devices
* Plays mp4, with h264 codec, on all devices
* Supported web browsers: IE8+, Firefox, Chrome, Safari, Opera and more  

## Usage

```html
<!DOCTYPE html>
<head>
	<title>o3-video usage</title>	
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
	<script src="o3-video.source.js"></script>
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
