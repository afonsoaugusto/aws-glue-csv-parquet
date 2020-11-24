import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "user_db", table_name = "load_csv", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "user_db", table_name = "load_csv", transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("id", "long", "id", "long"), ("name", "string", "name", "string"), ("email", "string", "email", "string"), ("phone", "string", "phone", "string"), ("address", "string", "address", "string"), ("age", "long", "age", "long"), ("create_date", "string", "create_date", "timestamp"), ("update_date", "string", "update_date", "timestamp")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("id", "long", "id", "long"), ("name", "string", "name", "string"), ("email", "string", "email", "string"), ("phone", "string", "phone", "string"), ("address", "string", "address", "string"), ("age", "long", "age", "long"), ("create_date", "string", "create_date", "timestamp"), ("update_date", "string", "update_date", "timestamp")], transformation_ctx = "applymapping1")
## @type: ResolveChoice
## @args: [choice = "make_struct", transformation_ctx = "resolvechoice2"]
## @return: resolvechoice2
## @inputs: [frame = applymapping1]
resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")
## @type: DropNullFields
## @args: [transformation_ctx = "dropnullfields3"]
## @return: dropnullfields3
## @inputs: [frame = resolvechoice2]
dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")
## @type: DataSink
## @args: [connection_type = "s3", connection_options = {"path": "s3://glue-terraform/data/output"}, format = "parquet", transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = dropnullfields3]
datasink4 = glueContext.write_dynamic_frame.from_options(frame = dropnullfields3, connection_type = "s3", connection_options = {"path": "s3://glue-terraform/data/output"}, format = "parquet", transformation_ctx = "datasink4")
job.commit()