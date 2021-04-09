import json
st = """
{
   "Records":[
      {
         "EventSource":"aws:sns",
         "EventVersion":"1.0",
         "EventSubscriptionArn":"arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic:cbdfec04-7502-4509-9954-435e1ddc5e3c",
         "Sns":{
            "Type":"Notification",
            "MessageId":"cb78fff8-c490-5e5c-af4e-a711a1ec1b4d",
            "TopicArn":"arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic",
            "Subject":"[Amazon Redshift INFO] - Test Topic",
            "Message":"Successfully sent a test message to topic arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic",
            "Timestamp":"2021-04-08T20:10:36.874Z",
            "SignatureVersion":"1",
            "Signature":"vgunP5vUu/x2Oz95sEF/kT6Lvnlxtk6zSoHQtCswMEC1TX06O6OghHRWP234F9t23M4eRcb6tb+/TNToDjpX/Z4N1h8oO9Mwzd6IGjpjs4VF0cZiuY8p1vF5KWXu7C5oEd3gLk2BrGVCV97b3GkDYOkkGFmauh8JfnEjT5LgpEHqedMR7NhEz+1JLiTKB/8g+FwINCk9WkY3RNCUabYviwhvPgsvrfDxHQ4cEmy1kzT3GEm0Kk0yA+WQr1YcwWsO2/+/76VX58o+w/v6SdeXWI3gxaYIv1Dw6/7TUNuvXCr//VuvSyyI/Ky0A0zBeh8H3MseX9ho5eyBXYfL/VVQGg==",
            "SigningCertUrl":"https://sns.us-east-2.amazonaws.com/SimpleNotificationService-010a507c1833636cd94bdb98bd93083a.pem",
            "UnsubscribeUrl":"https://sns.us-east-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-2:427128480243:terraform-redshift-sns-topic:cbdfec04-7502-4509-9954-435e1ddc5e3c",
            "MessageAttributes":{
               
            }
         }
      }
   ]
}
   """
valid_json = "[" + st + "]"
data = json.loads(st)
print(type(data))
print(data)