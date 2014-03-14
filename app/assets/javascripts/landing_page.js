scroll_up = function() {
	$('#anchor').click(function() {
		$('html, body').animate({
        	scrollTop: $( '#sign_up' ).offset().top
    	}, 500);
    	return false;
	});
}

$(document).ready(scroll_up);