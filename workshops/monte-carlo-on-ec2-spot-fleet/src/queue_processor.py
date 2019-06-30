import boto3
import time
import subprocess
import argparse
import os

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('--queue', dest='queue',default='workshop', help='Amazon SQS')
parser.add_argument('--region', dest='region',default=None, help='Region')
args = parser.parse_args()
QUEUE = args.queue
REGION = args.region

try:
    if REGION is None:
        REGION = os.getenv("REGION")
except:
    raise "Must pass region as environment variable or argument"


sleepTime = 5

# takes inputs, runs simulations and returns CSV output
def runSimulation(stock_symbol,short,longVa,days,iterVa,ukey,s3Bucket):
    print('Starting simulation')
    # use Subprocess to call code str.find(str, beg=0, end=len(string))
    try:
        output_value = 0
        subprocess.check_output(['python','worker.py','--stock', stock_symbol,'--short_window_days',short, '--long_window_days', longVa, '--trading_days', days, '--id', ukey])
        return output_value
    except subprocess.CalledProcessError as e:
        return e.returncode

# Save the simulation results to an S3 bucket
def saveToS3(bucket_name,filename):
    s3 = boto3.client('s3')
    s3.upload_file(filename, bucket_name, filename)
    # s3 = boto3.resource('s3', region_name=REGION)
    # s3.Bucket(s3Bucket).put_object(Key=file_key, Body=simData)
    


# Checks the queue for new messages, 
# send them to the simulation if found and deletes from queue once complete.
def main():
    while True:
        # Get the SQS service resource
        sqs = boto3.resource('sqs', region_name=REGION)

        # Get the queue
        queue = sqs.get_queue_by_name(QueueName=QUEUE)

        MessageCount = 0

        # Get message attributes and call simulation
        for message in queue.receive_messages(MessageAttributeNames=['All']):
            
            MessageCount = MessageCount + 1

            # Get the  message attributes
            stock_symbol = ''
            short = ''
            longVa = ''
            days = ''
            iterVa = ''
            ukey = ''
            s3Bucket = ''
            if message.message_attributes is not None:
                stock_symbol = message.message_attributes.get('stock').get('StringValue')
                short = message.message_attributes.get('short').get('StringValue')
                longVa = message.message_attributes.get('long').get('StringValue')
                days = message.message_attributes.get('days').get('StringValue')
                iterVa = message.message_attributes.get('iter').get('StringValue')
                ukey = message.message_attributes.get('key').get('StringValue')
                s3Bucket = message.message_attributes.get('bucket').get('StringValue')

            # run simulations and get results
            simStatus = runSimulation(stock_symbol,short,longVa,days,iterVa,ukey,s3Bucket)
            print('Simulation Returned: \n {0}'.format(simStatus))
            print('Simulation ReturnCode = {0}'.format(simStatus))

            if simStatus == 0:
                mcfile = '{0}_{1}_MonteCarloSimResult.csv'.format(ukey, stock_symbol)
                ptfile = '{0}_{1}_portfolio_total.csv'.format(ukey, stock_symbol)
                srfile = '{0}_{1}_sim_results.csv'.format(ukey, stock_symbol)
                prafile = '{0}_PortfolioRiskAssessment.csv'.format(ukey)

                # save results to s3 bucket
                print('Saving files to S3')
                saveToS3(s3Bucket, mcfile)
                saveToS3(s3Bucket, ptfile)
                saveToS3(s3Bucket, srfile)
                saveToS3(s3Bucket, prafile)
                
                print('Cleaning up local files')
                subprocess.check_output(['rm',mcfile])
                subprocess.check_output(['rm',ptfile])
                subprocess.check_output(['rm',srfile])
                subprocess.check_output(['rm',prafile])

                # delete the processed message
                print('Telling SQS message was successfully processed')
                message.delete()

                print('Simulation success: stock={0}, short={1}, long={2}, days={3}, iterations={4}, id={5}, bucket={6}'.format(stock_symbol,short,longVa,days,iterVa,ukey,s3Bucket))
                print('Messages processed: {0}'.format(MessageCount))
            else:
                print('Simulation failed: stock={0}, short={1}, long={2}, days={3}, iterations={4}, id={5}, bucket={6}'.format(stock_symbol,short,longVa,days,iterVa,ukey,s3Bucket))
                
    
            
            
            
        
        print('pausing for {0} seconds.'.format(sleepTime))
        time.sleep(sleepTime)

main()