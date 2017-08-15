module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home page/
      '/'

    when /the sign up page/
      '/users/signup'
    
    when /the sign in page/
      '/users/signin'
    
    when /the sign out page/
      '/users/signout'
    
    when /the new family page/
      '/families/new'
      
    when /the schools page/
      '/schools'
  
    when /^(.*)'s home page$/i
      s = user_path(User.find_by_email($1)) + "/post_board"
    
    when /^(.*)'s account page$/i
      edit_user_account_path(User.find_by_email($1))
    
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
