class Document < LibraryItem
  
  # Each Document points to an asset (an asset is a real file stored on Amazon S3).
  belongs_to :file
  
end