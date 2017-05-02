import boto3

def toggle_instance(instance, start):
    ec2 = boto3.resource("ec2", region_name="eu-west-1")
    instance = ec2.Instance(instance["InstanceId"])
    if start:
        instance.start()
    else:
        instance.stop()
    
def toggle_instances(start):
    ec2_client = boto3.client("ec2", region_name="eu-west-1")
    action_name = 'start' if start else 'stop'
    print('Looking for instances to {}'.format(action_name))
    # Look for the tag stopAtNight
    description = ec2_client.describe_instances( Filters=[ { 'Name': 'instance-state-name', 
        'Values': ['stopped' if start else 'running'] },
        { 'Name': 'tag:Scheduled-Stop-Start', 'Values' : ['yes'] }])
    
    for reservation in description["Reservations"]:
        for instance in reservation["Instances"]:
            print('instance to {}: {}'.format(action_name, instance["InstanceId"]))
            toggle_instance(instance, start)

        
def lambda_handler(event, context):
    toggle_instances("wakeup" in event["resources"][0])