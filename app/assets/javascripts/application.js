// = require jquery
// = require jquery_ujs
// = require jquery-ui
// = require vendor
// = require common
// = require registrations
// = require_self




//------------------------------------------------------------------------------
// Shared functions and constants
//------------------------------------------------------------------------------

function get_scroll_offset(w) {
	w = w || window;
	// for all browser but no IE < 9 
	if (w.pageXOffset != null) {
		 return { x: w.pageXOffset, y: w.pageYOffset };
	}
	
	// for IE < 9
	var d=w.document;
	if (document.compactMode=="CSS1Compact") {
		return {x: d.documentElement.scrollLeft, y:d.documentElement.scrollTop}
	}
	
	// Quirks mode
	return { x:d.body.scrollLeft, y: d.body.scrollTop };
}

function hide_modal_window(div) {
	$(div).hide();
	$("#shadow").hide();
	$("body").css('overflow', 'scroll');
}

function show_modal_window(panel) {
    $(panel).show();
	$("body").css('overflow', 'hidden');
	$("#shadow").show();
    var event_data = {div:panel}; 
    $("#close").bind('click',  event_data, hide_modal_window_event);
	$(document).keyup(function(e) {
		if (e.keyCode == KEYCODE_ESC) {
			hide_modal_window(panel);
		}
	});
}

function hide_modal_window_event(e) {
	hide_modal_window(e.data.div);
}

function close_modal_window(div) {
	$(div).hide();
	$('#shadow').hide();
	$('body').css('overflow', 'scroll');
	$(div).remove();
}

function close_modal_window_event(e){
	close_modal_window(e.data.div);
}

function clearForm(form) {
  // iterate over all of the inputs for the form
  // element that was passed in
  $(':input', form).each(function() {
    var type = this.type;
    var tag = this.tagName.toLowerCase(); // normalize case
    // it's ok to reset the value attr of text inputs,
    // password inputs, and textareas
    if (type == 'text' || type == 'password' || tag == 'textarea')
      this.value = "";
    // checkboxes and radios need to have their checked state cleared
    // but should *not* have their 'value' changed
    else if (type == 'checkbox' || type == 'radio')
      this.checked = false;
    // select elements need to have their 'selectedIndex' property set to -1
    // (this works for both single and multiple select elements)
    else if (tag == 'select')
      this.selectedIndex = -1;
  });
};

function disable_submit_buttons(){
	// $('input[type=submit]').attr('disabled', true).css('background','#ccc'); 
	
	// addClass('greyed_out_botton');
}

function enable_submit_buttons(){
	// $('input[type=submit]').attr('disabled', false).css('background','#F26531');
}
    
Date.prototype.distance_of_time_in_words = function(to) {
  distance_in_milliseconds = to - this;

  distance_in_minutes = Math.round(Math.abs(distance_in_milliseconds / 60000));

  if (distance_in_minutes == 0) {
    words = "less than a minute";
  } else if (distance_in_minutes == 1) {
    words = "1 minute";
  } else if (distance_in_minutes < 45) {
    words = distance_in_minutes + " minutes";
  } else if (distance_in_minutes < 90) {
    words = "about 1 hour";
  } else if (distance_in_minutes < 1440) {
    words = "about " + (distance_in_minutes / 60).round() + " hours";
  } else if (distance_in_minutes < 2160) {
    words = "about 1 day";
  } else if (distance_in_minutes < 43200) {
    words = (distance_in_minutes / 1440).round() + " days";
  } else if (distance_in_minutes < 86400) {
    words = "about 1 month";
  } else if (distance_in_minutes < 525600) {
    words = (distance_in_minutes / 43200).round() + " months";
  } else if (distance_in_minutes < 1051200) {
    words = "about 1 year";
  } else {
    words = "over " + (distance_in_minutes / 525600).round() + " years";
  }

  return words;
};
Date.prototype.time_ago_in_words = function() {
  return this.distance_of_time_in_words(new Date());
};
function display_flash_message(){
	
	// Flash slides down and it stays on the screen
	$('#flash_region').slideDown(1000, function() {
		$('.flash_region_close').click(function(){
			$('#flash_region').hide();
		});
	});
}

function show_on_hover(hover_selector, what_to_show_selector){
	$(hover_selector).live({
		  mouseenter: function(){ $(this).find(what_to_show_selector).css('visibility','visible'); },
 		  mouseleave: function(){ $(this).find(what_to_show_selector).css('visibility','hidden');  }	
    });
}

//------------------------------------------------------------------------------
// Widget: webcam
//------------------------------------------------------------------------------
function load_js_for_webcam_widget(webcam_html, unique_id){
	var unique_class='.pp_'+unique_id+' ';
	$(unique_class+'#take_a_photo_button').live('click', function(){
		show_modal_window_full_screen('webcam_container', webcam_html);
		$(unique_class+'#cancel_button,'+unique_class+'#cancel_X').click(function(){
		 	$("#close_webcam_container").click();
		});
		$('#close_webcam_container').hide();
		$(unique_class+"#camera_image").webcam({
				width: 320,
				height: 240,
				mode: "callback",
				swffile: "/javascripts/jquery_plugins/jquery.webcam/jscam_canvas_only.swf",
				onTick: function() {
					if (0 == remain) {
					        jQuery(unique_class+"#status").text("Cheese!");
					    } else {
					        jQuery(unique_class+"#status").text(remain + " seconds remaining...");
					    }
				},
				onSave: function() {
					var col = data.split(";");
					var img = image;
					for(var i = 0; i < 320; i++) {
					        var tmp = parseInt(col[i]);
					        img.data[pos + 0] = (tmp >> 16) & 0xff;
					        img.data[pos + 1] = (tmp >> 8) & 0xff;
					        img.data[pos + 2] = tmp & 0xff;
					        img.data[pos + 3] = 0xff;
					        pos+= 4;
					}
					if (pos >= 4 * 320 * 240) {
					   ctx.putImageData(img, 0, 0);
					   pos = 0;
					}
				},
				onCapture: function() {
				    $(unique_class+'#save_button').css("color","white");
				},
				debug:  function (type, string) {},
				onLoad: function(){}
			});

		$(unique_class+"#snap_button").live('click',function(){
			webcam.capture();
		});
	});
}


