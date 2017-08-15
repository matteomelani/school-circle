
App.load_js_for_registrations_edit_page = ->
	$('.update_password_box').click( ->$('.update_password').toggle(); $('.right_panel').height( $('.right_panel').height() + 200 );)