# Route 53 #

 data "aws_route53_zone" "hosted-zone" {        # Already have a hosted zone via aws console, so import data
   name = "amirb.uk"
 }

resource "aws_route53_record" "threat-sub-domain" {
  zone_id = data.aws_route53_zone.hosted-zone.id
  name    = "ecs.amirb.uk"
  type    = "CNAME"
 
  ttl    = 300
  records = [aws_lb.threat-alb.dns_name]
}