//------------------------------------------------------------------------------
// Widget: profile_picture
//------------------------------------------------------------------------------
function load_js_for_avatar_widget(auth_token, uid, target_div){
	uid = uid || '';
	uid_selector='';
	target_div = target_div || '#avatar_id';
	var div_to_uploadify = '#zfile_asset' + uid;
	var img_selector = '.avatar_widget img';
	if (uid) {
		img_selector = '#'+ uid +' img.profile_picture';	
	    uid_selector = '#'+ uid +' ';
	}
    $(div_to_uploadify).uploadify({
		uploader       : '/assets/jquery_plugins/jquery.uploadify-v2.1.4/uploadify.swf',
		cancelImg      : '/assets/cancel.png',
		multi          : false,
		auto           : true,
		fileExt        : '*.jpg;*.gif;*.png;*.jpeg',
		fileDesc       : 'Image Files',
		sizeLimit      : 3048000,  
		queueSizeLimit : 1,
		script         : '/zfiles?auth_token='+auth_token,
		hideButton     : true,                                
		wmode          : 'transparent',
		onOpen : function(event, queueID, fileObj, response, data) 
		{
		   $(uid_selector + ' .submit_button').hide();	
		},
		onComplete : function(event, queueID, fileObj, response, data) 
		{ 
		    var dat = eval('(' + response + ')');
            $(target_div).append('<input type="hidden" name="avatar_id" value="'+dat.zfile_id+'" />');
	        $(img_selector).attr("src",dat.zfile_url.replace(/_original\./i,"_large."));
	        if ( $(uid_selector+'.remove_avatar').length > 0 ) 
	        {
	            $(uid_selector+'.remove_avatar').attr('href', '/zfiles/'+dat.zfile_id);
	        } 
	        else 
	        {
	            $(uid_selector+'#take_a_photo_button_container').before(
		                 '<a rel="nofollow" data-remote="true" data-method="delete" class="remove_avatar" href="/zfiles/'+dat.zfile_id+'">Remove this picture</a>');
		    }
		    $('.on_focus_message_container2').toggle();
		    $(uid_selector + '.submit_button').show();
	    },
	    onCancel : function(event, queueID, fileObj, response, data) {}
	});
		
    $(uid_selector+'.remove_avatar').live('click', function(){
        $(img_selector).attr("src", $('.default_avatar').attr('src').replace(/_original\./i,"_medium."));
	    $(this).remove();
	    $(target_div).find('input[name="avatar_id"]').remove();                      
    });
}

function reset_all_message_filters(){
	 $(".circle_metadata a").css('color','#6A737B').css('font-weight','normal');;
     $(".circle").css('background', '#f1f3ea');
     $('.user_strip .message_filter, .circle_metadata a').css('color', 'grey').css('font-weight','normal');
}

//------------------------------------------------------------------------------
// Widget: user_dashboard
//------------------------------------------------------------------------------
function load_js_for_user_dashboard_widget(){
}

//------------------------------------------------------------------------------
// Widget: modal_window
//------------------------------------------------------------------------------
function show_modal_window_full_screen(div, html){
	// insert into the body element the modal window div
	var unique_id = new Date().getTime();
	var unique_id_selector='.'+unique_id+' ';
	$('body').prepend(
		 '<div id="modal_window_'+div+'" class="modal_window '+unique_id+'">\
	        <div id="modal_window_container_'+div+'" class="modal_window_container">\
	          <div id="close_'+div+'" class="close"><a href="#">Close X</a></div>\
	          <div id="'+div+'">'+html+'</div>\
	          <div id="modal_window_container_footer_'+div+'" class="modal_window_container_footer"></div>\
	        </div>\
	      </div>');
	$('#modal_window_'+div).show();	
	$('body').css('overflow', 'hidden');
	$('#shadow').show();
	var event_data = {div:('#modal_window_'+div)}; 
	$('#close_'+div).bind('click',  event_data, close_modal_window_event);
	$(document).keyup(function(e) {
		if (e.keyCode == KEYCODE_ESC) {
			close_modal_window('#modal_window_'+div);
		}
	});
}

//------------------------------------------------------------------------------
// Page: all pages (application layout)
//------------------------------------------------------------------------------
function load_global_variables(current_user_id, current_user_sign_in_count, default_avatar_url){
	$.theschoolcircle = {
        user_id            : current_user_id, 
 		user_sign_in_count : current_user_sign_in_count,
		default_avatar_url : default_avatar_url
	};
}


jQuery(function() 
{

    // Prepare
    var History = window.History; // Note: We are using a capital H instead of a lower h
    if ( !History.enabled ) 
    {
       // History.js is disabled for this browser.
       // This is because we can optionally choose to support HTML4 browsers or not.
       return false;
    }
       
    //  Bind to StateChange Event
    History.Adapter.bind(window,'statechange',function(e)
    {
       var state = History.getState();
       eval(state.data.function_rest + "("+JSON.stringify(state)+");");		
       History.log(state);
    });
       	
    $('#loading')
	    .hide()  // hide it initially
	    .ajaxStart(function() {
	        $(this).show();
	    })
	    .ajaxStop(function() {
	        $(this).hide();
	    })
	;
	
    // $('input[type=submit]').attr('disabled', false);
    enable_submit_buttons();
	$('form').submit(function(){
        if ( ! $(this).isValid(clientSideValidations.validators.all() ) )
	    {
		}
		else
		{
           disable_submit_buttons();
        }
	});
	
	$.watermark.options.useNative = false;
	$.watermark.options.className='lightgrey-text';
	
	display_flash_message();
	
	App.make_same_outser_height(".left_panel", ".right_panel")
    
    // Header navigation links
	if ($("#page.users.show").length > 0 ) { 
		$("#header_nav_menu #homelink").css("color","black").css("font-weight","bold");
	}
	if ($("#page.profiles, #page.families.edit, #page.families.new, #page.registrations" ).length > 0 ) { 
		$("#header_nav_menu #profilelink").css("color","black").css("font-weight","bold");
	}
	
	if ($("#page.groups.index, #page.classrooms.index, #page.schools.index" ).length > 0 ) { 
		$("#header_nav_menu #circleslink").css("color","black").css("font-weight","bold");
	}
	
	// Profile navigation links
	if ($("#page.profiles").length > 0 ) { 
		$("a#myprofile").css("color","black").css("font-weight","bold");
	}
	if ($("#page.families.edit, #page.families.new").length > 0) { 
		$("a#myfamily").css("color","black").css("font-weight","bold");
	}
	if ($("#page.registrations").length > 0 ) { 
		$("a#myaccount").css("color","black").css("font-weight","bold");
	}
	if ($("#page.notifications").length > 0 ) { 
		$("a#mynotifications").css("color","black").css("font-weight","bold");
	}
	
	// Circles links
	if ($("#page.classrooms.index").length > 0 ) { 
		$("a#myclassrooms").css("color","black").css("font-weight","bold");
	}
	if ($("#page.classrooms.new, #page.classrooms.edit").length > 0 ) { 
		$("a#classroom_info").css("color","black").css("font-weight","bold");
	}
	
});


