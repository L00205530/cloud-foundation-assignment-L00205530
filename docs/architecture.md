\# AWS CloudFormation Assignment – Architecture Design



\*\*Student:\*\* Ronald Torres  

\*\*Student ID:\*\* L00205530  

\*\*AWS Region:\*\* `eu-west-1` (Ireland)



\## 1. Introduction



This document describes the design and implementation of two AWS architectures deployed using AWS CloudFormation:



1\. \*\*Static website architecture:\*\* A secure static website hosted in Amazon S3 and delivered through Amazon CloudFront.

2\. \*\*Three-tier architecture:\*\* A network infrastructure containing a public Application Load Balancer, a private EC2 application server and a private Amazon RDS database.



Both architectures use infrastructure as code to provide repeatable and manageable deployments.



\---



\# 2. Architecture A – Static Website



\## 2.1 Design overview



The static website architecture uses Amazon S3 to store website files and Amazon CloudFront to distribute the content to visitors.



The S3 bucket is private. Visitors do not access the bucket directly. Instead, CloudFront retrieves the website content using Origin Access Control (OAC).



The CloudFront distribution provides HTTPS access to the website and redirects HTTP requests to HTTPS.



\## 2.2 Architecture diagram



```mermaid

flowchart TD

&#x20;   A\[Website Visitor] -->|HTTPS| B\[Amazon CloudFront]

&#x20;   B -->|Signed request using OAC| C\[Private Amazon S3 Bucket]

&#x20;   C --> D\[index.html]

&#x20;   C --> E\[styles.css]

```



\## 2.3 AWS resources



| Resource | Purpose |

|---|---|

| Amazon S3 bucket | Stores the static website files |

| Amazon CloudFront | Distributes website content to visitors |

| CloudFront Origin Access Control | Allows CloudFront to access the private S3 origin |

| S3 bucket policy | Restricts access to the designated CloudFront distribution |



\## 2.4 Security decisions



The architecture implements several security controls:



\- \*\*Private S3 bucket:\*\* Public access is blocked using S3 Block Public Access.

\- \*\*Origin Access Control:\*\* CloudFront accesses S3 using signed requests.

\- \*\*Bucket policy restrictions:\*\* Access is restricted to the CloudFront distribution rather than allowing public S3 access.

\- \*\*HTTPS:\*\* CloudFront redirects HTTP requests to HTTPS.

\- \*\*Encryption at rest:\*\* S3 server-side encryption using AES-256 is enabled.

\- \*\*Restricted CloudFront methods:\*\* Only GET and HEAD requests are permitted.



These controls reduce the exposure of the storage bucket while allowing the website to remain publicly accessible through CloudFront.



\## 2.5 Deployment



The architecture is defined in:



`infra/static-website.yaml`



The deployment and website upload process is automated using:



`scripts/deploy-static-website.ps1`



The deployment process creates the CloudFormation stack, retrieves the S3 bucket and CloudFront distribution outputs, uploads the website files and creates a CloudFront cache invalidation.



\## 2.6 Deployment evidence



The deployed website is available at:



https://dz3999bhs13vt.cloudfront.net



The CloudFormation stack was successfully created with status `CREATE\_COMPLETE`.



Screenshots are stored in:



\- `docs/screenshots/static-website.png`

\- `docs/screenshots/s3-security.png`



\---



\# 3. Architecture B – Three-Tier Architecture



\## 3.1 Design overview



The second architecture implements a three-tier infrastructure within an Amazon Virtual Private Cloud (VPC).



The architecture separates the public entry point, application server and database into different network layers.



The three logical tiers are:



1\. \*\*Web tier:\*\* An internet-facing Application Load Balancer receives HTTP requests.

2\. \*\*Application tier:\*\* An Amazon EC2 instance hosts the Apache web server inside a private subnet.

3\. \*\*Database tier:\*\* An Amazon RDS MySQL database is deployed in private database subnets.



The network design uses public and private subnets to control how resources communicate and which resources can be reached from the internet.



\## 3.2 Network and subnet layout



The VPC uses the CIDR range:



`10.20.0.0/16`



The subnet layout is:



| Subnet | CIDR | Purpose |

|---|---|---|

| Public Subnet 1 | `10.20.1.0/24` | Application Load Balancer |

| Public Subnet 2 | `10.20.2.0/24` | Application Load Balancer |

| Private Application Subnet | `10.20.10.0/24` | EC2 application server |

| Private Database Subnet 1 | `10.20.20.0/24` | Database subnet group |

| Private Database Subnet 2 | `10.20.21.0/24` | Database subnet group |



The VPC includes:



\- Internet Gateway for internet connectivity to public resources.

\- NAT Gateway to allow resources in private subnets to initiate outbound internet connections.

\- Public and private route tables.

\- Security groups controlling communication between infrastructure components.



\## 3.3 Architecture diagram



