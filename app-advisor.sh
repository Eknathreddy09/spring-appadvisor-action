VERSION=1.3.1
curl -L -H "Authorization: Bearer $ARTIFACTORY_TOKEN" -o /tmp/advisor-cli.tar -X GET https://packages.broadcom.com/artifactory/spring-enterprise/com/vmware/tanzu/spring/application-advisor-cli-linux/$VERSION/application-advisor-cli-linux-$VERSION.tar
tar -xf /tmp/advisor-cli.tar --strip-components=1 -C /tmp
install /tmp/advisor /usr/local/bin/advisor

cat > /home/runner/.m2/settings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>spring-enterprise-subscription</id>
      <username>eknath.reddy@broadcom.com</username>
      <password>${ARTIFACTORY_TOKEN}</password>
    </server>
  </servers>
  <profiles>
    <profile>
      <id>spring-enterprise</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <repositories>
        <repository>
          <id>spring-enterprise-subscription</id>
          <url>https://packages.broadcom.com/artifactory/spring-enterprise</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>spring-enterprise-subscription</id>
          <url>https://packages.broadcom.com/artifactory/spring-enterprise</url>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>spring-enterprise</activeProfile>
  </activeProfiles>

</settings>
EOF

java --version
echo $JAVA_HOME
advisor --version

advisor build-config get

cat ".advisor/errors/$(ls -t .advisor/errors | head -n1)"

advisor build-config publish
advisor upgrade-plan get
cat /home/runner/.m2/settings.xml
advisor upgrade-plan apply
