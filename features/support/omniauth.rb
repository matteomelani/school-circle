
Before('@omniauth_google_failure_test') do
  OmniAuth.config.test_mode = true

  # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
  OmniAuth.config.mock_auth[:open_id] = :invalid_credentials
end


Before('@omniauth_aol_failure_test') do
  OmniAuth.config.test_mode = true

  # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
  OmniAuth.config.mock_auth[:open_id] = :invalid_credentials
end

Before('@omniauth_facebook_google_test') do
  OmniAuth.config.test_mode = true

  # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
   OmniAuth.config.mock_auth[:facebook] = {
     'provider' => 'facebook',
     'uid'      => "531564247",
     'credentials' => {
       'token'=> "189157821119422|2.NKt21XnznTNEDPGYXI2UUw__.3600.1300309200-531564247|Mi0DhWREl6g-T9bMZnL82u7s4MI"
       },
     'user_info' => { 
       'nickname'   => "profile.php?id=531564247",
       'email'      => "matteomelani@yahoo.com",
       'first_name' => "Matteo",
       'last_name'  => "Melani",
       'name'       => "Matteo Melani",
       'image'      => "http://graph.facebook.com/531564247/picture?type=square",
       'urls'       => {
         'facebook' => "http://www.facebook.com/profile.php?id=531564247", 
         'website'  => ""
         }
     },
     'extra' => { 
       'user_hash' => { 
           'id'         => "531564247",
           'name'       => "Matteo Melani",
           'first_name' => "Matteo",
           'last_name'  => "Melani",
           'link'       => "http://www.facebook.com/profile.php?id=531564247",
           'birthday'   => "04/17/1972",
           'hometown'   => { 
             'id'   => "104048449631599",
             'name' => "Menlo Park, California"
           },
           'location' => { 
             'id'   => "104048449631599",
             'name' => "Menlo Park, California"
           },
           'gender'   => "male",
           'email'    => "matteomelani@yahoo.com",
           'timezone' => "-7",
           'locale'   => "en_US",
           'verified' => true
         }
       }
     }
  # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
  OmniAuth.config.mock_auth[:open_id] = 
  {
      'provider'  => "open_id",
      'uid'       => "https://www.google.com/accounts/o8/id?id=118181138998978630963",
      'user_info' => {'email' => "matteomelani@yahoo.com", 'first_name' => "Test", 'last_name' => "User", 'name' => "Test User"}
  }
end
