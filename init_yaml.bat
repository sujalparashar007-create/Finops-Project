@echo off
cd /d C:\Users\user\Document\Repositories\Finops-Project\projects\examples\yaml-driven
set TF_PLUGIN_CACHE_DIR=C:\Users\user\Document\Repositories\Finops-Project\test-IAM\.terraform\providers
terraform init -backend=false -no-color 2>&1
echo INIT_EXIT:%ERRORLEVEL%
