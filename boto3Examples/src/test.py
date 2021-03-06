import json
import ast

st = {'Records': [{'EventSource': 'aws:sns', 'EventVersion': '1.0', 'EventSubscriptionArn': 'arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic:cbdfec04-7502-4509-9954-435e1ddc5e3c', 'Sns': {'Type': 'Notification', 'MessageId': 'fecb7b39-a861-5450-9189-23d0ce68f268', 'TopicArn': 'arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic', 'Subject': '[Amazon Redshift INFO] - Cluster Created', 'Message': '{"Event Source":"cluster","Resource":"qa-redshift-cluster","Event Time":"2021-04-08 20:12:57.466","Identifier Link":"https://console.aws.amazon.com/redshift/home?region=us-east-2#cluster-details:cluster=qa-redshift-cluster ","Severity":"INFO","Category":["Management"],"About this Event":"http://docs.aws.amazon.com/redshift/latest/mgmt/working-with-event-notifications.html#REDSHIFT-EVENT-2000 ","Event Message":"Amazon Redshift cluster \'qa-redshift-cluster\' has been created at 2021-04-08 20:12 UTC and is ready for use."}', 'Timestamp': '2021-04-08T20:12:57.905Z', 'SignatureVersion': '1', 'Signature': 'jS2AK8hf/rebeXMsfFw0DJx+788w+RiDTXyAbLNZzYdE5Mlhi6GRRIns8VaAJZc5otXkkhGshvgvuE0JsUiOhXBccGEJY6Z+lhx6cLSQoEdQB0DRfwltWKOfpQ88LZXJuKCxYcsPL3y5veBdjJqwjdBZtcVYV9BYRhQvT6q/0MpDcJeOYzMkdpR2ULX5B7GasZ3AV0WbKxIjjzFSd3GNud2m85obRrB//NHQwqN6ydvg7SaN/sXuyJjmguRok27O6YNkIqzKjC4JxDbTl4BwyIbck59edbHC5kxmfpoc/RqjF/kUGaqnf0HYOUuMfDT85+9wYVz8vFFER1v3NnKRLA==', 'SigningCertUrl': 'https://sns.us-east-2.amazonaws.com/SimpleNotificationService-010a507c1833636cd94bdb98bd93083a.pem', 'UnsubscribeUrl': 'https://sns.us-east-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic:cbdfec04-7502-4509-9954-435e1ddc5e3c', 'MessageAttributes': {}}}]}

st1 = st['Records'][0]['Sns']['Message']

print(st1)

st2= json.loads(st1)
print(st2["About this Event"])
#data1 = json.loads(st)

a = {'Records': [{'EventSource': 'aws:sns', 'EventVersion': '1.0', 'EventSubscriptionArn': 'arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic:cbdfec04-7502-4509-9954-435e1ddc5e3c', 'Sns': {'Type': 'Notification', 'MessageId': 'cb78fff8-c490-5e5c-af4e-a711a1ec1b4d', 'TopicArn': 'arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic', 'Subject': '[Amazon Redshift INFO] - Test Topic', 'Message': 'Successfully sent a test message to topic arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic', 'Timestamp': '2021-04-08T20:10:36.874Z', 'SignatureVersion': '1', 'Signature': 'vgunP5vUu/x2Oz95sEF/kT6Lvnlxtk6zSoHQtCswMEC1TX06O6OghHRWP234F9t23M4eRcb6tb+/TNToDjpX/Z4N1h8oO9Mwzd6IGjpjs4VF0cZiuY8p1vF5KWXu7C5oEd3gLk2BrGVCV97b3GkDYOkkGFmauh8JfnEjT5LgpEHqedMR7NhEz+1JLiTKB/8g+FwINCk9WkY3RNCUabYviwhvPgsvrfDxHQ4cEmy1kzT3GEm0Kk0yA+WQr1YcwWsO2/+/76VX58o+w/v6SdeXWI3gxaYIv1Dw6/7TUNuvXCr//VuvSyyI/Ky0A0zBeh8H3MseX9ho5eyBXYfL/VVQGg==', 'SigningCertUrl': 'https://sns.us-east-2.amazonaws.com/SimpleNotificationService-010a507c1833636cd94bdb98bd93083a.pem', 'UnsubscribeUrl': 'https://sns.us-east-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic:cbdfec04-7502-4509-9954-435e1ddc5e3c', 'MessageAttributes': {}}}]}

b = a['Records'][0]['Sns']['Message']

print(b)
# c = json.loads(b)
# print(c["About this Event"])




