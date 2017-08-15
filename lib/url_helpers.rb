module UrlHelpers

   # If the url starts with / it returns the url of the files on the AWS storage public 
   # folder (either S3 or CloudFront) else it returns the url untouched. For example:
   #
   # /images/my_image.png => http://s3.amazonaws.com/#{bucket}/images/my_image.png
   #
   # http:www.bla.com/my_image.png => http:www.bla.com/my_image.png
   #
   # The bucket is loaded from S3.yml and depends on the Rails.env.
   #
   # The AWS storage public folder is a folder that mimic the Rails public folder and 
   # its purpose is to serve the web app static assets and user 
   # generated content (public/content).
   # 
   def UrlHelpers.get_aws_public_url(url)
     if url.start_with?("/")
       bucket = YAML.load_file("config/s3.yml")[Rails.env]["bucket"] 
       "http://s3.amazonaws.com"+"/#{bucket}/public" + url
     else
       url
     end
     # change the s3 url to cloud front url if CLOUDFRONT_DISTRIBUTION is defined
     #url.gsub( "http://s3.amazonaws.com/built-for-speed", CLOUDFRONT_DISTRIBUTION )

     #TODO: enable cloudfront distribution in production by editing s3.yml: add cloudfront_distribution for 
     # the bucket that are configured on cloudfront: production, staging for sure, maybe test
   end
   
end