//------------------------------------------------------------------------------
// session form (sign in form)
//------------------------------------------------------------------------------
function load_js_for_session_form(){
	$('.signin a').mouseover(function(){
		$(this).fadeTo("fast", .70);
	}).mouseout(function(){
		$(this).fadeTo("fast", 1);	   	
	});
}


//------------------------------------------------------------------------------
// users show
//------------------------------------------------------------------------------
function load_js_for_users_show_page()
{
	// $('.message_filter.all').click();
}

function load_js_for_post_board_widget()
{
	
	window.onunload = function(){};
	
    // Change the color of the filters to tell user what filter is using
	// $('.user_strip .message_filter.all').addClass('black-text').addClass('bold-text');
	// 	$('.user_strip .message_filter').click(function(){
	// 		reset_all_message_filters();
	// 		$(this).css('color', 'black').css('font-weight','bold');
	// 	});	
	
	App.make_same_outser_height("#message_container", "#message_author_photo")
    App.make_same_outser_height("#reminder_container", "#reminder_author_photo")
   
	// Auto ellipses for text that is overflow  
	$(".autoellipsis").truncate({
		width: 'auto',
	    token: '&hellip;',
	    center: false,
	});
	
	// Make user can bookmark page and back and forward browser button work
	$('.message_filter').bind('click', function() 
	{
	    History.pushState({"function_rest":"restore_post_board_widget"}, document.title, this.href);
	    return false
	});
	
 
	if (Object.keys($.url().param()).length == 0) 
	{
		// there are no parameter in the url so no filter of posts
		reset_all_message_filters();
		$('.message_filter.all').css('color', 'black').css('font-weight','bold');
	}
	else
	{
		$('.message_filter').each(function(){
			var id_parts = $(this).attr('id').split("_");
			var filter_name = id_parts[2]
			var filter_param = id_parts[3]
			if ( $.url().param()[filter_name] && $.url().param()[filter_name] == filter_param )
			{
				reset_all_message_filters();
				$(this).css('color', 'black').css('font-weight','bold');
				return false;
			} 
		});
	}	
	// Ajaxfy pagination links
	$('.pagination a').bind('click', function () {  
	  History.pushState({"function_rest":"restore_post_board_widget"}, document.title, this.href);
	  return false;
	  });
    
    App.make_same_outser_height(".left_panel", ".user_feed");
    App.make_same_outser_height(".left_panel", ".right_panel");
    
    $('a.view_conversation').click(function()
    {
	   History.replaceState({"function_rest":"restore_post_board_widget"}, document.title, this.href);
	   return false;
    });

    $('.thread_info .back_link a').click(function()
    {
	   History.back(-1);     
    });
}

function restore_post_board_widget(state)
{	
	$.getScript(state.url);
}

//------------------------------------------------------------------------------
// users show (New Messages modal window)
//------------------------------------------------------------------------------
function removeAttachedFile(e) {
	$('input[value="'+e.data.asset_id+'"]').remove();
	$('#attached_file_'+e.data.asset_id).fadeOut(1000, function() { $(this).remove(); } );
    window.messageAttachments = window.messageAttachments - 1;
	//TODO: json call to destroy asset
	
}

