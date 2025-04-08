from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lit

def main():
    """
    Sample ETL job that demonstrates:
    1. Reading data from a CSV file
    2. Performing transformations
    3. Writing data to MinIO in Parquet format
    4. Registering the data as a table in the Hive Metastore
    """
    print(f">>>> Inside main!")
    # Initialize Spark session with Hive and S3 support
    spark = SparkSession.builder \
        .appName("Sample ETL Job") \
        .config("spark.jars.ivy","/tmp/.ivy") \
        .config("spark.sql.warehouse.dir", "s3a://raw-data/warehouse") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
        .enableHiveSupport() \
        .getOrCreate()

    print(f">>>> Spark session created main!")
    # Create sample data
    print("Creating sample data...")
    data = [
        (1, "Product A", 100.50, "2023-01-15"),
        (2, "Product B", 200.75, "2023-01-16"),
        (3, "Product C", 150.25, "2023-01-17"),
        (4, "Product D", 300.00, "2023-01-18"),
        (5, "Product E", 175.50, "2023-01-19")
    ]
    
    # Define schema
    columns = ["id", "product_name", "price", "sale_date"]
    
    # Create DataFrame
    df = spark.createDataFrame(data, columns)
    
    # Show the data
    print("Sample data:")
    df.show()
    
    # Perform transformations
    print("Performing transformations...")
    transformed_df = df.withColumn("price_with_tax", col("price") * 1.1) \
                       .withColumn("data_source", lit("sample_etl"))
    
    # Show transformed data
    print("Transformed data:")
    transformed_df.show()
    
    # Write data to MinIO in Parquet format
    print("Writing data to MinIO...")
    transformed_df.write \
        .mode("overwrite") \
        .parquet("s3a://processed-data/sample_sales")
    
    # Create Hive table pointing to the data
    print("Creating Hive table...")
    spark.sql("DROP TABLE IF EXISTS sample_sales")
    spark.sql("""
    CREATE TABLE sample_sales (
        id LONG,
        product_name STRING,
        price DOUBLE,
        sale_date STRING,
        price_with_tax DOUBLE,
        data_source STRING
    )
    STORED AS PARQUET
    LOCATION 's3a://processed-data/sample_sales'
    """)
    
    # Verify table creation by querying the data
    print("Verifying table creation by querying data:")
    transformed_df.printSchema()
    spark.sql("SELECT * FROM sample_sales").printSchema()
    spark.sql("SELECT * FROM sample_sales").show()
    
    # Print table information
    print("Table information:")
    spark.sql("DESCRIBE FORMATTED sample_sales").show(truncate=False)
    
    print("ETL job completed successfully!")
    
    # Stop Spark session
    spark.stop()

if __name__ == "__main__":
    main()
