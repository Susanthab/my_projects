parameters:
  Region:
    type: string
    required: true
    position: 0
    default: "us-east-1"
  AvailabilityZones:
    type: array
    required: true
    position: 1
    default: ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e"]
  LaunchConfigurationName:
    type: string
    required: true
    position: 2
  Asg_name:
    required: true
    type: string
    position: 3
  Environment:
    required: true
    type: string
    position: 4
  App_type:
    required: true
    type: string
    position: 5
  Team: 
    type: string
    required: true
    position: 6
  MinSize:
    type: integer
    required: true
    position: 7
    default: 3
  DesiredCapacity:
    type: integer
    required: true
    position: 8
    default: 2
  MaxSize:
    type: integer
    required: true
    position: 9
    default: 7
  ImageId:
    required: false
    type: string
    position: 10
    default: "ami-47bc4c51"
  KeyName:
    required: false
    type: string
    position: 11
    default: "susanthab"
  SecurityGroups:
    required: false
    type: array
    position: 12
    default: "sg-06249479"
  IamInstanceProfile:
    required: false
    type: string
    position: 13
    default: "MongoDBRole"
  EbsOptimized:
    required: false
    type: string
    position: 14
    default: false
  InstanceType:
    required: false
    type: string
    position: 15
    default: "t2.micro"
runner_type: mistral-v2