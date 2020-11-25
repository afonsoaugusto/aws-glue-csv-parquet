import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import to_timestamp, desc, col
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
import json
from awsglue.dynamicframe import DynamicFrame


def join_with_columns_origin(types_mapping:dict, list_columns_origin:list) -> list:
    
    types_mapping_with_columns_origin = []
    
    for column_type_origin in list_columns_origin:
        if column_type_origin[0] not in types_mapping:
            tupla = (column_type_origin[0], column_type_origin[1], column_type_origin[0], column_type_origin[1])
            types_mapping_with_columns_origin.append(tupla)
        else:
            tupla = (column_type_origin[0], column_type_origin[1],column_type_origin[0], types_mapping[column_type_origin[0]])
            types_mapping_with_columns_origin.append(tupla)

    return types_mapping_with_columns_origin

def load_mapping_types(types_mapping_dict:dict, list_columns_origin:list) -> list:
    types_mapping_with_columns_origin_list = join_with_columns_origin(types_mapping_dict, list_columns_origin)
    
    return types_mapping_with_columns_origin_list

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Definitions
config_types_mapping_filename = "config/types_mapping.json"
data_filename_import = "data/input/users/load.csv"

column_sort_values = "update_date"
column_drop_duplicates = "id"
time_format = "yyyy-MM-dd HH:mm:ss.SSSSSS"

BUCKET_NAME = 'glue-terraform-scripts'
KEY = config_types_mapping_filename

s3 = boto3.client('s3')

response = s3.get_object(Bucket = BUCKET_NAME, Key = KEY)
content = response['Body']
jsonObject = json.loads(content.read())
print(jsonObject)

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

raw_dynamic_frame = glueContext.create_dynamic_frame.from_catalog(database = "aws-glue-csv-parquet", table_name = "load_csv", transformation_ctx = "raw_dynamic_frame")

sdf_row_data = raw_dynamic_frame.toDF()
sdf_row_data.select(column_sort_values).show()

sdf_conveted_column_to_sort_data = sdf_row_data.withColumn(column_sort_values, col(column_sort_values).cast("timestamp"))
sdf_sorted_data = sdf_conveted_column_to_sort_data.orderBy(desc(column_sort_values))

print(sdf_sorted_data.show())

sdf_deduplicate_data = sdf_sorted_data.drop_duplicates([column_drop_duplicates])

types_mapping_dict = load_mapping_types(jsonObject, sdf_deduplicate_data.dtypes)

print(types_mapping_dict)

df_deduplicate_data = DynamicFrame.fromDF(sdf_deduplicate_data, glueContext, "df_deduplicate_data")
print(type(df_deduplicate_data))
print(type(raw_dynamic_frame))
df_converted_type_data = ApplyMapping.apply(frame = df_deduplicate_data, mappings = types_mapping_dict, transformation_ctx = "df_converted_type_data")

datasink = glueContext.write_dynamic_frame.from_options(frame = df_converted_type_data, connection_type = "s3", connection_options = {"path": "s3://glue-terraform/data/output"}, format = "parquet", transformation_ctx = "datasink")


job.commit()