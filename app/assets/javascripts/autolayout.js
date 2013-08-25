// The main function to adjust the layout. This can't run until the window is loaded or the various styles are not actually set and can't be read.
function autolayout()
	{
	var scrw = $(window).width();
	
	// read height of various screen elements. There were some issues with floated elements. Containers containing floated elements needed to be floated themselves otherwise their contents weren't counted. When it came to the width calculation, #contentcontainer needed floating left otherwise jquery returned the entire screen width. The content will still always appear beneath the header despite them all being floated left, as the content will always be given a left margin that will push it below the header.
	contwidth = $("#container").outerWidth(true);
	
	// set left margin of each element
	var n = (scrw-contwidth)/2;
	if (n<2)
		n=2;
	leftmargin = n.toFixed(0) + "px"; // 'var' is not used to declare this variable to make it global so can be accessed outside function.
	$("#container").css("margin-left",leftmargin);
	
	document.getElementById("container").style.visibility = "visible";
	}