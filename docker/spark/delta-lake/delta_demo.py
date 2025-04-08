from pyspark.sql import SparkSession
from delta.tables import DeltaTable
import os

def main():
    """
    Sample Delta Lake job that demonstrates:
    1. Creating a Delta table
    2. Performing ACID transactions (insert, update, delete)
    3. Time-travel capabilities
    4. Registering the Delta table in the Hive Metastore
    """
    # Initialize Spark session with Delta Lake support
    spark = SparkSession.builder \
        .appName("Delta Lake Demo") \
        .config("spark.sql.warehouse.dir", "s3a://delta-lake/warehouse") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .enableHiveSupport() \
        .getOrCreate()

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
    
    # Define Delta table path
    delta_table_path = "s3a://delta-lake/products"
    
    # Write data to Delta table
    print("Writing data to Delta table...")
    df.write \
        .format("delta") \
        .mode("overwrite") \
        .save(delta_table_path)
    
    # Read the Delta table
    print("Reading Delta table:")
    delta_df = spark.read.format("delta").load(delta_table_path)
    delta_df.show()
    
    # Get the current version of the Delta table
    print("Current Delta table version:")
    version_0 = spark.sql(f"DESCRIBE HISTORY delta.`{delta_table_path}`").first()["version"]
    print(f"Version: {version_0}")
    
    # Perform UPDATE operation (ACID transaction)
    print("Performing UPDATE operation...")
    delta_table = DeltaTable.forPath(spark, delta_table_path)
    delta_table.update(
        condition="id = 3",
        set={"price": "200.00"}
    )
    
    # Show updated data
    print("Data after UPDATE:")
    delta_df = spark.read.format("delta").load(delta_table_path)
    delta_df.show()
    
    # Get the new version after UPDATE
    print("Delta table version after UPDATE:")
    version_1 = spark.sql(f"DESCRIBE HISTORY delta.`{delta_table_path}`").first()["version"]
    print(f"Version: {version_1}")
    
    # Perform DELETE operation (ACID transaction)
    print("Performing DELETE operation...")
    delta_table.delete("id = 5")
    
    # Show data after DELETE
    print("Data after DELETE:")
    delta_df = spark.read.format("delta").load(delta_table_path)
    delta_df.show()
    
    # Get the new version after DELETE
    print("Delta table version after DELETE:")
    version_2 = spark.sql(f"DESCRIBE HISTORY delta.`{delta_table_path}`").first()["version"]
    print(f"Version: {version_2}")
    
    # Perform INSERT operation (ACID transaction)
    print("Performing INSERT operation...")
    new_data = [
        (6, "Product F", 250.00, "2023-01-20"),
        (7, "Product G", 175.25, "2023-01-21")
    ]
    new_df = spark.createDataFrame(new_data, columns)
    
    delta_table.alias("old") \
        .merge(
            new_df.alias("new"),
            "old.id = new.id"
        ) \
        .whenNotMatchedInsertAll() \
        .execute()
    
    # Show data after INSERT
    print("Data after INSERT:")
    delta_df = spark.read.format("delta").load(delta_table_path)
    delta_df.show()
    
    # Get the new version after INSERT
    print("Delta table version after INSERT:")
    version_3 = spark.sql(f"DESCRIBE HISTORY delta.`{delta_table_path}`").first()["version"]
    print(f"Version: {version_3}")
    
    # Demonstrate time-travel capability
    print("Demonstrating time-travel capability...")
    
    # Read data at version 0 (original data)
    print(f"Data at version {version_0} (original):")
    df_v0 = spark.read.format("delta").option("versionAsOf", version_0).load(delta_table_path)
    df_v0.show()
    
    # Read data at version 1 (after UPDATE)
    print(f"Data at version {version_1} (after UPDATE):")
    df_v1 = spark.read.format("delta").option("versionAsOf", version_1).load(delta_table_path)
    df_v1.show()
    
    # Read data at version 2 (after DELETE)
    print(f"Data at version {version_2} (after DELETE):")
    df_v2 = spark.read.format("delta").option("versionAsOf", version_2).load(delta_table_path)
    df_v2.show()
    
    # Show table history
    print("Delta table history:")
    history_df = spark.sql(f"DESCRIBE HISTORY delta.`{delta_table_path}`")
    history_df.show(truncate=False)
    
    # Register Delta table in Hive metastore
    print("Registering Delta table in Hive metastore...")
    spark.sql(f"""
    CREATE TABLE IF NOT EXISTS delta_products
    USING DELTA
    LOCATION '{delta_table_path}'
    """)
    
    # Verify table creation
    print("Verifying table creation:")
    spark.sql("SHOW TABLES").show()
    spark.sql("SELECT * FROM delta_products").show()
    
    print("Delta Lake functionality demonstration completed successfully!")
    
    # Stop Spark session
    spark.stop()

if __name__ == "__main__":
    main()
