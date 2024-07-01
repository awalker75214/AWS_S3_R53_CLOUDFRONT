#create s3 bucket
resource "aws_s3_bucket" "website_project" {
  bucket = "money-bucket-100"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.website_project.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.website_project.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

## 4. Attach S3-Cloudfront Policy (JSON)
##    Document to Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_project.id
  policy = data.aws_iam_policy_document.s3_cloudfront_policy.json
}


## 5. Grab Cloudfront OAI IAM_ARN Metadata
##    And Bucket_ARN Metadata
##    To Build S3-Cloudfront Policy (JSON) Document
data "aws_iam_policy_document" "s3_cloudfront_policy" {
    statement {
        actions     = ["s3:GetObject"]
        resources   = ["${aws_s3_bucket.website_project.arn}/*"]
    
        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.OAI.iam_arn]
        }
    }
}



resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.website_project.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website_project.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.website_project.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "profile" {
  bucket = aws_s3_bucket.website_project.id
  key = "IMG_0543.JPG"
  source = "IMG_0543.JPG"
  acl = "public-read"
  content_type  = "image/jpg"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_project.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.example ]
}