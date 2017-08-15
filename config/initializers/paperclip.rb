## this allows us to use the user id to build the paperclip file name
##
Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end

Paperclip.options[:log_command] = true
Paperclip.options[:log] = true