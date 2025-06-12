VERSION=1.3.1
curl -L -H "Authorization: Bearer $ARTIFACTORY_TOKEN" -o /tmp/advisor-cli.tar -X GET https://packages.broadcom.com/artifactory/spring-enterprise/com/vmware/tanzu/spring/application-advisor-cli-linux/$VERSION/application-advisor-cli-linux-$VERSION.tar
tar -xf /tmp/advisor-cli.tar --strip-components=1 -C /tmp
install /tmp/advisor /usr/local/bin/advisor

java --version
echo $JAVA_HOME
advisor --version

advisor build-config get

file=$(ls *.log 2>/dev/null | head -n1) && [ -n "$file" ] && cat "$file"

advisor build-config publish
advisor upgrade-plan get
advisor upgrade-plan apply
