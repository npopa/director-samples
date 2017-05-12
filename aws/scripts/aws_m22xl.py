import boto3
import pprint
client = boto3.client('ec2')

#ami-8a158fea
#Original AMI ami-30697651

spot_instances_response = client.request_spot_instances(
    SpotPrice='0.15',
    InstanceCount=1,
    Type='one-time',
    LaunchSpecification={
      "ImageId": "ami-d52e4bb5",
      "InstanceType": "m2.2xlarge",
      "KeyName": "npopa-ps",
                "BlockDeviceMappings": [
                    {
                        "DeviceName": "/dev/sda",
                        "Ebs": {
                            "DeleteOnTermination": True,
                            "VolumeSize": 30,
                            "VolumeType": "gp2"
                        }
                    },
                    {
                        "DeviceName": "/dev/sdb",
                        "VirtualName": "ephemeral0"
                    }
                ],
      "NetworkInterfaces": [
        {
          "DeviceIndex": 0,
          "SubnetId": "subnet-38a95b60",
          "DeleteOnTermination": True,
          "AssociatePublicIpAddress": True,
          "Groups": [
            "sg-900adbf6"
          ]
        }
      ]
    }
)

pprint.pprint(spot_instances_response)
instances={}
if spot_instances_response.get('SpotInstanceRequests') is not None:
    spot_instance_req_num=len(spot_instances_response.get('SpotInstanceRequests'))

while (len(instances.values()) < spot_instance_req_num) : #This should wait till all the requests get an instanceId
    for spot_instance_req in spot_instances_response.get('SpotInstanceRequests'):
        InstanceId=client.describe_spot_instance_requests(SpotInstanceRequestIds=[spot_instance_req.get('SpotInstanceRequestId')]).get('SpotInstanceRequests')[0].get('InstanceId')
        if InstanceId is not None:
            instances[spot_instance_req.get('SpotInstanceRequestId')]=InstanceId
        else:
            print(spot_instance_req.get('SpotInstanceRequestId'), "Still did not get an InstanceId")

print instances

for i in instances.values():
    client.create_tags(Resources=[i],Tags=[{'Key': 'owner','Value': 'npopa'}])



# Find information about the VM: curl http://169.254.169.254/2009-04-04/meta-data/
