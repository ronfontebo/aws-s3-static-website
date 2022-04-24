# This is a terraform script to create a route 53 hosted zone and route 53 A-record
#===================================================================================
# Steps:
#=======
# *** Register your domain name with route53 if you don't already have one
# Create a route53 public hosted zone for root domain
# Create route53 A-record for root domain                 **** (A (Address) record =/ alias)
# Create route53 A-record for subdomain 
#-----------------------------------------------------------------------------------------------------------



# Create route53 public hosted zone for root domain
#------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "root_domain" {
  name = "${var.root_domain}"
}



# Create route53 A-record for root domain
#------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "root_domain" {
  zone_id = "${aws_route53_zone.root_domain_id}"
  name    = "${var.root_domain}"
  type    = "A"

  alias {
    name                   = "${var.root_domain}"                    # Domain name for a CloudFront distribution, S3 bucket, in this hosted zone.
    zone_id                = "${aws_route53_zone.root_domain_id}"    # Hosted zone ID for a CloudFront distribution, S3 bucket   
    evaluate_target_health = false                                   # true
  }
}


# Create route53 A-record for subdomain
#------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "subdomain" {
  zone_id = "${aws_route53_zone.root_domain_id}"
  name    = "www.${var.root_domain}"
  type    = "A"

  alias {
    name                   = "www.${var.root_domain}"                # Domain name for a CloudFront distribution, S3 bucket, in this hosted zone.
    zone_id                = "${aws_route53_zone.root_domain_id}"    # Hosted zone ID for a CloudFront distribution, S3 bucket    
    evaluate_target_health = false                                   # true
  }
}

#************************************************************************************************************
#                                      End of route53 setup!!    
#************************************************************************************************************