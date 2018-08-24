#!/usr/bin/env python
import requests
import time

node="10.1.32.226"
user="susanthab"
passw="twister75"

content = [line.rstrip('\n') for line in open('course.txt')]
for course_id in content: 
    print("For course id %s: " % course_id)
    data = {'statement': 'update led set learningModel.configurations.courseMastery.PreAssessment.mastery = ''0'' WHERE id = "%s"' % (course_id)}
    response = requests.post('http://%s:8093/query/service' % node, auth=(user,passw), data = data)
    print ("Update [PreAssessment.mastery] to 0. : %s" % (response))

    data = {'statement': 'update led set learningModel.configurations.courseMastery.Practice.mastery = ''0'' WHERE id = "%s"' % (course_id)}
    response = requests.post('http://%s:8093/query/service' % node, auth=(user,passw), data = data)
    print ("Update [Practice.mastery] to 0. : %s" % (response))

    data = {'statement': 'update led set learningModel.configurations.courseMastery.PostAssessment.mastery = ''0'' WHERE id = "%s"' % (course_id)}
    response = requests.post('http://%s:8093/query/service' % node, auth=(user,passw), data = data)
    print ("Update [PostAssessment.mastery] to 0. : %s" % (response))    
  
    print("") 
    time.sleep(2)