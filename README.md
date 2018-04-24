## tf-aws-lambda-stop-start
-----

This module is should be used where customers wish to shutdown and startup specific instances on a schedule. It is triggered by a Cloudwatch schedule that launches a Lambda function.

The instances must be tagged with "Scheduled-Stop-Start" for the function to apply.

Currently the lambda function looks for any instances tagged with the above tag and checks the status of the instance, if the instance is running when the "bedtime" event occurs then it will be shutdown, if the instance is stopped when the "wakeup" event occurs it will be started.

The schedule must be in cron format, for example by default the startup occurs at 07:00 UTC which is equal to "cron(0 7 * * ? *)" and the shutdown at 17:00 UTC which is equal to "cron(0 17 * * ? *)"

The UTC timing does mean that if scheduling based on GMT+1 you will have to modify your schedule to occur one hour earlier than the standard GMT+1 time.

### Prerequisites

The only prerequisite is that instances are tagged with the following:
Key: Scheduled-Stop-Start
Value: yes

Declare a module in your Terraform file, for example:

    module "lambda-stop-start" {
      source = "../modules/tf-aws-lambda-stop-start"

      name                = "${var.customer}"
      envname             = "${var.envname}"
      cron_stop_schedule  = "cron(0 17 * * ? *)"
      cron_start_schedule = "cron(0 7 * * ? *)"
    }



### Variables

    name - name of customer
    envname - name of environment
    cron_stop_schedule - crontab to trigger the Lambda - default set to daily 17:00 UTC (will occur at 18:00 GMT+1)
    cron_start_schedule - crontab to trigger the Lambda - default set to daily 07:00 UTC (will occur at 08:00 GMT+1)
