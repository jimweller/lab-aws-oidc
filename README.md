# AWS<->Github OIDC

> This readme is messy. I was slinging notes in. It's trying to capture various mechanism in the JWT for auth besides just the repo name.

Use `assume` and `terraform` to deploy to `AwsProfile/AWSAdministratorAccess
12345678901`. Then, in github, you can run the action **manually** and see the effects in
the log there.

A very basic AWS+Github OIDC integration. The Identity Provider in AWS is
configured to only trust this repo and the role assumed is the default
@iac_deploy_role. The only outputs are the logs in the actions tab from running
the workflow. The action establishes a session, runs `aws sts
get-caller-identy`, and uses the the githubs JWT debugger action to print the
token from the OIDC session. All the outputs will be in the `actions` section of
github.

![Image](github-oidc-roles.drawio.svg)

- AwsProfile/AWSAdministratorAccess 12345678901

- https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/
- https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
- https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- https://medium.com/tinder/identifying-vulnerabilities-in-github-actions-aws-oidc-configurations-8067c400d5b8
- https://securitylabs.datadoghq.com/articles/exploring-github-to-aws-keyless-authentication-flaws/
- https://www.youtube.com/watch?v=Io5UFJlEJKc

How to control at the org level?

- We can customize the JWT subject with stuff that repo owners can't get to. OIDC template.
- https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#set-the-customization-template-for-an-oidc-subject-claim-for-an-organization
- We'll need to figure out how to partition github repos to align w/ AWS accounts (and their CICD source accounts)
- https://docs.github.com/en/rest/actions/oidc?apiVersion=2022-11-28#set-the-customization-template-for-an-oidc-subject-claim-for-an-organization
- Can I match to a composite action? I see shared workflows job_workflow_ref
- https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows
- How can I print the JWT in an action to see the subject?
  - https://github.com/github/actions-oidc-debugger
- Make the identity provider and trust relationships in terraform so we can maintain them at scale. They should also have some stubs in AFTc
- THIS IS THE MAGIC. USE CODEOWNERS TO RESTRICT ACCESS TO THE WORKFLOW.
  - Additional CODEOWNERS setup section on this page:
  - https://devopstar.com/2023/01/08/automate-aws-oidc-role-changes-with-github-configurable-oidc-claims/

See all the Enablement Team's demos using the github topics `team-cloud-enablement` and `demo`
https://github.com/orgs/ExampleCoSoftware/repositories?q=topic%3Ateam-cloud-enablement+topic%3Ademo