function load_js_for_messages_new_page(auth_token) {
    
    App.make_same_height("#message_container", "#message_author_photo")
	App.make_same_height("#reminder_container", "#reminder_author_photo")
	App.make_same_height("#message_view_left_column","#message_view_right_column");
	
	tinyMCE.init({
          content_css : '/assets/tinyMCE.css?bogus=1306384393',
          editor_selector : 'mceEditor',
          font_size_style_values : '10px,12px,13px,14px,16px,18px,20px',
          language : 'en',
          mode : 'textareas',
 	      plugins : "fullscreen",
   		        fullscreen_new_window : false,
		        fullscreen_settings : {
		                theme_advanced_path_location : "none"
		        },
          theme : 'advanced',
          theme_advanced_buttons1 : 'bold,italic,underline,fontsizeselect,forecolor,|,bullist,numlist,|,outdent,indent, justifycenter,justifyright,justifyleft, blockquote',
		  theme_advanced_buttons2 : '',
          theme_advanced_buttons3 : '',
          theme_advanced_buttons1_add : "fullscreen",
          theme_advanced_containers_default_align : 'left',
          theme_advanced_font_sizes : '10px,12px,13px,14px,16px,18px,20px',
          theme_advanced_resizing : false,
          theme_advanced_toolbar_align : 'left',
          theme_advanced_toolbar_location : 'top'
          });
	
	
	 $(".message_recipient_container")
	     .live('click',function()
	     {
		     $('#message_recipient').focus();
		     $(this).addClass("blue_glow");
	     })
	     .live('blur',function()
	     {
		     $(this).removeClass("blue_glow");
		 });
	
	$('#message_recipient').live('focus', function(){
		$(this).catcomplete('search','');
	});
	
    //add live handler for clicks on remove links  
    $(".message_recipient_container .remove").live("click", function(){  
        $(this).parent().remove(); 
        $('#message_recipient').focus();
        $('#message_receiver_id').val("");
        $('#message_circle_id').val("");
    });

    // Add categories to the suggestion list
    $.widget( "custom.catcomplete", $.ui.autocomplete, 
    {  
	    _renderMenu: function( ul, items ) 
	  	{
		    var self = this,
		    currentCategory = "";
		    $.each(items, function(index, item) 
		    {
		       if (item.category != currentCategory ) 
		       {
		          ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" );
		          currentCategory = item.category;
		       }
		       self._renderItem( ul, item );
		    });
		},
		// add the description next to the menu item for ex: Matteo Melani(@matteomelani)
		// where "@matteomelani" is the user name or handle
		_renderItem: function( ul, item ) 
		{    
		    if (!item.desc) 
			{
				return $("<li></li>")
					.data("item.autocomplete", item)
					.append("<a>"+item.label+"</a>" )
					.appendTo(ul);
			}
			else
			{
		     return $("<li></li>")
				.data("item.autocomplete", item)
				.append("<a>"+item.label+"("+item.desc+")</a>" )
				.appendTo(ul);
			}
	    }
	});
	
	
	//TODO: the list of contacts is so short that we should get it when we load the user data.
    var cache = {}, lastXhr;
	$('#message_recipient').catcomplete({
		minLength: 0,
		autoFocus: true,
		source: function(request, response) 
		{ 
			//pass request to server
			var term = request.term;
			if ( term in cache ) 
			{
			    response(cache[term]);
				return;
			}
			request_end_point = $('#message_recipient').attr('data-endpoint-all-connections')
			// if term == '', message recipient field was just focus so just get the list of circles
			if ( !term ) 
			{
				request_end_point = $('#message_recipient').attr('data-endpoint-circles')
			}
			
		    lastXhr = $.getJSON(request_end_point, request, function(data, status, xhr ) 	
		    {  
			    cache[term] = data;
				if ( xhr === lastXhr ) { response( data ); }
            });  
        },
        select: function(e, ui) 
        {
	        if ( $(".selected_recipient").length == 1 )
	        {
		        alert("Sorry for now you can only send a message to one circle at a time!");
		        $("#message_recipient" ).val('');
		        $("#message_title").focus(); 
		        return false;
          	}
            span = '<span class="selected_recipient">'+ ui.item.value +  
                      '<a class="remove" href="javascript:" title="Remove this recipient">X</a>' +
		              '<div class=".recipient" style="display: none;">'+
					     '<input type="hidden" name="recipients[][id]" value="'+ui.item.id+'" />'+
			             '<input type="hidden" name="recipients[][type]" value="'+ui.item.type+'" />'+
					  '</div>'+
					'</span>';
            $(".message_recipient_container").append(span);
            if (ui.item.type == "User")
            {
	            $('#message_receiver_id').val(ui.item.id);  
            }
            else
            {
	            $("#message_circle_id" ).val(ui.item.id);
            }
            $("#message_recipient" ).val('');
			
			$("#unkown_recipient_error").hide();
			
			if ( $(".selected_recipient").length == 1 )
	        {
		        $("#message_title").focus();
          	}
			// this prevent the input field to be updated
			return false;
        },  
        focus: function() 
        {
		    // prevent value inserted on focus
		    return true;
		},
        change: function(evant, ui) 
        {  
            //prevent 'to' field being updated and correct position  
            // $("#message_recipient").val("").css("top", 2);  
			// ui.item is null if selection not in the list
			if (ui.item) 
			{
				$("#unkown_recipient_error").hide();
			} 
			else 
			{
              $("#unkown_recipient_error").html("You typed in the wrong recipent. You can only send message to circles you subscribe to.").show(); 
              $("#message_recipient" ).focus(); 				
			}
            return false;
        }  

	});
	
	// Code to handle attachments
	window.messageAttachments = 0;
	// make sure the input field #asset_asset is not focused on (I actually do not remember what this is for?)
	$('#file_asset').click(function(event){ 
		event.preventDefault();
	}); 
	$('#zfile_file').uploadify({
		uploader       : '/assets/jquery_plugins/jquery.uploadify-v2.1.4/uploadify.swf',
		cancelImg      : '/assets/cancel.png',
		multi          : true,
		auto           : true,
		sizeLimit      : 2048000,  
		queueSizeLimit : 4,
		script         : '/zfiles?auth_token='+auth_token,
		scriptAccess   : 'always',
		buttonText     : 'select files',
		onSelect: function (event, queueID, fileObj, response, data) 
		{
		    if ( window.messageAttachments >= 4) 
		    {
			   alert("Sorry, you cannot upload more than 4 attachments per message.");
			   jQuery('#zfile_asset').uploadifyCancel(queueID);   
			   return false;
		    }
		    window.messageAttachments = window.messageAttachments + 1;
		},
		onComplete : function(event, queueID, fileObj, response, data) 
		{ 
		     var zfile = eval('(' + response + ')');
             $('form#new_message #attached_zfiles').append('<input type="hidden" name="zfile_ids[]" value="'+ zfile.zfile_id+'" />');
             $('#attached_file_list').prepend('<div id="attached_file_'+zfile.zfile_id+'" class="attached-file"><span id="file_name">'+zfile.zfile_name+'</span><span id="delete"></span></div>');
             $('#attached_file_'+zfile.zfile_id+' #delete').bind('click', {zfile_id:zfile.zfile_id}, removeAttachedFile);
        },
	    onCancel : function(event, queueID, fileObj, response, data) 
	    {
		    window.messageAttachments = window.messageAttachments - 1;
		    return true;
	    },
	    onQueueFull : function (event,queueSizeLimit) 
	    {
		    alert("Sorry, you cannot upload more than 4 attachments per message.");
		    return false;
		}
    });
	$('#file_submit').click(function(event){ 
			event.preventDefault(); 
			('#file_asset').uploadifyUpload(); 
    });
	$('#my_circles a').bind('click',{},function(){
		$('#message_recipient').val($(this).text());
		$('#my_circles a').css('color','grey');
		$(this).css('color','#f26531');
	});
	
	
	$('#top_post_button').click(function()
	{
	   	$('#bottom_post_button').click();
	});
	
	$('#new_message').submit(function(event){
		if ( $(".selected_recipient").length == 0 ){
		   $("#unkown_recipient_error").html("You forgot to enter a recipient.").show();
		   $('#message_recipient').focus();
		   return false;
		}
		return true;
	});
 }


