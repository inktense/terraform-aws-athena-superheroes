import sys

from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F

import pandas as pd
import awswrangler as wr

# We instantiate a GlueContext object, which allows us to work with the data in AWS Glue.
glueContext = GlueContext(SparkContext.getOrCreate())
job = Job(glueContext)

args = getResolvedOptions(sys.argv, [
    'JOB_NAME', 
    'catalog_database_name', 
    'catalog_table_name', 
    'curated_data_path',
    ])
    
database_name = args['catalog_database_name']
table_name = args['catalog_table_name']
output_location = args['curated_data_path']
    
# Load our data from the catalog that we created with a crawler
# We use this DynamicFrame to perform any necessary operations on the data structure before it’s written to our desired output format.
# The source files remain unchanged.
dynamicFrame = glueContext.create_dynamic_frame.from_catalog(
    database = database_name,
    table_name = table_name,
    # format= 'csv',
    # {'withHeader': True},
    transformation_ctx = "dynamicFrame")
    
superheroesPandas = dynamicFrame.toDF().toPandas()
    
print("main table = > ", superheroesPandas.columns)
print(superheroesPandas.to_string())

# Save data as parquet files in S3
wr.s3.to_parquet(
    df = superheroesPandas,
    path = output_location,
    dataset = True, # Saved data in a parquet file instead of an ordinary one
    mode = 'overwrite'
    )
