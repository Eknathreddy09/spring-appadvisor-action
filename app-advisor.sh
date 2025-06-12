#!/bin/bash
set -e

# Use the latest version available
VERSION=1.3.1

echo "Downloading Spring Application Advisor CLI version $VERSION..."

# Download the CLI
curl -L -H "Authorization: Bearer $ARTIFACTORY_TOKEN" \
  -o /tmp/advisor-cli.tar \
  -X GET \
  "https://packages.broadcom.com/artifactory/spring-enterprise/com/vmware/tanzu/spring/application-advisor-cli-linux/$VERSION/application-advisor-cli-linux-$VERSION.tar"

# Extract the CLI
tar -xf /tmp/advisor-cli.tar --strip-components=1 -C /tmp

# Install the CLI to a location in PATH
sudo install /tmp/advisor /usr/local/bin/advisor

# Clean up
rm -f /tmp/advisor-cli.tar

echo "Spring Application Advisor CLI installed successfully"

# Verify installation
advisor --version || echo "Advisor CLI installed"

echo "Running Spring Application Advisor..."

# Generate build configuration
echo "Generating build configuration..."
advisor build-config get

# Generate upgrade plan
echo "Generating upgrade plan..."
advisor upgrade-plan get

# Apply upgrade plan
echo "Applying upgrade plan..."
advisor upgrade-plan apply

echo "Spring Application Advisor completed successfully"