//------------------------------------------------------------------------------
// users show (Show Message modal window)
//------------------------------------------------------------------------------
function start_ipaper(div, id, key) {
    
   //  <a title="View Untitled on Scribd" 
   //              href="http://www.scribd.com/doc/56985363/Untitled" 
   //              style="margin: 12px auto 6px auto; font-family: Helvetica,Arial,Sans-serif; font-style: normal; font-variant: normal; font-weight: normal; font-size: 14px; line-height: normal; font-size-adjust: none; font-stretch: normal; -x-system-font: none; display: block; text-decoration: underline;">Untitled</a>
   //      <iframe 
   //           class="scribd_iframe_embed" 
   //           src="http://www.scribd.com/embeds/56985363/content?start_page=1&view_mode=list&access_key=key-q4fah1jrh6426c9bs1i" 
   //           data-auto-height="true" 
   //           data-aspect-ratio="0.772727272727273" 
   //           scrolling="no" 
   //           id="doc_16271" 
   //           width="100%" 
   //           height="600" 
   //           frameborder="0">
   //       </iframe>
   // 
   //    <script type="text/javascript">
   // 
   // (function() { 
   // 	var scribd = document.createElement("script"); 
   // 	scribd.type = "text/javascript"; 
   // 	scribd.async = true; 
   // 	scribd.src = "http://www.scribd.com/javascripts/embed_code/inject.js"; 
   // 	var s = document.getElementsByTagName("script")[0]; 
   // 	s.parentNode.insertBefore(scribd, s); 
   // 	})();
   // 	
   // 	</script>
 
   var scribd_doc = scribd.Document.getDoc(id, key);
   var oniPaperReady = function(e) {
        // scribd_doc.api.setPage(3);
    }
    scribd_doc.addParam( 'jsapi_version', 1 );
	scribd_doc.addParam('height', 700);
	scribd_doc.addParam('width', 500);
    scribd_doc.addEventListener( 'iPaperReady', oniPaperReady );
    scribd_doc.write( 'embedded_flash' );
}

function wait_for_return(e) {
	if (e.keyCode == KEYCODE_ENTER && !e.shiftKey) {
		$('#comment_form textarea').unbind('keyup');
		$('#new_comment').submit();
		$('#comment_form textarea').attr('disabled','true');
	}
}

function load_js_for_view_message() {
	App.make_same_outser_height("#message_container", "#message_author_photo")
	App.make_same_outser_height("#reminder_container", "#reminder_author_photo")
	App.make_same_outser_height("#message_view_left_column","#message_view_right_column"); 	
    $('#message_actions a:contains("new message")').live('click',jump_to_new_message_modal);

    $('#comment_form').hide();
	$('#fake_comment').watermark(' write a comment...');
	$('#comment_form textarea').bind('keyup', wait_for_return);
	$('#comment_comment').jqEasyCounter({
		'maxChars': 400,
		'maxCharsWarning': 380,
		'msgFontSize': '12px',
		'msgFontColor': '#F26531',
		'msgTextAlign': 'right',
		'msgWarningColor': '#F00',
		'msgAppendMethod': 'insertAfter'
	});
	$('#fake_comment').live('click',function(){
		$(this).hide();
		$('#comment_form').show();
		$('#comment_form textarea').focus();
		$('#comment_form textarea').elastic();
		
	});	
	$('#comment_form textarea').live('focusout',function(){
	 	$('#comment_form').hide();
 		$('#fake_comment').show();
	 });
	
	$('#new_comment')
	    .live("ajax:error", function(event, data, status, xhr) 
	    {
	        eval(data.responseText);
	    })
	    .live("ajax:complete", function(event, data, status, xhr)
	    {
		    $('#comment_form textarea').removeAttr("disabled");
		    $('#comment_form textarea').bind('keyup', wait_for_return);
	    });
	
	show_on_hover(".comment", '.actions');
		
	$(".comment .actions .delete")
	    .live('ajax:success', function()
        {
	        $(this).parents('.comment').fadeOut(1000, function() { $(this).remove(); } );
        });
	 
	// this is the comment Like button
	$('#new_acts_as_votable_vote')
	    .live("ajax:success", function(event, data, status, xhr) {
	      $(this).hide();
	      var l=$.parseJSON(xhr.responseText).votable_likes;
	      $(this).parents('#comment_actions').prev().html(l+((l>1) ? " people like" : " person likes"+ " this."));
	});
	
	// this is to display attachments
	$('a.action.view').click(function(){
	    $('#ipaper_viewer').show();
	    $('a.action.hide').show().click(function(){
		  $('#ipaper_viewer').hide();
		  $(this).hide();
     	});	
	});
    
    // the vote button has 3 states:
    //   - 'nil' which it means the user has not voted the message
    //   - 'true' the user voted up the message
    //   - 'false' the state voted down the message
    //  The jQuery one method is used to make sure the user can click only onece on the vote buttons.
    //  A user can only vote once. A user can chage his vote until he the view message page is opend.
    //   Once closed the vote cannot be changed anymore.

    var message_vote = $('.vote').attr('data-vote');
    var vote_id = $('.vote').attr('data-vote-id');
    if ( ! message_vote )
    {
	    // user has not vote yet
	    $('.vote_up_button').bind('click', create_vote_up);
	    
	    // when the create form is submitted we update the total count and bind the vote up button
	    // with the link to delete the just-casted vote
	    $('.message_vote_up')
		   .live("ajax:success", function(event, data, status, xhr) 
		   {
			   $('.vote').attr('data-vote', 'true');
		       var res = $.parseJSON(xhr.responseText); 
		       $('.vote_result').text(res.score);
		       
		       // flip images
		       var new_image_url = $('.vote_up_button img').attr('src').replace(/vote_up_32x32.png/,'vote_up_voted_32x32.png');
		       $('.vote_up_button img').attr('src', new_image_url);
		       
		       // flip title
		       flip_title('.vote_up_button');
		       
		       // set vote id in case user wants to delete it
		       $('a.vote_up_delete').attr('href','/votes/'+res.id);
		       
		       // re-enable buttons to voted up
		       $('.vote_up_button').bind('click', delete_vote_up);    
			   $('.vote_down_button').bind('click', create_vote_down);   
	       }
	    );
	    
	    // when the delete vote link is clicked we delete the vote with the id specified in href
	    // and we bind the vote up button to the create vote up form
	    $('a.vote_up_delete')
		   .live("ajax:success", function(event, data, status, xhr) 
		   {   
			   $('.vote').attr('data-vote', '');
		       var res = $.parseJSON(xhr.responseText); 
		       $('.vote_result').text(res.score);
		
		       // re-enable buttons to neutral
		       $('.vote_up_button').bind('click', create_vote_up);
		       $('.vote_down_button').bind('click', create_vote_down);
	       }
	    );
	   
	    // When I click the vote down button change the button image and submit the form to create the down vote
		$('.vote_down_button').bind('click',create_vote_down);
				
        $('.message_vote_down')
            .live("ajax:success", function(event, data, status, xhr) 
      		{
	            // set widget state
	            $('.vote').attr('data-vote', 'false');
      		    
                var res = $.parseJSON(xhr.responseText); 
				
                // update results
                $('.vote_result').text(res.score);
   		        
                // flip images
                var new_image_url = $('.vote_down_button img').attr('src').replace(/vote_down_32x32.png/,'vote_down_voted_32x32.png');;
			    $('.vote_down_button img').attr('src', new_image_url);
			     
			    // flip title
			    flip_title('.vote_down_button');
			    
			    // set vote id in case user wants to delete it
			    $('a.vote_down_delete').attr('href','/votes/'+res.id);
			    
			    // re-enable buttons to voted down
			    $('.vote_down_button').bind('click', delete_vote_down);
			    $('.vote_up_button').bind('click', create_vote_up);
   	        }
      	 );

	    // when the delete vote link is clicked we delete the vote with the id specified in href
	   	// and we bind the vote up button to the create vote up form
   	    $('a.vote_down_delete')
   		    .live("ajax:success", function(event, data, status, xhr) 
   		    {
	           // set widget state
	           $('.vote').attr('data-vote', '');
	
   		       var res = $.parseJSON(xhr.responseText); 
   	           
               // update result
          	   $('.vote_result').text(res.score);
   		       
               // re-enable buttons to neutral
               $('.vote_up_button').bind('click', create_vote_up);
		       $('.vote_down_button').bind('click', create_vote_down);
   	       }
   	    );
    
    }
    else
    {
	   // do nothin: user can vote only once
    }
}

