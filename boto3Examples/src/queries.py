
DROP_STATEMENT = "DROP TABLE IF EXISTS demographics , user_databases , user_languages ;"

REDSHIFT_IAM_ROLE_ARN = ""

CREATE_DEMOGRAPHICS_STATEMENT = """
CREATE TABLE IF NOT EXISTS demographics (
 
    respondent INTEGER PRIMARY KEY,
    age INTEGER,
    country TEXT,
    gender TEXT,
    Age1stCode INTEGER,
    EducationLevel TEXT,
    Sexuality TEXT,
    Trans TEXT   
);
"""

CREATE_DATABASES_STATEMENT = """
CREATE TABLE IF NOT EXISTS user_databases (

    respondent INTEGER PRIMARY KEY,
    DatabaseWorkedWith TEXT,
    DatabaseDesireNextYear TEXT
);
"""

CREATE_LANGUAGES_STATEMENT = """
CREATE TABLE IF NOT EXISTS user_languages (
    respondent INTEGER PRIMARY KEY,
    LanguageDesireNextYear TEXT,
    LanguageWorkedWith TEXT
);
"""

COPY_DEMOGRAPHICS_INFORMATION = f"copy demographics from '<bucket_location>' iam_role {REDSHIFT_IAM_ROLE_ARN} IGNOREHEADER 1;"

COPY_DATABASES_STATEMENT = f"copy user_databases from '<bucket_location>' iam_role {REDSHIFT_IAM_ROLE_ARN} IGNOREHEADER 1;"

COPY_LANGUAGES_STATEMENT = f"copy user_languages from '<bucket_location>' iam_role {REDSHIFT_IAM_ROLE_ARN} IGNOREHEADER 1;"

CREATE_SCHEMA_STATEMENT = "CREATE DATABASE stackoverflow;"

CREATE_TABLES_STATEMENT = [CREATE_DEMOGRAPHICS_STATEMENT , CREATE_DATABASES_STATEMENT , CREATE_LANGUAGES_STATEMENT]
