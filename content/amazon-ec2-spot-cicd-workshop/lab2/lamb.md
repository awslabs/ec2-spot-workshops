+++
title = "Code snippet: The SpotCICDWorkshop_ManageTestEnvironment Lambda function"
weight = 20
+++
Below is a sanitized version of the SpotCICDWorkshop_ManageTestEnvironment Lambda function that was deployed to your account by the CloudFormation template that you deployed during the Workshop Preparation:
```javascript
'use strict';
var AWS = require('aws-sdk');
var actions = {
  deploy: function (cfn, ddb, request_payload) {
    return new Promise(function (resolve, reject) {
      var cfn_params = {
        StackName: request_payload.stackName,
        Capabilities: [ 'CAPABILITY_IAM' ],
        Parameters: [
          {
            ParameterKey: 'KeyPair',
            ParameterValue: '${SpotCICDWorkshop.KeyPair}'
          }, {
            ParameterKey: 'CurrentIP',
            ParameterValue: '${SpotCICDWorkshop.Current.Ip}'
          }, {
            ParameterKey: 'AMILookupLambdaFunctionARN',
            ParameterValue: '${SpotCICDWorkshop.AMILookupLambdaFunction.Arn}'
          }, {
            ParameterKey: 'DeploymentArtifactsS3Bucket',
            ParameterValue: '${SpotCICDWorkshop.DeploymentArtifactsS3Bucket}'
          }, {
            ParameterKey: 'VPC',
            ParameterValue: '${SpotCICDWorkshop.VPC}'
          }, {
            ParameterKey: 'SubnetA',
            ParameterValue: '${SpotCICDWorkshop.SubnetPublicA}'
          }, {
            ParameterKey: 'SubnetB',
            ParameterValue: '${SpotCICDWorkshop.SubnetPublicB}'
          }, {
            ParameterKey: 'SubnetC',
            ParameterValue: '${SpotCICDWorkshop.SubnetPublicC}'
          }
        ],
        RoleARN: '${SpotCICDWorkshop.IAMRoleTestEnvironmentCloudFormation.Arn}',
        TemplateURL: '{{< siteurl >}}config/amazon-ec2-spot-cicd-workshop/amazon-ec2-spot-cicd-workshop_game-of-life.yaml'
      };
      cfn.createStack(cfn_params, function(err, cfn_data) {
        if (err) { return reject(err); }
        console.log('[INFO]', 'StackId: ', cfn_data.StackId);
        return new Promise(function (resolve, reject) {
          var ddb_params = {
            Item: {
              'JobBaseName': { S: request_payload.jobBaseName },
              'BuildID': { N: request_payload.buildId },
              'CloudFormationStackID': { S: cfn_data.StackId }
            },
            ReturnConsumedCapacity: 'TOTAL',
            TableName: '${SpotCICDWorkshop.DynamoDBTestEnvironmentTable}'
          };
          ddb.putItem(ddb_params, function(err, ddb_data) {
            if (err) { return reject(err); }
            console.log('[INFO]', 'Consumed Capacity Units: ', ddb_data.ConsumedCapacity.CapacityUnits);
            return resolve();
          }); 
        });
      });
    });
  },
  terminate: function(cfn, ddb, request_payload) {
    return new Promise(function (resolve, reject) {
      var ddb_params = {
        Key: {
          'JobBaseName': { S: request_payload.jobBaseName },
          'BuildID': { N: request_payload.buildId }
        },
        TableName: '${SpotCICDWorkshop.DynamoDBTestEnvironmentTable}'
      };
      ddb.getItem(ddb_params, function(err, ddb_data) {
        if (err) { return reject(err); }
        console.log('[INFO]', 'CloudFormationStackId: ', ddb_data.Item.CloudFormationStackID.S);
        return new Promise(function (resolve, reject) {
          var cfn_params = {
            StackName: request_payload.stackName,
            RoleARN: '${SpotCICDWorkshop.IAMRoleTestEnvironmentCloudFormation.Arn}'
          };
          cfn.deleteStack(cfn_params, function(err, cfn_data) {
            if (err) { return reject(err); }
            return resolve();
          });
        });
      });
    });
  }
};
exports.handler = function (event, context, callback) {
  var p = actions[event.action];
  if (!p) {
    return callback('Unknown action');
  }
  var msgAction = event.action.toUpperCase() + ' ';
  var cfn = new AWS.CloudFormation();
  var ddb = new AWS.DynamoDB();
  console.log('[INFO]', 'Attempting', msgAction);
  return p(cfn, ddb, event).then(function (data) {
    return callback(null, data);
  }).catch(function (err) {
    console.log('[ERROR]', JSON.stringify(err));
    return callback(err);
  });
};         

```