function create_vote_up()
{
	// disable the buttons
	$('.vote_up_button').unbind('click');
	$('.vote_down_button').unbind('click');
	
    if ( $('.vote').attr('data-vote') == 'false' )
    {
	    // $('.vote_down_button').unbind('click');
	    alert("You have to undo your DOWN vote before voting up the message: just click on the down vote arrow again.");
	    // rebind the button
	    $('.vote_up_button').bind('click', create_vote_up);  
	    $('.vote_down_button').bind('click', delete_vote_down);
    }
    else
    {		    
        $('.message_vote_up').submit();
    }
}
function create_vote_down()
{
	$('.vote_up_button').unbind('click');
	$('.vote_down_button').unbind('click');
	if ( $('.vote').attr('data-vote') == 'true' )
    {
	    alert("You have to undo your UP vote before voting down the message: just click on the up vote arrow again."); 
	    $('.vote_down_button').bind('click',create_vote_down);  
	    $('.vote_up_button').bind('click', delete_vote_up);
    }
    else
    {
        $('.message_vote_down').submit();
    }	    
}
function delete_vote_up()
{
	//disable buttons
	$('.vote_up_button').unbind('click');
	$('.vote_down_button').unbind('click');
	
	// flip images
	var new_image_url = $('.vote_up_button img').attr('src').replace(/vote_up_voted_32x32.png/,'vote_up_32x32.png');;
	$('.vote_up_button img').attr('src', new_image_url);
	
	// flip title
	flip_title('.vote_up_button');
	
	// delete on server
	$('a.vote_up_delete').click();	
}
function delete_vote_down(vote)
{
    //disable buttons
	$('.vote_up_button').unbind('click');
	$('.vote_down_button').unbind('click');
	
	//flip images
	var new_image_url = $('.vote_down_button img').attr('src').replace(/vote_down_voted_32x32.png/,'vote_down_32x32.png');;
	$('.vote_down_button img').attr('src', new_image_url);
	
	// flip title
	flip_title('.vote_down_button');
	
	//delete on server
	$('a.vote_down_delete').click();	
}

function flip_title(a_div){
	// flip back title and undo title
	var buffer = $(a_div).attr('title');
    $(a_div).attr('title', $(a_div).attr('undo_title') );
    $(a_div).attr('undo_title', buffer);
}

function jump_to_new_message_modal() {
  // $('#close_show_message_page a').click(); 
  //$('#post_message_link').click();
}

