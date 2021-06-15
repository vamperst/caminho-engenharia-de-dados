import boto3
import json
import uuid
import os
from kinesisHandler import KinesisHandler
from baseDAO import BaseDAO

deliveryStream = KinesisHandler(os.environ["kinesisName"])


def handler(event, context):
    print(f"event: %s" % json.dumps(event))
    dao = BaseDAO('susep-sinistro')

    for record in event["Records"]:
        item = dict()
        if("NewImage" in record["dynamodb"].keys()):
            rec = record["dynamodb"]["NewImage"]
            item = dao.ddb_to_dict(rec)
            print("New Image: {}".format(json.dumps(item)))
        else:
            pass

        # item["PurchaseID"] = rec["PurchaseID"]["S"]
        # item["PriceID"] = rec["PriceID"]["S"]
        # item["UserID"] = rec["UserID"]["S"]
        # item["SKU"] = rec["SKU"]["S"]

        deliveryStream.put_record(json.dumps(item))
