
# This terraform module is intended to be run locally just for the purpose of this demo

# assume AwsProfile/AWSAdministratorAccess

# It defines the identity provider that trusts github
# It defines an IAM role that can't do much in this demo



terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.5"

}


module "iam_github_oidc_provider" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"

  tags = {
    DoNotNuke = "True"
    Permanent = "True"
  }
}


module "iam_github_oidc_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  name = "@github_role"
  # This should be updated to suit your organization, repository, references/branches, etc.
  subjects = ["ExampleCoSoftware/jira-demo-aws-oidc:*"]

  policies = {
    S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    OidcSafter = aws_iam_policy.deny_role_jumping.arn
  }

  tags = {
    DoNotNuke = "True"
    Permanent = "True"
  }
}

resource "aws_iam_policy" "deny_role_jumping" {
  name        = "OidcSafety"
  path        = "/"
  description = "Deny role jumping/chaining"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "OidcSafety",
            "Effect": "Deny",
            "Action": "sts:AssumeRole",
            "Resource": "*"
        }
    ]
})
}

# resource "aws_iam_policy_attachment" "oidcRole-to-oidcPolicy" {
#   name       = "oidcRole-to-oidcSafety"
#   roles      = [iam_github_oidc_role.aws_iam_role.arn]
#   policy_arn = aws_iam_policy.deny_role_jumping.arn
# }

#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
#       + role       = "@github_role"
#     }


# ❯ aws iam get-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::12345678901:oidc-provider/token.actions.githubusercontent.com
#
# {
#     "Url": "token.actions.githubusercontent.com",
#     "ClientIDList": [
#         "sts.amazonaws.com"
#     ],
#     "ThumbprintList": [
#         "1b511abead59c6ce207077c0bf0e0043b1382612",
#         "959cb2b52b4ad201a593847abca32ff48f838c2e",
#         "6938fd4d98bab03faadb97b34396831e3780aea1",
#         "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
#     ],
#     "CreateDate": "2024-03-21T23:09:20.245000+00:00",
#     "Tags": [
#         {
#             "Key": "Permanent",
#             "Value": "True"
#         },
#         {
#             "Key": "DoNotNuke",
#             "Value": "True"
#         }
#     ]
# }




# ❯ aws iam get-role --role-name "@github_role"
# {
#     "Role": {
#         "Path": "/",
#         "RoleName": "@github_role",
#         "RoleId": "AROAXK4E2HE5ISF25LAFS",
#         "Arn": "arn:aws:iam::12345678901:role/@github_role",
#         "CreateDate": "2024-03-21T23:45:31+00:00",
#         "AssumeRolePolicyDocument": {
#             "Version": "2012-10-17",
#             "Statement": [
#                 {
#                     "Sid": "GithubOidcAuth",
#                     "Effect": "Allow",
#                     "Principal": {
#                         "Federated": "arn:aws:iam::12345678901:oidc-provider/token.actions.githubusercontent.com"
#                     },
#                     "Action": [
#                         "sts:TagSession",
#                         "sts:AssumeRoleWithWebIdentity"
#                     ],
#                     "Condition": {
#                         "StringLike": {
#                             "token.actions.githubusercontent.com:sub": "repo:ExampleCoSoftware/terraform-aws-iam:*"
#                         },
#                         "ForAllValues:StringEquals": {
#                             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
#                             "token.actions.githubusercontent.com:iss": "http://token.actions.githubusercontent.com"
#                         }
#                     }
#                 }
#             ]
#         },
#         "MaxSessionDuration": 3600,
#         "Tags": [
#             {
#                 "Key": "DoNotNuke",
#                 "Value": "True"
#             },
#             {
#                 "Key": "Permanent",
#                 "Value": "True"
#             }
#         ],
#         "RoleLastUsed": {}
#     }
# }