//------------------------------------------------------------------------------
// users show (reminders new)
//------------------------------------------------------------------------------
function load_js_for_reminder_new_page() {
	show_modal_window('#modal_window');
	$('#shadow').hide();
	$('#close').css('visibility','hidden');
	$('#reminder_recipient').watermark('To');	
	$('#reminder_recipient').autocomplete({
		minLength: 0,
		source: $('#reminder_recipient').attr('data-endpoint'),
		select: function( event, ui ) {
			$("#reminder_recipient" ).val(ui.item.label);
			$("#reminder_circle_id" ).val(ui.item.id );
            return false;
		},
		change: function( event, ui ) {
			// ui.item is null if selection not in the list
			if ( ui.item ) {
				$("#unkown_recipient_error").hide();
			} else {
              $(this).val('');
              $("#unkown_recipient_error").html("You typed in the wrong recipent. You can only post reminder to the circles you subscribe to.").show();                				
			}
            return false;
		}	 
	});
	$('#new_reminder').submit(function(event){
		if ( !$("#reminder_recipient").val() ){
		   $("#unkown_recipient_error").html("You forgot to enter a recipient.").show();
		   $('#reminder_recipient').focus();
		   return false;
		}
		return true;
	});
	$('#reminder_recipient').focus();
	$('#reminder_content').watermark('you can type up to 140 chars');
	
	// Counts the chars in the reminders.
	// TODO: make sure that min version and regular are the same since I have changed the regular 
	// version to remove the "Characther word"  
	$('#reminder_content').jqEasyCounter({
		'maxChars': 140,
		'maxCharsWarning': 120,
		'msgFontSize': '18px',
		'msgFontColor': '#F26531',
		'msgFontFamily': 'Lucida Grande',
		'msgTextAlign': 'right',
		'msgWarningColor': '#F00',
		'msgAppendMethod': 'insertAfter' 
	});
	$('#reminder_window_close_button').click(function(){
		$("#close").click();
	});
}


//------------------------------------------------------------------------------
// profiles edit (My Profile page) 
//------------------------------------------------------------------------------
function load_js_for_profiles_edit_page(){
    $('#profile_location').watermark('e.g: Menlo Park, CA or 94025.');
    clientSideValidations.callbacks.element.fail = function(element, message, callback) {
	  callback();
	}
	clientSideValidations.callbacks.element.pass = function(element, callback) {
	  callback();
	}
	clientSideValidations.callbacks.form.fail = function(element, message, callback) {
	}
	clientSideValidations.callbacks.form.pass = function(element, callback) {
	 
	}
}


//------------------------------------------------------------------------------
// families edit (My Family page)
//------------------------------------------------------------------------------
function load_js_for_add_child_form(){
	enable_submit_buttons();
	$('form').submit(function(){
        disable_submit_buttons();
	});
	
	$('.add_fields').live('click',function(){
		var h =$('.new_child_page').height();
		$('.new_child_page').height(h+32);
	});
	$('.remove_fields.dynamic').live('click',function(){
		var h =$('.new_child_page').height();
		$('.new_child_page').height(h-32);
	});
}

function load_js_for_family_form()
{
	$('#family_about')
	     .focus(function(){
		    $(this).siblings('.on_focus_message_container').toggle();
	      })
	     .blur(function(){
		    $(this).siblings('.on_focus_message_container').toggle();
	     });	
}

function load_js_for_family_edit_page()
{
		
	show_on_hover('.membership','.actions');
	
	$('#child_memberships a.add').click(function(){
		show_modal_window_full_screen("add_child_form", $(this).attr("data-form"));   
	    // trigger client_side_validation
	    $('form.new_user[data-validate]').validate();
	});
	
	$('#child_memberships .actions  a.edit').live('click', function(){
	   show_modal_window_full_screen('child_form',$(this).attr("data-form"));	
	});
	
	$('.membership_invitation_container .actions a.delete')
	    .live('ajax:success', function()
        {
	        $(this).parents('.membership_invitation_container').fadeOut(1000, function() { $(this).remove(); } );
        });
	
    $('.membership .actions a.delete')
        .live('ajax:success', function()
      	{
	       $(this).parents('.membership').fadeOut(1000, function() { $(this).remove(); } );
	    });

	$('#child_memberships .actions a.delete')
	    .live("ajax:success", function() {
		   $(this).parents('.membership').fadeOut(1000, function() { $(this).remove(); } );
	    });
	
	load_js_for_add_child_form();
}

function load_js_for_update_child_profile(id, membership_html)
{
    $('.close').click();
    $('#membership_'+id).replaceWith(membership_html);
}

//------------------------------------------------------------------------------
// classrooms index (My Classrooms page)
//------------------------------------------------------------------------------
function load_js_for_classrooms_index_page(){
	
    $('#new_classroom') 
	     .live("ajax:complete", function(event, data, status, xhr){
		   enable_submit_buttons();
	     })
         .live('ajax:success', function(event, data, status, xhr){ 
            clearForm('form#new_classroom');
            $('.avatar_widget img').attr("src",$.theschoolcircle.default_avatar_url.replace(/_original\./i,"_large."));
         });
    if ($('.classrooms .classroom').length == 0) {
        $('.classrooms .info_message').show();
    }
    $('.actions a.delete, .actions a.leave').live('ajax:success', function(){
	    $(this).parents('.classroom').fadeOut(1000, function(){
	        $(this).remove();
			if ($('.classrooms .classroom').length == 0){
		       $('.classrooms .info_message').show();
		    }
	    });
    });
}

function load_js_for_classroom_new_page(){
	$('#classroom_name').focus();	
}


function load_js_for_circle_memberships_widget() {
	$(".membership .actions").click(function(){ 
	    $(this).find('.menu').toggle(); 
    });
   

    // $('.actions menu').
}


function load_js_for_classrooms_edit_page()
{ 
   $('.cancel_button').click(function(){
      History.back(-1);
   });
}



//------------------------------------------------------------------------------
// invitations new.js
//------------------------------------------------------------------------------
function is_valid_email_address(email) {
    var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
    return pattern.test(email);
};

function are_valid_email_addresses(comma_separated_emails) {
   var email = email_field.split(',');
   for (var i = 0; i < email.length; i++) {
       if ( ! is_valid_email_address(email[i]) ) {
          return false;
       }
   }
   return true;
}

