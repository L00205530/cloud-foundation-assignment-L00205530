**# Testing Report**



**## Static website**


**| Test | Expected result | Actual result |

| CloudFormation validation | Valid template | Passed |**


PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws cloudformation validate-template `

>>   --template-body file://infra/static-website.yaml `

>>   --region eu-west-1

{

&#x20;   "Parameters": \[],

&#x20;   "Description": "Static website for the CloudFormation Assignment 2026. Website content is stored in a private S3 bucket and served by CloudFront.\\n"

}



**| CloudFront endpoint | HTTP 200 | Passed |**



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws cloudfront list-distributions `

>>   --query "DistributionList.Items\[\*].\[Id,DomainName,Status]" `

>>   --output table

\----------------------------------------------------------------

|                       ListDistributions                      |

+-----------------+--------------------------------+-----------+

|  E3EJHCVO1TKZP8 |  dz3999bhs13vt.cloudfront.net  |  Deployed |

+-----------------+--------------------------------+-----------+

PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> curl.exe -I https://dz3999bhs13vt.cloudfront.net

HTTP/1.1 200 OK

Content-Type: text/html

Content-Length: 978

Connection: keep-alive

Server: AmazonS3

Date: Sun, 01 Nov 2026 20:15:09 GMT

Last-Modified: Sun, 01 Nov 2026 12:55:25 GMT

ETag: "09fe16c560cf984f600cf636bd2b1a79"

x-amz-server-side-encryption: AES256

Accept-Ranges: bytes

X-Cache: Miss from cloudfront

Via: 1.1 e85f40b9e4a0224c05d79e84598c0254.cloudfront.net (CloudFront)

X-Amz-Cf-Pop: DUB56-P1

Alt-Svc: h3=":443"; ma=86400

X-Amz-Cf-Id: CL\_\_\_OM6jfcYQkzX-69zEjyy7iwJ4rx6pqOh0d6sIqRsRukrEmUzlQ==

**| HTTPS | HTTP redirects to HTTPS | Passed |

| Website content | Correct name and L-number | Passed |**



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> curl.exe -s https://dz3999bhs13vt.cloudfront.net

<!DOCTYPE html>

<html lang="en">

<head>

&#x20;   <meta charset="UTF-8">

&#x20;   <meta name="viewport" content="width=device-width, initial-scale=1">

&#x20;   <meta name="description" content="CloudFormation assignment static website">

&#x20;   <title>CloudFormation Assignment</title>

&#x20;   <link rel="stylesheet" href="styles.css">

</head>

<body>

&#x20;   <header>

&#x20;       <h1>L00205530 — Ronald Torres</h1>

&#x20;       <p>CloudFormation Assignment 2026</p>

&#x20;   </header>



&#x20;   <main>

&#x20;       <section>

&#x20;           <h2>Welcome</h2>

&#x20;           <p>This static website is deployed using AWS CloudFormation,

&#x20;              Amazon S3 and Amazon CloudFront.</p>

&#x20;       </section>



&#x20;       <section>

&#x20;           <h2>Infrastructure as Code</h2>

&#x20;           <p>The infrastructure is defined in version-controlled

&#x20;              CloudFormation YAML templates.</p>

&#x20;       </section>

&#x20;   </main>



&#x20;   <footer>

&#x20;       <p>CloudFormation Lab — 2026</p>

&#x20;   </footer>

</body>

</html>





**## Three-tier architecture**



**| Test | Expected result | Actual result |**


**| CloudFormation validation | Valid template | Passed |**

PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws cloudformation validate-template `

>>   --template-body file://infra/three-tier.yaml `

>>   --region eu-west-1

{

&#x20;   "Parameters": \[

&#x20;       {

&#x20;           "ParameterKey": "EnvironmentName",

&#x20;           "DefaultValue": "cloudlab",

&#x20;           "NoEcho": false,

&#x20;           "Description": "Prefix for this lab's resource names"

&#x20;       },

&#x20;       {

&#x20;           "ParameterKey": "DBInstanceClass",

&#x20;           "DefaultValue": "db.t3.micro",

&#x20;           "NoEcho": false

&#x20;       },

&#x20;       {

&#x20;           "ParameterKey": "LatestAmiId",

&#x20;           "DefaultValue": "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86\_64",

&#x20;           "NoEcho": false,

&#x20;           "Description": "Latest Amazon Linux 2023 AMI ID for this region"

&#x20;       },

&#x20;       {

&#x20;           "ParameterKey": "InstanceType",

&#x20;           "DefaultValue": "t3.micro",

&#x20;           "NoEcho": false

&#x20;       }

&#x20;   ],

&#x20;   "Description": "Three-tier CloudFormation lab architecture. Public load balancer, private application server and private RDS database.\\n"

}

**| Stack deployment | CREATE\_COMPLETE | Passed |**


PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws cloudformation list-stacks `

>>   --stack-status-filter CREATE\_COMPLETE UPDATE\_COMPLETE `

>>   --region eu-west-1 `

>>   --query "StackSummaries\[\*].\[StackName,StackStatus]" `

>>   --output table

\------------------------------------------

