# "E:\\DataProject\\developer_survey_2020\\survey_results_public.csv"
from pyspark.sql import SparkSession
import pyspark.sql.functions as f

import pyspark.sql.types as t
from pyspark.sql import Window
import configparser

import os

config = configparser.ConfigParser()
#config.read('dwh.cfg')

#print(config.sections())

#os.environ['AWS_ACCESS_KEY_ID'] = config['AWS']['KEY']
#os.environ['AWS_SECRET_ACCESS_KEY'] = config['AWS']['SECRET']

#os.environ['AWS_ACCESS_KEY_ID'] = config.get('AWS')['KEY']
#os.environ['AWS_SECRET_ACCESS_KEY'] = config.get('AWS')['SECRET']

# org.apache.hadoop:hadoop-aws:3.3.0,org.apache.hadoop:hadoop-common:3.3.0,com.google.guava:guava:30.1.1-jre"
if __name__ == '__main__':
    # .config("spark.jars.packages","saurfang:spark-sas7bdat:3.0.0-s_2.12")
    session = SparkSession.builder \
        .appName("Stackoverflow Data Set") \
        .master("yarn").getOrCreate()
        #.config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:2.7.0") \


    # initialDF = session.read.format("com.github.saurfang.sas.spark")\
    #     .load("/home/deepak/immigration_dataset/immi_data3/data/18-83510-I94-Data-2016/i94_jan16_sub.sas7bdat")

    #path = "s3a://nyeis-uat-data/survey_results_public.csv"
    path = "s3a://nice-uat-data-warehouse/data-2020/survey_results_public.csv"
    # initialDF = initialDF.groupby(f.col("insnum")).count().alias("cc").orderBy(f.desc("cc.count"))
    initialDF = session.read.option("inferSchema", "true").option("header", "true").csv(path)
    # tot = initialDF.show()
    # #initialDF.groupby("Country").count().withColumnRenamed("count", "cent_per_group") \
    #     .withColumn("percent_count", (f.col("cent_per_group") / tot) * 100).orderBy(
    #     f.col("percent_count").desc()).show()

    # demographics information of the user
    # age, Age1stCode , Country , EdLevel , Ethnicity , Gender , Sexuality , Trans

    demographicsDF = initialDF.selectExpr(
        ["Respondent", "age", "country", "gender", "Age1stCode", "EdLevel as EducationLevel", "Sexuality", "Trans"])
    # demographicsDF = demographicsDF.withColumn("gender" , f.regexp_replace("gender","NA","No info available"))
    # demographicsDF.show(truncate=False)

    demographicsDF.write.mode("overwrite").option("header","true")\
        .csv("s3a://nice-uat-data-warehouse/stackoverflow/demographics/")

    #
    # initialDF.show()

    databaseDF = initialDF.select("Respondent", "DatabaseWorkedWith", "DatabaseDesireNextYear")
    databaseDF = databaseDF.withColumn("DatabaseWorkedWith", f.split("DatabaseWorkedWith", ";")) \
        .withColumn("DatabaseDesireNextYear", f.split("DatabaseDesireNextYear", ";"))

    databaseDF = databaseDF.select("Respondent", "DatabaseDesireNextYear",
                                   f.posexplode("DatabaseWorkedWith").alias("pos", "DatabaseWorkedWith"))

    # databaseDF = databaseDF.select("Respondent","DatabaseWorkedWith",
    #    f.when(f.col('pos')== 0 , f.col("DatabaseDesireNextYear")).alias("DatabaseDesireNextYear"))

    databaseDF = databaseDF.withColumn("count", f.size("DatabaseDesireNextYear"))

    # window = Window.partitionBy("Respondent").orderBy(f.col("Respondent").asc())

    # databaseDF = databaseDF.withColumn('row_num' , f.row_number().over(window))

    databaseDF = databaseDF.withColumn("DatabaseDesireNextYear", f.expr("DatabaseDesireNextYear[pos]"))

    databaseDF = databaseDF.select(["Respondent", "DatabaseWorkedWith", "DatabaseDesireNextYear"])

    databaseDF.show(truncate=False, n=30)
    # databaseDF = databaseDF.select("*",f.posexplode_outer("DatabaseDesireNextYear").alias("pos","DatabaseDesireNextYear2"))

    # databaseDF = databaseDF.select("Respondent","DatabaseDesireNextYear2",f.when(f.col("pos") < f.col("count"),f.col("DatabaseWorkedWith"))
    #                                .when(f.col("pos").isNull(),f.col("DatabaseWorkedWith"))
    #                                .alias("DatabaseWorkedWith"))
    #                                #f.posexplode_outer("DatabaseDesireNextYear").alias("pos", "DatabaseDesireNextYear2"))
    # databaseDF.show(truncate=False)

    # Languages changes

    databaseDF.write.mode("overwrite").option("header", "true") \
        .csv("s3a://nice-uat-data-warehouse/stackoverflow/database/")

    languageDF = initialDF.select(["Respondent", "LanguageWorkedWith", "LanguageDesireNextYear"])

    languageDF = languageDF.withColumn("LanguageWorkedWith", f.split("LanguageWorkedWith", ";")) \
        .withColumn("LanguageDesireNextYear", f.split("LanguageDesireNextYear", ";"))

    languageDF = languageDF.select("*", f.posexplode_outer("LanguageWorkedWith").alias("pos", "LanguageWorkedWith2"))

    languageDF = languageDF.withColumn("LanguageDesireNextYear", f.expr("LanguageDesireNextYear[pos]"))

    languageDF = languageDF.selectExpr("Respondent","LanguageDesireNextYear","LanguageWorkedWith2 as LanguageWorkedWith")

    languageDF.write.mode("overwrite").option("header", "true") \
        .csv("s3a://nice-uat-data-warehouse/stackoverflow/language/")

    languageDF.show(n=30, truncate=False)

    session.stop()


