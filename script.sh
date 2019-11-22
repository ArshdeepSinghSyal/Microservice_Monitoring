#! /bin/bash -ex

set -e
##############################################################
# 1. Configure your CLI environment with access key and secret
#    key from your zaloni account
# 2. Make sure JQ is installed and on your path
# 3. Change the AWS_USERNAME value to your username
# 4. Provide MFA token in parameter 1 of this script
# 5. Change the TARGET_ACCOUNT_ID value to the required role (the one being used currently is zaloni-engineering)
##############################################################

##GLOBAL VARIABLES:

#The Profile that you use to log in.
PROFILE=zaloni
TARGET_ACCOUNT_ID="181541241057"
#AWS_USERNAME=$(aws iam get-user --output json --query 'User.UserName' --profile $PROFILE)
AWS_USERNAME=asyal


####################

#Check that aws cli is installed
aws --version
#Check that jq is installed
jq --version

#Cleanup AWS Env. Variables
unset -v AWS_ACCESS_KEY_ID
unset -v AWS_SECRET_ACCESS_KEY
unset -v AWS_SESSION_TOKEN

# #Script will first authenticate with MFA
# #Script will then assume engineering role and take resulting key/credentials provided and
# #set in AWS environment variables so all future aws commands execute under assumed role

# echo "Generating MFA Credentials with Token $1"
# MFA_AWS_CREDENTIALS=`aws sts get-session-token --serial-number arn:aws:iam::891270843381:mfa/$AWS_USERNAME --token-code $1 --output json`

# export AWS_ACCESS_KEY_ID=`echo "$MFA_AWS_CREDENTIALS" | jq -r '.Credentials.AccessKeyId'`
# export AWS_SECRET_ACCESS_KEY=`echo "$MFA_AWS_CREDENTIALS" | jq -r '.Credentials.SecretAccessKey'`
# export AWS_SESSION_TOKEN=`echo "$MFA_AWS_CREDENTIALS" | jq -r '.Credentials.SessionToken'`

# echo "MFA Authentication generated:"
# echo "Access Key: $AWS_ACCESS_KEY_ID"
# echo "Secret Key: $AWS_SECRET_ACCESS_KEY"

# echo "Session Token: $AWS_SESSION_TOKEN"


echo "Attempting cross-account-developer Assume Role"
AWS_STS_ASSUMEROLE=$( aws sts assume-role --role-arn "arn:aws:iam::${TARGET_ACCOUNT_ID}:role/cross-account-developer" --role-session-name "${AWS_USERNAME}-cross-account-developer" --output json --profile ${PROFILE} )


#echo "$AWS_STS_ASSUMEROLE"

export AWS_ACCESS_KEY_ID=`echo "$AWS_STS_ASSUMEROLE" | jq -r '.Credentials.AccessKeyId'`
export AWS_SECRET_ACCESS_KEY=`echo "$AWS_STS_ASSUMEROLE" | jq -r '.Credentials.SecretAccessKey'`
export AWS_SESSION_TOKEN=`echo "$AWS_STS_ASSUMEROLE" | jq -r '.Credentials.SessionToken'`

echo "Assume Role generated:"
echo "Access Key: $AWS_ACCESS_KEY_ID"
echo "Secret Key: $AWS_SECRET_ACCESS_KEY"
echo "Session Token: $AWS_SESSION_TOKEN"
set +e