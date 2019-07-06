#!/usr/bin/env python3

import boto3
import time
import subprocess
import argparse
import os
import sys


def parseArguments():
    """ parses arguments
    Helper function to parse command line arguments and return internally the parameters selected 
    or print a help function
    
    Returns:
    string:SQS queue url
    string:AWS region where the queue can be found
    bool:Boolean describing if the process should stop when the queue is drained
    int:Number of iterations to go through when drain_queue is set to true
    int:Number of seconds to pause between polls to the queue
    """
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--queue', dest='queue',default='workshop', help='Amazon SQS')
    parser.add_argument('--region', dest='region',default=None, help='Region')
    parser.add_argument('--polling-freq-inSec', dest='sleep_interval', default=5, help='Time in seconds between polling')
    parser.add_argument('--drain-queue-mode', dest='drain_queue_mode', default=False, help='Stop the queue has been drained')
    parser.add_argument('--drain-queue-iterations', dest='drain_queue_iterations', 
        default=10, 
        help='Number of iterations to go through when drain_queue is set to true')

    args = parser.parse_args()
    queue = args.queue
    region = args.region
    sleep_time_insecs = args.sleep_interval
    drain_queue = args.drain_queue_mode
    drain_queue_iterations = args.drain_queue_iterations

    try:
        if region is None:
            region = os.getenv("REGION")
    except:
        raise "Must pass region as environment variable or argument"
    
    if os.getenv("BATCH_MODE") == "true":
        drain_queue = True
        

    return queue, region, sleep_time_insecs, drain_queue, drain_queue_iterations

class SimulationParameters:
    """ Class used to hold the Simulation parameters
    Use the static method to parse SQS Messages and generate instances of this
    type.
    """
    stock = ''
    short_window_days = ''
    long_window_days = ''
    trading_days = ''
    iterations = ''
    valuation_id = ''
    s3_bucket =''
    
    @staticmethod
    def extractSimulationParameters(message):
        if message.message_attributes is None:
            return None
        simulation_parameters = SimulationParameters()
        simulation_parameters.stock = message.message_attributes.get('stock').get('StringValue')
        simulation_parameters.short_window_days = message.message_attributes.get('short').get('StringValue')
        simulation_parameters.long_window_days = message.message_attributes.get('long').get('StringValue')
        simulation_parameters.trading_days = message.message_attributes.get('days').get('StringValue')
        simulation_parameters.iterations = message.message_attributes.get('iter').get('StringValue')
        simulation_parameters.valuation_id = message.message_attributes.get('key').get('StringValue')
        simulation_parameters.s3_bucket = message.message_attributes.get('bucket').get('StringValue')
        return simulation_parameters


# takes inputs, runs simulations and returns CSV output
def runSimulation(simulation_parameters):
    """ Run simulations
    This function uses the subprocess module to execute the simulation in an
    out of process mode.
    
    Parameters:
    simulation_parameters (SimulationParameters): Object with the simulation 
        parameters
    
    Returns:
    int: The exit code for the process, 0 if everything went well 
    """
    # use Subprocess to call code
    try:
        output_value = 0
        subprocess.check_output([
            'python3','worker.py',
            '--stock', simulation_parameters.stock,
            '--short_window_days', simulation_parameters.short_window_days, 
            '--long_window_days', simulation_parameters.long_window_days, 
            '--trading_days', simulation_parameters.trading_days,
            '--iterations', simulation_parameters.iterations,
            '--id', simulation_parameters.valuation_id]
        )
        return output_value
    except subprocess.CalledProcessError as e:
        return e.returncode

    
def storeResults(simulation_parameters):
    expected_result_files = [
        "{0}_{1}_{2}.csv".format(
            simulation_parameters.valuation_id, 
            simulation_parameters.stock,
            x
        ) for x in  [
        "MonteCarloSimResult",
        "portfolio_total",
        "sim_results"]
    ]
    expected_result_files.append(
        "{0}_PortfolioRiskAssessment.csv".format(
            simulation_parameters.valuation_id)
    )
    
    s3 = boto3.client('s3')
    for res_file_path in expected_result_files:
        print('Saving {0} to S3'.format(res_file_path))
        s3.upload_file(
            res_file_path, 
            simulation_parameters.s3_bucket, 
            res_file_path)
        print('Cleaning up {0}'.format(res_file_path))
        os.remove(res_file_path)

def inLoop(drain_queue=False, drain_queue_iterations=[10]):
    drain_queue_iterations[0] = max(0,drain_queue_iterations[0]-1)
    if not drain_queue or drain_queue_iterations[0] > 0:
        return True
    print("Queue worker was configured in batch mode. It has reached the max retries and will be exiting now")
    return False

# Checks the queue for new messages, 
# send them to the simulation if found and deletes from queue once complete.
def main(argv):
    message_count = 0
    queue, region, sleep_time_insecs, drain_queue, drain_queue_iterations = parseArguments()
    drain_queue_iterations = [drain_queue_iterations]

    # Get the SQS service resource and the queue
    sqs = boto3.resource('sqs', region_name=region)
    queue = sqs.get_queue_by_name(QueueName=queue)

    while inLoop(drain_queue, drain_queue_iterations):
        # Get message attributes and call simulation
        for message in queue.receive_messages(MessageAttributeNames=['All']):
            simulation_parameters = SimulationParameters.extractSimulationParameters(message)
            message_count = message_count + 1

            # run simulations and get results
            print('Starting simulation')
            simStatus = runSimulation(simulation_parameters)
            print('Simulation Returned: {0}'.format(simStatus))

            if simStatus == 0:
                storeResults(simulation_parameters)
                
                # delete the processed message
                print('Telling SQS message was successfully processed')
                message.delete()
                print('Messages processed: {0}'.format(message_count))
            print('Simulation {0}: stock={1}, short={2}, long={3}, days={4}, iterations={5}, id={6}, bucket={7}'.format(
                "success" if simStatus ==0 else "failure",
                simulation_parameters.stock,
                simulation_parameters.short_window_days,
                simulation_parameters.long_window_days,
                simulation_parameters.trading_days,
                simulation_parameters.iterations,
                simulation_parameters.valuation_id,
                simulation_parameters.s3_bucket))
        print('pausing for {0} seconds.'.format(sleep_time_insecs))
        time.sleep(sleep_time_insecs)
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))