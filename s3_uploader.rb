# s3_uploader.rb

require "aws-sdk-s3"

# Upload the CSV file to an S3 bucket
s3 = Aws::S3::Resource.new(region: "us-east-1")
bucket = s3.bucket("my-bucket")
obj = bucket.object("data.csv")
obj.upload_file("data.csv")