function accept_recipient(ui){
	// $('#recipient').val(ui.item.label);
	$('.error_message').remove();
	var display_string = ui.item.name + ' ('+ui.item.email+')'
	if (ui.item.name==ui.item.email){
		display_string = ui.item.name
	} 
	var new_id = new Date().getTime();
	$('.invited_people').append(
		'<div id="invited_person_'+new_id +'" class="invited_person"> '+
		  '<div class="float-left">'+display_string+'</div>'+
		  '<input type="hidden" name="invited_persons[][name]" value="'+ui.item.name+'" />'+
          '<input type="hidden" name="invited_persons[][email]" value="'+ui.item.email+'" />'+
	      '<input type="hidden" name="invited_persons[][type]"  value="'+ui.item.type+'" />'+
	      '<input type="hidden" name="invited_persons[][id]" value="'+ui.item.id+'" />'+
	      '<div class="remove float-right" title="Remove this person.">X</div>'+
	      '<div class="clear"/>'+
	    '</div>'
	);
	$('#invited_person_'+new_id+' .remove').click(function(){
		$(this).parent().fadeOut(1000, function() { $(this).remove(); } );
		$('#invitation_page').height($('#invitation_page').height()-$(this).parent().outerHeight(true));
	});
	$('#invitation_page').height($('#invitation_page').height()+$('.invited_person').last().outerHeight(true));

}

function test_and_accept_email(email) {
	email = email.trim();
	if (is_valid_email_address(email)) 
	{
		var ui = { item: {name: email, email: email, type: 'Email', id: ''}}
		accept_recipient(ui);
	}
	else
	{
		$('#recipient').focus();
		$('#recipient').after('<div class="error_message red-text">Ooops "'+email+'" does not lool like an email address!</div>');
		return false;
	}
	return true;
}
function handle_invite_action() {
    var name = $(this).siblings('.name').text().trim();
	var email = $(this).siblings('.email').text().trim();
	// add invited person 
	var ui = { item: {name: name, email: email, type: 'Email', id: ''}}
	accept_recipient(ui);
}

function load_js_for_invitations_new_page(){
	$('.close a').hide();
	$('#invitation_page #cancel_X').click(function(){
	 	$(".close").click();
	});
	
	$('#recipient')
	   .autocomplete({
		minLength: 0,
		source: $('#recipient').attr('data-endpoint'),
		select: function(event, ui) {
			accept_recipient(ui);
			$('#recipient').val('');
			return false;
		} 
	});
	
	$('#recipient').focus();
	$('#recipient').bind('keypress', function(e){
	    if (e.keyCode == KEYCODE_ENTER && !e.shiftKey) 
	    {
	       $('#invitation_submit').focus();
	    }
	});
	$('#recipient').bind('focusout', function(e){
        $('.error_message').remove();
		if (!$('#recipient').val())
		{
		   return true;   	
		}
		var r = $('#recipient').val().split(',');
		if ( r.length == 1 ) // Single email address
		{
            if ( test_and_accept_email(r[0]) ) {$('#recipient').val('');}
		} 
		else if ( r.length > 1 ) // Comma separated list of emails
		{
	        for (var i = 0; i < r.length; i++) 
	        {
			    if (! test_and_accept_email(r[i]) ) { return; }
			}
			$('#recipient').val('');			
	    } 
	    else
	    {	
		    $('#recipient').focus();
		    $('#recipient').after('<div class="error_message red-text">Ooops I cannot understand the email address</div>');
		}
	});
	enable_submit_buttons();
	$('form').submit(function(){
        disable_submit_buttons();
	});
	$('form#new_invitation')
        .live("ajax:complete", function(event, data, status, xhr){
		   enable_submit_buttons();
	    })
        .live("ajax:success", function(event, data, status, xhr) {
		    var invitations=$.parseJSON(xhr.responseText);
	       	for (var i = 0; i < invitations.length; i++) 
	        {
		        var current_time = new Date();
		        var invitation = invitations[i].invitation;
	        	$('#close_invitation_page').click();
			    if ($('.membership_invitations').length > 0)
		        {
			       $('.membership_invitations').prepend(
				       '<div class="membership_invitation_container">'+
				         '<div class="membership_invitation">'+
				            invitation.email+ ' was invited '+ (new Date(invitation.sent_on)).time_ago_in_words() +'  ago. Invitation expires in ' + (new Date(current_time-((new Date(invitation.expires_on))-current_time))).time_ago_in_words()+
				         '</div>'+
				         '<div class="actions_container">'+
				            '<div class="actions float-right">'+
				                '<a title="delete invitation" rel="nofollow" data-remote="true" data-method="delete" class="delete orange-text" href="/circles/'+invitation.circle_id+'/invitations/'+invitation.id+'.json">X</a>'+
				            '</div>'+
				         '</div>'+
				         '<div class="clear"></div>'+
				       '</div>');
	            }
		   }
        });

	$('.invite_action').bind('click', handle_invite_action)
}




//------------------------------------------------------------------------------
// groups index (my circle page)
//------------------------------------------------------------------------------
function load_js_for_groups_index_page(){
  	if ($("#page.groups.index").length > 0 ) { 
		$("a#mygroups").css("color","black").css("font-weight","bold");
	}
	
	$('.circle').each(function(){
		var cc = $(this).find('.circle_info_container');
		var cm = $(this).find('.circle_members_container');
		App.make_same_height(cc,cm);
	});
	
	$('#new_group')
		.live("ajax:complete", function(event, data, status, xhr){
			enable_submit_buttons();
		 })
         .live('ajax:success', function(event, data, status, xhr){ 
            clearForm('form#new_group');
            $('.avatar_widget img').attr("src",$.theschoolcircle.default_avatar_url.replace(/_original\./i,"_large."));
    });
	if ($('.circles .circle').length == 0) {
        $('.circles .info_message').show();
    }
    $('.actions a.delete, .actions a.leave')
        .live('ajax:success', function()
        {
	        $(this).parents('.circle').fadeOut(1000, function()
	        {
		         $(this).remove();
		   	     if ( $('.circles .circle').length == 0)
		         {
		             $('.circles .info_message').show();
		         }
	       });
        });
}

function load_js_for_schools_index_page()
{
	if ($("#page.schools.index").length > 0 ) { 
		$("a#myschools").css("color","black").css("font-weight","bold");
	}
}