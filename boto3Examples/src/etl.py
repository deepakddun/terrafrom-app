import os
import psycopg2
import queries as q





conn = psycopg2.connect(host="qa-redshift-cluster.cuzz3vbarbrm.us-east-2.redshift.amazonaws.com" ,
                        user ="deepak" , database = "qawarehouse" , password = "")

cur = conn.cursor()

for statement in q.CREATE_TABLES_STATEMENT:
    cur.execute(statement)
    conn.commit()






