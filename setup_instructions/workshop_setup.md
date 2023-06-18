# Serverless on Kubernetes Workshop Setup

This will be a fast-paced workshop, so you will need to complete the following steps 
before the start of the workshop. Details on each of the steps is included below.

## Tool Setup
In this workshop we'll use a variety of tools beyond your chosen IDE. Follow the instructions in the [Tool Setup](tool_setup.md)
docs to install these before the workshop.

## Optional: DigitalOcean Account and API Credentials
 
## Optional: AWS Account and API Credentials
Obviously, you will need an AWS account and credentials for doing this AWS workshop.

> Important: This workshop should cost you very little on AWS spend. 
> Most of what we do will be covered under the _free tier_ for the volume of traffic we'll use.
> However, it will be more than $0.00 because of some minimal storage we'll consume. To minimize 
> any costs, be sure to **destroy** any created resources and **delete** any stored data or artifacts 
> when the workshop is over. The workshop will include instructions for doing this.

### AWS Account Creation

> If you already have an AWS account you can use, skip to Creating API credentials.

Official instructions on Account Setup are part of the 
[AWS CLI setup instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html).

Follow those all the way through the AWS CLI v2 installation.

Here's a synopsis of what's involved

To create an AWS account, go to the AWS [home page](https://aws.amazon.com/).

![aws home page screenshot](aws_home_page.jpg)

Click on the Create an AWS Account button and follow the instructions. 


### API Credentials

> Important: New AWS [security best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
> recommends against using long-term API keys. The reasoning is simple: Long-lasting API keys are a security risk,
> especially if those API keys offer broad access, e.g. administrator. Accordingly, AWS now makes it painful to create AWS API
> keys and only allows two to exist at any time.

> Disclaimer: For this workshop, I'll note how to create a user with API access. If you do the same, it is your responsibility
> to make the API key inactive or delete it after the workshop to manage the risk of using it.

After creating your account, use IAM to create a new user
- You should never use your Root account for routine operational tasks
- Do not give this user Console access
- You can make the user an Administrator, either by attaching the Administrator Policy directly or through a Cognito Group association
- Or, you can create and attache the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "arn:aws:iam::*:role/cdk-*"
            ]
        }
    ]
}
```

I created a user named `stls_workshop`. When I chose to add an Access Key, I got this nag screen and found choosing Other worked 
for my purposes:
![Access key creation nag screen](access_key_nag_screen.jpg)

Once the user is created, go to the user's Security Credentials and create an API Key.
> Note: The Key will be visible but the Secret is only visible until you navigate away. Be sure to record these in a safe place like a Password Manager.
> Also, never share these and keep them inactive or delete them when not being used. Since you can have two, you can regularly, and frequently, rotate them

Rotating keys:
1. The active key is what's in use now
2. Make a second active key
3. Update app environment variables or config (i.e. Vault, Secrets Manager, Config Server, etc.) with the new key
4. After all apps are using the new key, deactivate the old key, but don't delete it quite yet
5. If some app complains, re-activate the old key and update the app's config
6. Tip: Automated health checks should include checking for access using the configured keys
7. Once you've verified the old key is not being used anywhere, delete it
