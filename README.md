# cloud-foundation-assignment-L00205530

Cloud Foundation Assignment from L00205530

# CloudFormation Assignment 2026



\## Student information



\- \*\*Name:\*\* Ronald Torres

\- \*\*L-number:\*\* L00205530

\- \*\*AWS Region:\*\* `eu-west-1` (Europe – Ireland)

\- \*\*Repository:\*\* \[cloud-foundation-assignment-L00205530](https://github.com/L00205530/cloud-foundation-assignment-L00205530)



\---



\## 1. Overview



This project implements two AWS infrastructure architectures using AWS CloudFormation and YAML templates:

## Architecture Documentation

For detailed architecture diagrams, network design, security decisions
and deployment details, see:

- [Architecture Design](docs/architecture.md)


1\. A static website stored in Amazon S3 and delivered publicly through Amazon CloudFront.

2\. A three-tier network and application architecture consisting of a public web entry point, a private application tier and a private database tier.



The infrastructure is defined as code so that resources can be provisioned consistently and managed through version control. The project also considers security, network separation, deployment validation, testing, scalability, availability and cost.



The two architectures are defined in separate CloudFormation templates:



\- `infra/static-website.yaml`

\- `infra/three-tier.yaml`



Website content is held in:



\- `website/index.html`

\- `website/styles.css`



\## 2. Repository structure



```text

cloud-foundation-assignment-L00205530/

├── infra/

│   ├── static-website.yaml

│   └── three-tier.yaml

├── website/

│   ├── index.html

│   └── styles.css

└── README.md

```



The repository also contains the project history, including the feature branches and pull requests used during development. Refer to the GitHub repository for the complete commit and pull-request history.



\---



\# 3. Architecture A – Static website



\## 3.1 Objective



The first architecture deploys a static website using Amazon S3 as the storage service and Amazon CloudFront as the public-facing content delivery service.



The website displays the student identification:



\*\*L00205530 – Ronald Torres\*\*



The HTML and CSS files are stored in S3. Visitors access the website through the CloudFront distribution rather than accessing the S3 bucket directly.



\## 3.2 Architecture and resources



The implementation in `infra/static-website.yaml` creates the following resources:



| Resource | Purpose |

|---|---|

| `AWS::S3::Bucket` | Stores the static website files |

| `AWS::CloudFront::OriginAccessControl` | Provides authenticated access from CloudFront to the S3 origin |

| `AWS::CloudFront::Distribution` | Provides the public HTTPS website endpoint |

| `AWS::S3::BucketPolicy` | Allows the authorised CloudFront distribution to read website objects |



The website files are uploaded separately to the provisioned bucket. CloudFormation creates the infrastructure; it does not automatically upload the local HTML and CSS files.



\## 3.3 S3 security design



The S3 bucket is deliberately private. S3 Block Public Access is enabled, and the bucket uses server-side encryption with AES256.



The bucket policy grants `s3:GetObject` to the CloudFront service principal, with a condition restricting the permission to the ARN of the specific CloudFront distribution.



This design means:



\- The website can be accessed publicly through CloudFront.

\- Anonymous users cannot directly retrieve objects from the S3 bucket.

\- CloudFront uses Origin Access Control (OAC) and SigV4 signing to access the S3 origin.

\- The S3 bucket does not need a public-read policy.



Keeping the origin private reduces unnecessary exposure and ensures that public content delivery takes place through the intended CloudFront distribution.



\## 3.4 CloudFront configuration



The CloudFront distribution is configured with:



\- S3 regional bucket domain as its origin.

\- Origin Access Control using SigV4.

\- `index.html` as the default root object.

\- HTTP-to-HTTPS redirection for viewer requests.

\- GET and HEAD as the allowed methods.

\- Compression enabled.

\- Query-string forwarding disabled.

\- Cookie forwarding disabled.

\- `PriceClass\_100` to use the selected CloudFront price class.



The distribution uses the default CloudFront certificate. A custom domain and custom TLS certificate are not part of the current implementation.



\## 3.5 Deployment procedure



Run the commands from the repository root in PowerShell.



Validate the template:



```powershell

cfn-lint infra/static-website.yaml



aws cloudformation validate-template `

&#x20; --template-body file://infra/static-website.yaml `

&#x20; --region eu-west-1

```



Deploy the stack:



```powershell

aws cloudformation deploy `

&#x20; --template-file infra/static-website.yaml `

&#x20; --stack-name cf-static-website `

&#x20; --region eu-west-1

```



Retrieve the stack outputs:



```powershell

aws cloudformation describe-stacks `

&#x20; --stack-name cf-static-website `

&#x20; --region eu-west-1 `

&#x20; --query "Stacks\[0].Outputs" `

&#x20; --output table

```



Upload the website files. The bucket name below is the bucket returned by the deployed stack:



```powershell

aws s3 sync website/ `

&#x20; s3://cf-static-website-websitebucket-5rnmdhnm4qya/ `

&#x20; --region eu-west-1

```



The CloudFront distribution can take time to deploy. Once it is deployed, the website can be opened using the CloudFront URL.



\## 3.6 Deployment result



The following result was obtained from the AWS CLI:



```text

Stack: cf-static-website

Status: CREATE\_COMPLETE

Region: eu-west-1

```



CloudFormation outputs:



| Output | Deployed value |

|---|---|

| S3 bucket | `cf-static-website-websitebucket-5rnmdhnm4qya` |

| CloudFront distribution ID | `E3EJHCVO1TKZP8` |

| Website URL | https://dz3999bhs13vt.cloudfront.net |



\*\*Deployed website:\*\* \[https://dz3999bhs13vt.cloudfront.net](https://dz3999bhs13vt.cloudfront.net)



\## 3.7 Testing



The successful `CREATE\_COMPLETE` status confirms that CloudFormation created the stack successfully.



The following checks should be recorded with their actual results and supporting screenshots:



| Test | Expected result | Result/evidence |

|---|---|---|

| CloudFormation validation | Template accepted by AWS | Record CLI result |

| `cfn-lint` | No unresolved lint errors | Record CLI result |

| Stack deployment | `CREATE\_COMPLETE` | Confirmed |

| Website through CloudFront | Website content is returned | Record browser/HTTP result |

| HTTPS | HTTP viewer requests redirect to HTTPS | Record test result |

| Direct anonymous S3 object request | Access denied | Record CLI result |

| Website content and styling | Correct student details and CSS | Record browser screenshot |



Do not mark a test as passed unless the corresponding check was performed.



\---



\# 4. Architecture B – Three-tier architecture



\## 4.1 Objective



The second architecture provisions a three-tier AWS environment using a custom Amazon VPC.



The design separates the public entry point, application compute and database resources into different network tiers. Security groups control communication between these components.



The implementation is defined in `infra/three-tier.yaml`.



\## 4.2 VPC and subnet design



The template creates a VPC with CIDR range `10.20.0.0/16`.



It contains five subnets:



| Subnet | CIDR | Availability Zone | Purpose |

|---|---|---|---|

| Public subnet A | `10.20.1.0/24` | First available AZ | Public load balancer |

| Public subnet B | `10.20.2.0/24` | Second available AZ | Public load balancer |

| Application subnet | `10.20.10.0/24` | First available AZ | Private EC2 application instance |

| Database subnet A | `10.20.20.0/24` | First available AZ | RDS subnet group |

| Database subnet B | `10.20.21.0/24` | Second available AZ | RDS subnet group |



The public subnets are associated with a route table containing a default route to the Internet Gateway.



The application subnet uses a separate route table. Its default route points to a NAT Gateway located in public subnet A. This allows outbound internet connectivity from the private application subnet without assigning the application instance a public IP address.



The database subnets use a separate route table without a default internet route. They are not directly exposed to the internet.



\## 4.3 Web tier – Application Load Balancer



An internet-facing Application Load Balancer is deployed across the two public subnets.



It listens for HTTP requests on TCP port 80 and forwards requests to the application target group.



The target group uses:



\- Protocol: HTTP

\- Port: 80

\- Target type: instance

\- Health-check path: `/health.html`

\- Expected successful health-check response: HTTP 200



The load balancer is the public entry point for the three-tier application.



\*\*Current limitation:\*\* The listener uses HTTP rather than HTTPS. A production implementation should configure a suitable TLS certificate and an HTTPS listener.



\## 4.4 Application tier – EC2



The application tier consists of one EC2 instance deployed in the private application subnet.



The template uses:



\- Amazon Linux 2023 AMI, resolved through the public SSM AMI parameter.

\- Default instance type: `t3.micro`.

\- No public IP address.

\- IMDSv2 token requirement.

\- User data to install and start Apache HTTP Server.



The user-data script creates:



\- `/var/www/html/index.html`

\- `/var/www/html/health.html`



The HTML page identifies the three-tier CloudFormation lab. The health-check file returns the content `OK`, allowing the load balancer to check the application target.



The application security group only permits inbound HTTP traffic from the load balancer security group.



\*\*Current application scope:\*\* The deployed EC2 application serves a static demonstration page and health-check file. The template provisions RDS, but the current application does not perform database queries. Therefore, successful load-balancer health checks demonstrate web-tier-to-application-tier connectivity, not application-to-database integration.



\## 4.5 Database tier – Amazon RDS



The database tier uses Amazon RDS for MySQL.



The template configures:



\- MySQL database engine.

\- Default instance class: `db.t3.micro`.

\- Allocated storage: 20 GB.

\- Storage type: gp3.

\- Storage encryption enabled.

\- Database name: `labdb`.

\- Database username: `labadmin`.

\- Private DB subnet group containing the two database subnets.

\- Public accessibility disabled.

\- Single-AZ deployment.

\- Backup retention period of zero days.



The database password is generated and stored in AWS Secrets Manager. The CloudFormation database resource references the generated secret value rather than defining a plaintext password in the template.



The current template does not configure an EC2 application IAM role to retrieve the secret or implement a database client in the application.



\## 4.6 Security group design



Three security groups separate the allowed traffic paths.



| Security group | Inbound rule | Source |

|---|---|---|

| Load balancer | TCP 80 | `0.0.0.0/0` |

| Application | TCP 80 | Load balancer security group |

| Database | TCP 3306 | Application security group |



This implements the intended communication path:



```text

Internet

&#x20;  |

&#x20;  | HTTP :80

&#x20;  v

Application Load Balancer

&#x20;  |

&#x20;  | HTTP :80

&#x20;  v

EC2 Application Server

&#x20;  |

&#x20;  | MySQL :3306 (permitted network path)

&#x20;  v

Amazon RDS MySQL

```



The database security group does not allow inbound MySQL connections from arbitrary internet addresses. It only allows the specified application security group as its source.



The EC2 application server is deployed without a public IP address, and the RDS instance is configured with `PubliclyAccessible: false`.



\## 4.7 Deployment procedure



Validate the template:



```powershell

cfn-lint infra/three-tier.yaml



aws cloudformation validate-template `

&#x20; --template-body file://infra/three-tier.yaml `

&#x20; --region eu-west-1

```



Deploy the stack:



```powershell

aws cloudformation deploy `

&#x20; --template-file infra/three-tier.yaml `

&#x20; --stack-name cf-three-tier `

&#x20; --parameter-overrides EnvironmentName=cloudlab `

&#x20; --region eu-west-1

```



Inspect the stack:



```powershell

aws cloudformation describe-stacks `

&#x20; --stack-name cf-three-tier `

&#x20; --region eu-west-1 `

&#x20; --query "Stacks\[0].{Status:StackStatus,Outputs:Outputs}" `

&#x20; --output json

```



Retrieve the application endpoint:



```powershell

aws cloudformation describe-stacks `

&#x20; --stack-name cf-three-tier `

&#x20; --region eu-west-1 `

&#x20; --query "Stacks\[0].Outputs\[?OutputKey=='WebsiteEndpoint'].OutputValue" `

&#x20; --output text

```



Test the load balancer endpoint in a browser or using:



```powershell

Invoke-WebRequest -Uri cf-thr-Publi-Dof0BAxorSGD-303545619.eu-west-1.elb.amazonaws.com

```



\## 4.8 Deployment results



The following results were obtained from the AWS CLI:



```text

Stack: cf-three-tier

Status: CREATE\_COMPLETE

Region: eu-west-1

```



CloudFormation outputs:



| Resource | Deployed value |

|---|---|

| VPC ID | `vpc-0b7da2b507708b1cd` |

| Application instance | `i-00405572d6dd0eaab` |

| Load balancer endpoint | `http://cf-thr-Publi-Dof0BAxorSGD-303545619.eu-west-1.elb.amazonaws.com` |

| Database endpoint | `cf-three-tier-labdatabase-igkx7lxvneoh.cbacuqy22h3e.eu-west-1.rds.amazonaws.com` |

| Secrets Manager ARN | `arn:aws:secretsmanager:eu-west-1:816435462788:secret:DatabaseSecret-dRjpwjpnhgGT-sQvwUD` |



The database endpoint is a private database endpoint and is not intended to be accessed directly from the public internet.



\## 4.9 Testing results



The following checks have been confirmed from the AWS CLI output:



| Test | Result |

|---|---|

| CloudFormation stack creation | \*\*Passed\*\* – `CREATE\_COMPLETE` |

| Application target registration | \*\*Confirmed\*\* – EC2 instance registered |

| Target group health | \*\*Passed\*\* – `healthy` |

| Target health reason | `None` |



The target health command returned:



```text

Instance: i-00405572d6dd0eaab

State: healthy

Reason: None

```



This confirms that the target group health check considers the application instance healthy.



Additional checks to record with their actual outputs:



| Test | Expected result | Result/evidence |

|---|---|---|

| `cfn-lint` | No unresolved lint errors | Record CLI result |

| ALB HTTP request | Successful response | Record HTTP result |

| EC2 public IP | No public IP | Record CLI result |

| RDS public accessibility | `false` | Record CLI result |

| Database connectivity | Application can connect to RDS | Not implemented/tested in current application |



\---



\# 5. Security, scalability and performance considerations



\## 5.1 Security



Security decisions implemented in this project include:



\- S3 Block Public Access for the static website bucket.

\- CloudFront Origin Access Control for private S3 origin access.

\- AES256 S3 server-side encryption.

\- HTTPS redirection for CloudFront viewers.

\- Public and private subnet separation in the three-tier architecture.

\- Application security group restricted to the load balancer security group.

\- Database security group restricted to the application security group.

\- RDS public accessibility disabled.

\- Encrypted RDS storage.

\- Generated database password stored in AWS Secrets Manager.

\- EC2 IMDSv2 required.



\## 5.2 Scalability



CloudFront improves the distribution of static website content through its edge network and caching.



The three-tier design separates the public entry point, application compute and database, allowing these components to be scaled independently in a future implementation.



The current three-tier deployment uses a single EC2 instance and does not include an Auto Scaling group.



\## 5.3 Availability and resilience



The load balancer spans two public subnets in different Availability Zones. The RDS subnet group also includes two database subnets.



However, the application server is deployed in only one Availability Zone, and there is only one NAT Gateway.



These choices limit the overall availability of the architecture.



\## 5.4 Cost considerations



The implementation uses small default EC2 and RDS instance classes to keep the lab configuration relatively modest.



However, the three-tier architecture includes resources that can generate charges even when they are not actively being used, including:



\- NAT Gateway.

\- Application Load Balancer.

\- EC2 instance.

\- RDS instance and allocated storage.

\- Elastic IP associated with the NAT Gateway.

\- Secrets Manager secret.

\- Data transfer.



The static website may also incur S3 storage, request and CloudFront data-transfer charges.



The architecture should be deleted after testing if it is no longer required.



\---



\# 6. Limitations and future improvements



The current implementation provides a working infrastructure demonstration, but it is not intended to represent a fully production-ready application.



\## 6.1 Single NAT Gateway



The application subnet uses one NAT Gateway.



Limitations:



\- It creates a single point of failure for outbound connectivity.

\- An Availability Zone failure could interrupt outbound connectivity for the application subnet.

\- It does not provide Availability Zone-level NAT redundancy.



A future production design could deploy a NAT Gateway in each Availability Zone and route each private subnet through its local NAT Gateway.



\## 6.2 Single application instance



The application tier contains only one EC2 instance.



Limitations:



\- There is no application-level redundancy.

\- Failure of the instance makes the application unavailable.

\- There is no automatic scaling based on demand.



A future implementation could use an Auto Scaling group with multiple instances distributed across Availability Zones.



\## 6.3 Database integration



RDS is provisioned and its security group allows the intended MySQL network path from the application security group.



However, the current Apache demonstration page does not execute database queries.



Future work could include a backend application that retrieves credentials securely from Secrets Manager, connects to MySQL and performs a simple read/write operation.



\## 6.4 HTTPS for the three-tier web endpoint



The current ALB listener uses HTTP on port 80.



Future work could configure HTTPS on port 443 using an ACM certificate and redirect HTTP traffic to HTTPS.



\## 6.5 Automated deployment pipeline



Future work could introduce GitHub Actions to validate CloudFormation templates automatically when pull requests are opened or updated.



A secure deployment pipeline could use GitHub OIDC and an appropriately restricted AWS role rather than long-lived AWS access keys.



\---



\# 7. GitHub workflow and version control



The project was developed using Git feature branches and pull requests.



The development workflow separates work into logical changes before merging them into the main branch.



The workflow includes:



1\. Creating a feature branch.

2\. Implementing a specific part of the infrastructure.

3\. Validating and testing changes.

4\. Committing the work using descriptive commit messages.

5\. Pushing the feature branch to GitHub.

6\. Opening a pull request targeting `main`.

7\. Reviewing the changes before merging.



Examples of descriptive commit messages:



```text

feat: deploy private S3 website through CloudFront

feat: add three-tier AWS architecture

docs: complete assignment lab report

```



The repository's GitHub history provides the actual branches, commits and pull requests.



\*\*Lecturer access:\*\* The assignment requires `Ruth.Lennon@atu.ie` to be added as a repository collaborator. 



\---



\# 8. Research and AI usage



The assignment permits the use of tutorials and LLMs for learning the basics, but requires their use to be declared and the resulting solution to be improved beyond the basic examples.



\## 8.1 Official AWS documentation



The following official documentation is relevant to the implementation:



\- \[AWS CloudFormation documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)

\- \[CloudFormation best practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)

\- \[CloudFront: Restrict access to an S3 origin](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)

\- \[Amazon VPC documentation](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)

\- \[Amazon EC2 documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)

\- \[Amazon RDS for MySQL documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP\_MySQL.html)

\- \[AWS Secrets Manager documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)



\## 8.2 LLM assistance



ChatGPT was used as a learning and assistance tool during the assignment.



Examples of prompts used during the development discussion included:



&#x20;- "What are the best practices to do S3 Static Website with CloudFormation."

&#x20;- "Explain the best practices to implement a three-tier architecture using AWS CloudFormation."

&#x20;- "Explain this AWS CloudFormation error and help me troubleshoot it."

&#x20;- "Help me validate my CloudFormation YAML templates using AWS CLI."

&#x20;- "Explain the VPC, subnet design, load balancer and database security group configuration."



\- Summary of the advice received: ChatGPT provided explanations of AWS CloudFormation concepts, assistance with YAML template structure, VPC and subnet configuration, security groups, load balancers and database connectivity. It also helped troubleshoot AWS CLI errors, template validation issues, Git operations and deployment configuration.



\- What I verified independently: I verified the CloudFormation templates using the AWS CLI validate-template command, checked AWS resource configurations against official AWS documentation, and reviewed deployment outputs and resource configurations in the AWS Management Console. I also checked that the GitHub repository contained the expected project files.



\- What I implemented or changed myself: I created and maintained the CloudFormation YAML files, configured the AWS resources, selected the network architecture, adjusted security group rules, organised the project repository and performed deployment and validation activities. I also investigated and corrected errors encountered during implementation rather than relying exclusively on generated suggestions.

\## 8.3 Improvements beyond basic examples



The implementation includes several security and design decisions beyond a basic public static website or flat application deployment:



\- Private S3 storage with CloudFront Origin Access Control.

\- Explicit S3 Block Public Access.

\- S3 server-side encryption.

\- Separation of public, application and database subnets.

\- Security-group-based communication between tiers.

\- Private RDS deployment.

\- Database credential generation and storage through Secrets Manager.

\- IMDSv2 enforcement for EC2.



These decisions improve the security and maintainability of the infrastructure compared with exposing storage or database resources directly.



\---



\# 9. Cleanup instructions



CloudFormation manages the infrastructure lifecycle. Delete the stacks when the lab is finished to avoid unnecessary AWS charges.



\## 9.1 Delete the three-tier stack



```powershell

aws cloudformation delete-stack `

&#x20; --stack-name cf-three-tier `

&#x20; --region eu-west-1



aws cloudformation wait stack-delete-complete `

&#x20; --stack-name cf-three-tier `

&#x20; --region eu-west-1

```



\## 9.2 Empty the static website bucket



The S3 bucket must be emptied before its CloudFormation stack can be deleted.



```powershell

aws s3 rm `

&#x20; s3://cf-static-website-websitebucket-5rnmdhnm4qya/ `

&#x20; --recursive `

&#x20; --region eu-west-1

```



\## 9.3 Delete the static website stack



```powershell

aws cloudformation delete-stack `

&#x20; --stack-name cf-static-website `

&#x20; --region eu-west-1



aws cloudformation wait stack-delete-complete `

&#x20; --stack-name cf-static-website `

&#x20; --region eu-west-1

```



Verify deletion in the CloudFormation console or with the AWS CLI.



\---



\# 10. Conclusion



This assignment has given me hands-on experience with creating and deploying AWS-based infrastructure via IaC (Infrastructure as Code).



The Static Website Architecture is an example of how you can combine Amazon S3 and Cloud Front to provide public access to your websites' static files and keep the underlying store private.



The Three-Tiered Architecture is an example of Network Segmentation, Public/Private Subnets, Load Balancing, Application Hosting, Isolation of the Database and Security Group Control over Communication.



Additionally, this project shows that security, availability, scalability and cost should all be considered when designing cloud infrastructure.



That being said, there are still several things that could be improved upon currently; these include integrating applications/databases into the same environment, developing Multi-AZ resiliency for the applications, utilizing HTTPS for the load balancers, and validating automated deployments.



In general, this assignment showed how Cloud Formation, Git and a structured Pull Request Workflow can be utilized to create, review and maintain cloud based environments consistently.

