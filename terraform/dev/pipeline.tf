resource "aws_codepipeline" "codepipeline" {
  name     = "tf-aws-pipeline"
  pipeline_type = "v2" # Type of the pipeline. Possible values are: V1 and V2. Default value is V1.
  depends_on = [ aws_s3_bucket.codepipeline_bucket, aws_vpc.aws-vpc, aws_iam_role.eksClusterRole, iaws_iam_role.codepipeline_role  ] # TODO
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  stage { # TODO with GitHub repo
    name = "Source" 

    action { # Github connection requires manual approval in AWS Console. To avoid manual approval use lambda + webhooks
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection" 
      version          = "1" 
      output_artifacts = ["source_output"]

      configuration = { 
        ConnectionArn    = aws_codestarconnections_connection.github-repo.arn
        FullRepositoryId = "cralonsobcn/pipeline-tf-aws-eks"
        BranchName       = "master"
      }
    }

  }

  stage { # TODO with ECR
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "test"
      }
    }
  }

  stage { # TODO with EKS
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "EKS"
      input_artifacts = ["build_output"]
      version         = "2" # 1 > 2. The EKS deploy action is only available for V2 type pipelines.

      configuration = {
        ActionMode     = "REPLACE_ON_FAILURE"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "CreateStackOutput.json"
        StackName      = "MyStack"
        TemplatePath   = "build_output::sam-templated.yaml"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "github-repo" {
  name          = "pipeline-tf-aws-eks-repo"
  provider_type = "GitHub" # Valid values are Bitbucket, GitHub, GitHubEnterpriseServer, GitLab or GitLabSelfManaged
}

# S3 bucket for codepipeline artifacts 
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "test-bucket"
}

# TODO
resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  depends_on = [ aws_s3_bucket.codepipeline_bucket ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

