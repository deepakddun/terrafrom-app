import json
import boto3

EVENT_TYPE = "REDSHIFT-EVENT-2000"


def hello(event=None, context=None):
    print(event)
    if event is not None:
        message = event['Records'][0]['Sns']['Message']
        print(message)
        if message is not None and EVENT_TYPE in message:
            # convert the str to python dictionary
            message_dict = json.loads(message)
            print(message)
            # get the cluster details
            cluster_name = message_dict.get('Resource', None)
            print(cluster_name)
            if cluster_name is not None:
                client_red = boto3.client('redshift',region_name = 'us-east-2')
                clusters = client_red.describe_clusters(ClusterIdentifier=cluster_name)
                cluster_detail = clusters.get('Clusters')[0]
                print(cluster_detail)
                db_name = cluster_detail.get('DBName')
                db_endpoint = cluster_detail.get('Endpoint')
                print(db_endpoint)
                db_address = db_endpoint.get('Address')
                db_port = db_endpoint.get('Port')

                print(db_name)
                print(db_address)
                print(db_port)

                client_data = boto3.client('redshift-data' , region_name = 'us-east-2')

                client_data.execute_statement(
                    ClusterIdentifier = '',
                    Database = '',
                    DbUser = '',
                    Sql = ''
                )
