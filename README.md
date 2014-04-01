# [o3-video - HTML5 Video Player]
========

> o3-video is a web video player built on the basic web browser HTML5 player and tiny Flash video player. It supports video playback on desktops and mobile devices.

## Features

Lightweight, less than 10kb
Works on desktops and mobile devices
Supported web browsers: IE6+, Firefox, Chrome, Safari, Opera and more  

## Usage

Define the HTML5 video tag

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
	<video width="540" height="380" id="video1" controls poster="poster1.jpg">
		<source src="video1.mp4" type="video/mp4"> 
	</video>
</body>
</html>
```

## Requirements

[jQuery 1.7.2 or higher](http://jquery.com/download)

## License

Video.js is licensed under the MIT License. [View the license file](LICENSE)

Copyright 2014 Zoltan Fischer
