import boto3
import botocore
import csv
from concurrent.futures import ThreadPoolExecutor

BUCKET = "bcodmo-redmine"
CSV_FILE_NAME = "out2.csv"

s3 = boto3.resource("s3")
client = boto3.client("s3")
my_bucket = s3.Bucket(BUCKET)


def update_obj(filename, key, index):
    try:
        s3_object = s3.Object(BUCKET, key)

        r = client.head_object(Bucket=BUCKET, Key=key)

        s3_object.copy_from(
            CopySource={"Bucket": BUCKET, "Key": key},
            Metadata={},
            MetadataDirective="REPLACE",
            ContentType=r["ContentType"],
            ContentDisposition=f"inline; filename={filename}",
        )
    except botocore.exceptions.ClientError as e:
        print("Failed with row ", row, e)


executor = ThreadPoolExecutor(20)

results = []
with ThreadPoolExecutor(20) as executor:
    with open(CSV_FILE_NAME, "r", encoding="utf-8") as csv_file:
        reader = csv.reader(csv_file, delimiter="\t")
        header = next(reader)
        counter = 0
        updated = 0

        for row in reader:
            counter += 1
            if row[1] == "":
                continue
            filename = row[0]
            key = f"{row[2]}/{row[1]}"
            updated += 1
            result = executor.submit(update_obj, filename, key, updated)

            results.append(result)

            if counter % 50 == 0:
                print(f"Iterated through {counter} files, updated {updated}...")
    counter = 0
    for result in results:
        counter += 1
        if counter % 50 == 0:
            print(f"Finished with {counter} files!")
        result.result()
print("Done!")