```mermaid

flowchart TD

&#x20;   Internet((Internet))

&#x20;   Internet --> ALB



&#x20;   subgraph VPC\["VPC: 10.20.0.0/16"]

&#x20;       subgraph Public\["Public Subnets"]

&#x20;           ALB\["Application Load Balancer<br/>HTTP :80"]

&#x20;           NAT\["NAT Gateway"]

&#x20;       end



&#x20;       subgraph App\["Private Application Subnet"]

&#x20;           EC2\["EC2 Instance<br/>Amazon Linux 2023<br/>Apache"]

&#x20;       end



&#x20;       subgraph DB\["Private Database Subnets"]

&#x20;           RDS\["Amazon RDS<br/>MySQL"]

&#x20;       end



&#x20;       ALB -->|HTTP :80| EC2

&#x20;       EC2 -.->|Database access permitted by SG| RDS

&#x20;       EC2 --> NAT

&#x20;   end

```



\*\*Important:\*\* The diagram shows the intended network permission between the application and database tiers. The deployed application currently serves web content and a health-check page; an actual database connection or query has not been verified.



\## 3.4 Web tier



The web tier uses an internet-facing Application Load Balancer.



The load balancer:



\- Receives incoming HTTP traffic on port 80.

\- Distributes requests to the application target group.

\- Performs health checks using `/health.html`.

\- Uses the application security group as the permitted source for backend traffic.



The Application Load Balancer is deployed across two public subnets in different Availability Zones.



\## 3.5 Application tier



The application tier consists of an EC2 instance running Amazon Linux 2023.



The instance:



\- Is deployed in a private application subnet.

\- Does not receive a public IP address.

\- Runs Apache to serve the website content.

\- Provides a `/health.html` endpoint for load balancer health checks.

\- Uses a security group that allows HTTP traffic from the Application Load Balancer security group.



The target group health check was verified successfully, with the deployed EC2 instance reporting a `healthy` state.



\## 3.6 Database tier



The database tier uses Amazon RDS for MySQL.



The database:



\- Is deployed in private database subnets.

\- Is configured as not publicly accessible.

\- Uses encrypted storage.

\- Uses a database security group allowing MySQL traffic on port 3306 only from the application security group.

\- Uses AWS Secrets Manager to generate and store the database password.



The deployed database is part of the infrastructure, but application-level database connectivity has not been demonstrated as part of the current implementation.



\## 3.7 Security decisions



Security is implemented through network segmentation, security groups and managed AWS services.



| Component | Security control |

|---|---|

| VPC | Network isolation using a dedicated VPC |

| Application Load Balancer | Public entry point with restricted listener port |

| EC2 instance | Private subnet and no public IP |

| Application security group | Allows HTTP only from the ALB security group |

| RDS database | Private deployment and no public accessibility |

| Database security group | Allows MySQL only from the application security group |

| RDS storage | Encryption at rest |

| Database credentials | Generated and stored using Secrets Manager |



This design reduces direct exposure of the application and database infrastructure.



\## 3.8 Availability and scalability considerations



The architecture includes an Application Load Balancer deployed across two public subnets, providing a foundation for distributing traffic across multiple application instances.



However, the current implementation uses:



\- One EC2 application instance.

\- One NAT Gateway.

\- A single-AZ RDS deployment.



These choices keep the lab architecture relatively simple and cost-conscious, but they introduce availability limitations.



For a production environment, the architecture could be improved by:



\- Deploying multiple EC2 instances across Availability Zones.

\- Using an Auto Scaling Group.

\- Deploying RDS with Multi-AZ availability.

\- Using multiple NAT Gateways where required for resilience.

\- Configuring HTTPS on the Application Load Balancer with an AWS Certificate Manager certificate.



\---



\# 4. Deployment and Infrastructure as Code



Both architectures are defined using AWS CloudFormation templates.



| Architecture | CloudFormation template | Deployment script |

|---|---|---|

| Static website | `infra/static-website.yaml` | `scripts/deploy-static-website.ps1` |

| Three-tier | `infra/three-tier.yaml` | `scripts/deploy-three-tier.ps1` |



The scripts automate stack deployment and retrieve relevant outputs from CloudFormation.



The cleanup process is provided separately in:



`scripts/cleanup.ps1`



This script is intended to remove the deployed stacks when the lab is finished.



\---



\# 5. Testing and Verification



The following deployment results were observed during implementation.



| Test | Result |

|---|---|

| Static website CloudFormation deployment | `CREATE\_COMPLETE` |

| Three-tier CloudFormation deployment | `CREATE\_COMPLETE` |

| CloudFront website access | Deployed URL available |

| Application target group health check | `healthy` |

| Database application connectivity | Not verified |

| RDS private accessibility configuration | Defined in CloudFormation |



The successful target group health check confirms that the Application Load Balancer can reach the EC2 instance through the configured health-check endpoint.



It does not demonstrate application-to-database connectivity.



\---



\# 6. Conclusion



The assignment demonstrates how AWS CloudFormation can be used to deploy and manage cloud infrastructure through infrastructure as code.



The static website architecture demonstrates secure object storage and content distribution using Amazon S3 and CloudFront.



The three-tier architecture demonstrates network segmentation and separation of the web, application and database layers using VPC, EC2, Elastic Load Balancing and RDS.



Both implementations provide a foundation for further improvements in availability, scalability, monitoring and security.

