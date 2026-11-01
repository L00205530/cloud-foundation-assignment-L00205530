AWS documentation

1\. AWS CloudFormation User Guide

\- Source: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html

\- Date accessed: 1 November 2026

\- Topic researched: CloudFormation templates, stacks, resources, parameters, outputs and infrastructure as code.

\- How it influenced my implementation: I used CloudFormation YAML templates to define and deploy AWS resources consistently. Parameters were used to make the templates reusable and outputs to expose important deployment information.


2\. Amazon VPC User Guide

\- Source: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

\- Date accessed: 1 November 2026

\- Topic researched: VPC architecture, public and private subnets, route tables, internet gateways and network isolation.

\- How it influenced my implementation: I designed the three-tier architecture using a dedicated VPC with separate public and private subnets. This allowed me to isolate application and database resources from direct internet access.


3. Amazon EC2 User Guide

\- Source: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html

\- Date accessed: 1 November 2026

\- Topic researched: EC2 instances, instance configuration and networking.

\- How it influenced my implementation: I used EC2 instances as the compute layer of the three-tier architecture, allowing the application to run within the private network environment.


4. Elastic Load Balancing Documentation

\- Source: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html

\- Date accessed: 1 November 2026

\- Topic researched: Application Load Balancers, listeners, target groups and health checks.

\- How it influenced my implementation: I used an Application Load Balancer to provide an entry point for incoming application traffic and distribute requests to the application instances.


5. Amazon RDS Documentation

\- Source: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html

\- Date accessed: 1 November 2026

\- Topic researched: Relational database deployment, database subnet groups and security.

\- How it influenced my implementation: I used Amazon RDS as the database tier and configured network restrictions to prevent direct public access to the database.


6. AWS Security Groups Documentation

\- Source: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html

\- Date accessed: 1 November 2026

\- Topic researched: Stateful network firewalls, inbound and outbound rules, and security group referencing.

\- How it influenced my implementation: I applied the principle of least privilege by restricting communication between architectural tiers. The database security group only permits connections from the appropriate application security group.


7. AWS CloudFormation CLI Documentation

\- Source: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/

\- Date accessed: 1 November 2026

\- Topic researched: CloudFormation template validation, stack creation, updates and deployment commands.

\- How it influenced my implementation: I used AWS CLI commands to validate my YAML templates and manage CloudFormation stacks. This helped identify configuration and template errors before deployment.


Tutorials followed

1\. AWS CloudFormation Getting Started

\- Tutorial title and URL: Getting started with AWS CloudFormation

\- Date accessed: 1 November 2026

\- What I followed: The general process of creating CloudFormation templates, defining AWS resources and deploying infrastructure through CloudFormation stacks.

\- What I changed or improved: I adapted the examples to create my own templates for the static website and three-tier architecture, using parameters and outputs where appropriate.


2. Building a VPC with CloudFormation

\- Tutorial title and URL: AWS CloudFormation VPC resources

\- Date accessed: 1 November 2026

\- What I followed: The resource definitions and configuration required to create VPC networking components through YAML templates.

\- What I changed or improved: I adapted the networking configuration to support the three-tier architecture, separating public-facing resources from private application and database resources.


3. Application Load Balancer Configuration

\- Tutorial title and URL: Application Load Balancer – Getting Started

\- Date accessed: 1 November 2026

\- What I followed: The configuration of an Application Load Balancer, listeners and target groups.

\- What I changed or improved: I incorporated the load balancer into my CloudFormation architecture and configured traffic forwarding towards the application tier rather than exposing the application instances directly.


4. CloudFormation Template Validation

\- Tutorial title and URL: ValidateTemplate – AWS CLI

\- Date accessed: 1 November 2026

\- What I followed: The use of the AWS CLI to validate CloudFormation templates before deployment.

\- What I changed or improved: I incorporated template validation into my deployment workflow, using the eu-west-1 region and checking the YAML templates before attempting to create or update stacks.

LLM usage:


\- Tool/model: OpenAI ChatGPT – GPT-6.

\- Date: 29 October – 1 November 2026.

\- Exact prompt used: Multiple prompts were used throughout the development process, including:

&#x20; - "What are the best practices to do S3 Static Website with CloudFormation."

&#x20; - "Explain the best practices to implement a three-tier architecture using AWS CloudFormation."

&#x20; - "Explain this AWS CloudFormation error and help me troubleshoot it."

&#x20; - "Help me validate my CloudFormation YAML templates using AWS CLI."

&#x20; - "Explain the VPC, subnet design, load balancer and database security group configuration."



\- Summary of the advice received: ChatGPT provided explanations of AWS CloudFormation concepts, assistance with YAML template structure, VPC and subnet configuration, security groups, load balancers and database connectivity. It also helped troubleshoot AWS CLI errors, template validation issues, Git operations and deployment configuration.



\- What I verified independently: I verified the CloudFormation templates using the AWS CLI validate-template command, checked AWS resource configurations against official AWS documentation, and reviewed deployment outputs and resource configurations in the AWS Management Console. I also checked that the GitHub repository contained the expected project files.



\- What I implemented or changed myself: I created and maintained the CloudFormation YAML files, configured the AWS resources, selected the network architecture, adjusted security group rules, organised the project repository and performed deployment and validation activities. I also investigated and corrected errors encountered during implementation rather than relying exclusively on generated suggestions.

Critical Reflection 


Throughout the completion of this project, the utilization of a large language model such as ChatGPT was highly beneficial in providing explanations on many different AWS services, and various aspects of CloudFormation that assisted me in understanding how each resource is utilized within a specific cloud-based environment.



One of the greatest benefits were the tools it provided for assisting with the troubleshooting. When implementing my project, I experienced several issues with AWS permissions, CloudFormation Template Validation errors, incorrect file paths, and Git repository misconfigurations. However, through the use of ChatGPT, I was able to determine potential reasons for these errors, and generate commands to assist in investigating the root cause of the issue. This greatly shortened the amount of time spent in troubleshooting, while also increasing my knowledge of why certain errors occurred.



Not every recommendation produced by ChatGPT was directly implementable into the solution. Many times the recommendations required additional research to confirm their accuracy relative to official AWS Documentation or were not related at all to my case scenario. Specifically, there were multiple cases where I had to review official documentation regarding Resource Properties, Network Connectivity, Security Group Permissions, Deployment Restrictions, etc. As an example, when I received an AWS CLI validation error indicating that the local static website template was empty; I did not view this as a syntax related error with regards to CloudFormation. Instead, I reviewed the contents of the local files, along with reviewing the current directory hierarchy to identify the true source of the issue.



Therefore, at no point during the final implementation phase did I simply copy any generated examples or tutorials into the solution. In addition to adapting the recommended configurations into a format which met the requirements of the assignment, I independently determined which level of network segmentation would occur based upon the security requirements identified in this document, and performed independent testing of the completed infrastructure.



While using an LLM contributed significantly to my learning process, it did not replace my responsibility to ensure that I understood how everything functioned together, nor that I verified all components prior to accepting them as part of my final solution. Through this experience, I have come to realize that AI-Generated Information should always be viewed as Guidance only, never as Authoritative Technical Documentation.

