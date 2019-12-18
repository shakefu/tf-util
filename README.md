# tf-util
Docker image containing tfenv, tflint and jq

## Tags

- [latest]()

## Usage

This container allows you to run Terraform commands in a helpful way.

```bash
# Install terraform, init, validate, and tflint errors only
docker run -i \
    # Give AWS credentials to the container \
    -v "$HOME/.aws:/root/.aws" \
    # Load in Terraform code \
    -v "$PWD:/src" \
    # Provide Terraform backend auth \
    -e "ATLAS_TOKEN=$ATLAS_TOKEN" \
    shakefu/tf-util -c '
    tfenv install 0.12.18
    terraform init
    terraform validate
    tflint --output json | jq -rS .errors[].message'
```

This container provides a `ONBUILD` step if you want to preinstall a terraform
version.


```dockerfile
# This is the same as Dockerfile.terraform in this repo

# Dockerfile for triggering onbuild
FROM shakefu/tf-util

# No content needed
```

```bash
# Building with Terraform preinstalled
# Use your own repo/image:tag as appropriate
docker build -t shakefu/tf-util:0.12.18 --build-arg "TERRAFORM=0.12.18" -f Dockerfile.terraform .
```
