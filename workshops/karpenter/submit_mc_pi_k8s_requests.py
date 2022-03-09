#!/usr/bin/env python3

## Author : Carlos Manzanedo Rueda <ruecarlo@amazon.com>
## License: Apache 2.0

from multiprocessing import Pool
import requests
import time
import json
import argparse
from functools import reduce
from tqdm import tqdm
import sys

url = ""

def getUrl(url):
    try:
        return requests.get(url,timeout=30)
    except Exception as e:
        pass
        #print("Ouch, I'm getting timeouts !!!! ")

def runParallelRequests(processes=10, queued_requests_per_process=10,url="",iterations=10000000):
    the_url = url + "/?iterations=" + str(iterations)
    queue_of_urls = [ the_url for x in range(processes * queued_requests_per_process) ]
    print("Total processes: {}\nLen of queue_of_urls: {}\ncontent of queue_of_urls: {}".format(
        processes,
        len(queue_of_urls), 
        queue_of_urls[0]))
    pool = Pool(processes)
    try:
        results = []
        for res in tqdm(pool.imap_unordered(getUrl, queue_of_urls), total=len(queue_of_urls)):
            results.append(res)
    finally:
        pool.close()
        pool.join()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p','--processes',dest='processes',type=int,default=10, help="Number of parallel processes to use as clients")
    parser.add_argument('-r','--requests',dest='req',type=int,default=10, help="Number of requests each client process will run")
    parser.add_argument('-u','--url',dest='url',type=str, default=url, help="URL that will be used to do the GET request")
    parser.add_argument('-i','--iterations', dest='iterations', default=10000000, help="Number of montecarlo iterations requested")
    args = parser.parse_args()
   
    runParallelRequests(
        processes=args.processes,
        queued_requests_per_process=args.req,
        url=args.url,
        iterations=args.iterations
    )


if __name__ == "__main__":
    main()
