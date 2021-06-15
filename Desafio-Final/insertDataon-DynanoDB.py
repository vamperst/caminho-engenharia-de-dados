from __future__ import print_function  # Python 2/3 compatibility
import boto3
from boto3.dynamodb.conditions import Key
from baseDAO import BaseDAO
import random
from datetime import datetime
import json
import sys
import time
import csv
import string
import random
import threading
import glob
from multiprocessing import Queue

queue = Queue()

boto_args = {'service_name': 'dynamodb'}
print('Number of arguments:', len(sys.argv), 'arguments.')
print('Argument List:', str(sys.argv))

dao = BaseDAO('susep-sinistro')


def insert_from_file(fileName, thread_id, num_paralell_threads):
    time1 = time.time()
    file1 = open(fileName, 'r')
    count = 0
    send = 0
    list_to_send = []
    # Using for loop
    # print("Using for loop")

    for line in file1:
        count = count + 1
        list_to_send.append(json.loads(line))
        send = send + 1
        # dao.put_item(json.loads(line))
        # print("Line{}: {}".format(count, line.strip()))
        if(send == 25):
            response = dao.put_item_batch(list_to_send)
            # print(json.dumps(response['ConsumedCapacity']))
            if(len(response['UnprocessedItems']) > 0):
                print(json.dumps(response['UnprocessedItems']))
            # print(f"Count: {count}")
            send = 0
            list_to_send = []
            time2 = time.time() - time1
            print("thread_id: %s, row: %s, %s" % (thread_id, count, time2))

    if(send > 0):
        response = dao.put_item_batch(list_to_send)
        # print(json.dumps(response['ConsumedCapacity']))
        if(len(response['UnprocessedItems']) > 0):
            print(json.dumps(response['UnprocessedItems']))
    # Closing files
    time2 = time.time() - time1
    print("thread_id: %s, row: %s, %s" % (thread_id, count, time2))
    time1 = time.time()
    file1.close()
    queue.put(count)


# path = sys.argv[1]
# for i in range(135):
#     insert_from_file('{}/susep.{:02d}.json'.format(path,i))
if __name__ == "__main__":
    args = sys.argv[1:]
    path = args[0]
    thread_list = []
    num_paralell_threads = int(args[1])

    begin_time = time.time()
    boto3.resource(**boto_args)

    #
    print(f"{path}/*.json")
    files = glob.glob(f"{path}/*.json")
    print(files)
    thread_id = 0
    count_threads = 0
    for f in files:

        thread = threading.Thread(
            target=insert_from_file, args=(f, thread_id, num_paralell_threads))
        thread_list.append(thread)
        count_threads += 1
        print("count_threads: {}".format(count_threads))
        if(int(count_threads) == int(num_paralell_threads)):
            print("entered threads runner: {}".format(count_threads))
            for thread in thread_list:
                print("starting thread for file: %s" % (f))
                thread.start()

            # Block main thread until all threads are finished
            for thread in thread_list:
                thread.join()

            thread_list.clear()
            count_threads = 0

        thread_id += 1

        # time.sleep(.2)

    # # Start threads
    # for thread in thread_list:
    #     thread.start()

    # # Block main thread until all threads are finished
    # for thread in thread_list:
    #     thread.join()

    totalcount = 0
    for t in range(len(files)):
        totalcount = totalcount + queue.get()

    print('total rows %s in %s seconds' %
          (totalcount, time.time() - begin_time))