|               ListStacks               |

+--------------------+-------------------+

|  cf-three-tier     |  CREATE\_COMPLETE  |

|  cf-static-website |  CREATE\_COMPLETE  |

+--------------------+-------------------+




**| Load balancer request | HTTP 200 | Passed |**


PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws elbv2 describe-load-balancers `

>>   --region eu-west-1 `

>>   --query "LoadBalancers\[\*].\[LoadBalancerName,DNSName,State.Code]" `

>>   --output table

\------------------------------------------------------------------------------------------------------------

|                                           DescribeLoadBalancers                                          |

+----------------------------+-------------------------------------------------------------------+---------+

|  cf-thr-Publi-Dof0BAxorSGD |  cf-thr-Publi-Dof0BAxorSGD-303545619.eu-west-1.elb.amazonaws.com  |  active |

+----------------------------+-------------------------------------------------------------------+---------+



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> curl.exe -I cf-thr-Publi-Dof0BAxorSGD-303545619.eu-west-1.elb.amazonaws.com

HTTP/1.1 200 OK

Date: Sun, 01 Nov 2026 20:25:31 GMT

Content-Type: text/html; charset=UTF-8

Content-Length: 305

Connection: keep-alive

Server: Apache/2.4.69 (Amazon Linux)

Last-Modified: Sun, 01 Nov 2026 13:54:57 GMT

ETag: "131-65f375fe98b42"

Accept-Ranges: bytes

**| Target health | Healthy | Passed |**


PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws elbv2 describe-target-groups `

>>   --region eu-west-1 `

>>   --query "TargetGroups\[\*].\[TargetGroupName,TargetGroupArn]" `

>>   --output table

\---------------------------------------------------------------------------------------------------------------------------------------------

|                                                           DescribeTargetGroups                                                            |

+---------------------------+---------------------------------------------------------------------------------------------------------------+

|  cf-thr-Appli-4GTULE7WUZ4Y|  arn:aws:elasticloadbalancing:eu-west-1:816435462788:targetgroup/cf-thr-Appli-4GTULE7WUZ4Y/bf6b6d1111a3ec5f   |+---------------------------+---------------------------------------------------------------------------------------------------------------+



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws elbv2 describe-target-health `

>>   --target-group-arn arn:aws:elasticloadbalancing:eu-west-1:816435462788:targetgroup/cf-thr-Appli-4GTULE7WUZ4Y/bf6b6d1111a3ec5f `

>>   --region eu-west-1 `

>>   --query "TargetHealthDescriptions\[\*].\[Target.Id,TargetHealth.State,TargetHealth.Reason]" `

>>   --output table

\--------------------------------------------

|           DescribeTargetHealth           |

+----------------------+-----------+-------+

|  i-00405572d6dd0eaab |  healthy  |  None |

+----------------------+-----------+-------+

**| EC2 public IP | None | Passed |**


PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws ec2 describe-instances `

>>   --region eu-west-1 `

>>   --filters "Name=instance-state-name,Values=running" `

>>   --query "Reservations\[\*].Instances\[\*].\[InstanceId,PrivateIpAddress,PublicIpAddress,SubnetId]" `

>>   --output table

\-----------------------------------------------------------------------------

|                             DescribeInstances                             |

+----------------------+---------------+-------+----------------------------+

|  i-00405572d6dd0eaab |  10.20.10.196 |  None |  subnet-0e414008eb57adc56  |





**| RDS public access | Disabled | Passed |**



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws rds describe-db-instances `

>>   --region eu-west-1 `

>>   --query "DBInstances\[\*].\[DBInstanceIdentifier,Engine,PubliclyAccessible,DBInstanceStatus]" `

>>   --output table

\---------------------------------------------------------------------------

|                           DescribeDBInstances                           |

+-----------------------------------------+--------+--------+-------------+

|  cf-three-tier-labdatabase-igkx7lxvneoh |  mysql |  False |  available  |

+-----------------------------------------+--------+--------+-------------+

**| Database integration | Passed |**



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws rds describe-db-instances `

>>   --region eu-west-1 `

>>   --query "DBInstances\[\*].\[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]" `

>>   --output table

\---------------------------------------------------------------------------------------------------------------------------------------

|                                                         DescribeDBInstances                                                         |

+-----------------------------------------+-----------------------------------------------------------------------------------+-------+

|  cf-three-tier-labdatabase-igkx7lxvneoh |  cf-three-tier-labdatabase-igkx7lxvneoh.cbacuqy22h3e.eu-west-1.rds.amazonaws.com  |  3306 |

+-----------------------------------------+-----------------------------------------------------------------------------------+-------+



PS C:\\Users\\Ronald\\cloudformation-assignment-2026\\cloud-foundation-assigment-L00205530> aws rds describe-db-instances `

>>   --region eu-west-1 `

>>   --query "DBInstances\[\*].VpcSecurityGroups\[\*].\[VpcSecurityGroupId,Status]" `

>>   --output table

\------------------------------------

|        DescribeDBInstances       |

+-----------------------+----------+

|  sg-0e2950b9a11af1199 |  active  |

+-----------------------+----------+



