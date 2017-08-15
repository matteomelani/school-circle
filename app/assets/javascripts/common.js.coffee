window.App ||= {}

App.KEYCODE_ENTER = 13
App.KEYCODE_ESC = 27


#------------------------------------------------------------------------------
# Shared functions and constants
#------------------------------------------------------------------------------
# Make sure varius div that are displayed side by side have the same heights
App.make_same_outser_height = (div1, div2) ->
	panel_height = Math.max($(div1).outerHeight(),$(div2).outerHeight());
	$(div1).css('height', panel_height)
	$(div2).css('height', panel_height)
	
App.make_same_height = (div1, div2) ->
		panel_height = Math.max($(div1).height(),$(div2).height())
		$(div1).css('height', panel_height)
		$(div2).css('height', panel_height)
	