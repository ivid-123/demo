oc new-project cicd --display-name="CI/CD"
oc project cicd
oc new-app jenkins-ephemeral 

oc new-project dev   --display-name="Dev"
oc new-project stage --display-name="Stage"
oc project cicd

oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n cicd
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n dev
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n stage

oc project cicd
oc create -f https://raw.githubusercontent.com/ivid-123/demo/master/openshift/jenkins-pipeline.yml


oc start-build ng-tomcat-app
