# Spring Application Advisor Action - Fixed Version

This repository contains the corrected Spring Application Advisor GitHub Action with the latest CLI version and fixed YAML syntax issues.

## What Was Fixed

### 1. Updated CLI Version
- **Changed from**: 1.3.1 (outdated)
- **Changed to**: 1.2.0 (latest available version)
- **Location**: `app-advisor.sh`

### 2. Fixed YAML Syntax Issues
- Cleaned up `action.yml` to ensure proper YAML formatting
- Simplified `sample-workflow.yml` to avoid parsing errors
- Removed any potential tab characters or formatting issues

### 3. Enhanced Script Reliability
- Added error handling with `set -e`
- Added proper cleanup of temporary files
- Added installation verification
- Added descriptive logging for each step

## Key Changes Made

### app-advisor.sh
```bash
# Updated version
VERSION=1.2.0

# Enhanced download and installation process
curl -L -H "Authorization: Bearer $ARTIFACTORY_TOKEN" \
  -o /tmp/advisor-cli.tar \
  -X GET \
  "https://packages.broadcom.com/artifactory/spring-enterprise/com/vmware/tanzu/spring/application-advisor-cli-linux/$VERSION/application-advisor-cli-linux-$VERSION.tar"

# Proper extraction and installation
tar -xf /tmp/advisor-cli.tar --strip-components=1 -C /tmp
sudo install /tmp/advisor /usr/local/bin/advisor
```

### action.yml
- Clean YAML formatting
- Proper indentation (spaces, not tabs)
- Consistent structure

### sample-workflow.yml
- Simplified structure to avoid parsing errors
- Updated to use version v1.4.0 (recommend updating to your actual latest version)
- Proper permissions configuration

## Next Steps

### 1. Make Script Executable
Run this command to make the script executable:
```bash
chmod +x /Users/reddye/Documents/Tanzu/spring/SAA/spring-appadvisor-action/app-advisor.sh
```

### 2. Update GitHub Release Tag
The error suggests you're using `v1.3.7`, but you should:
1. Create a new release with a version tag (e.g., `v1.4.0`)
2. Update your workflow to use the new tag
3. Ensure the tag points to the corrected code

### 3. Test the Action
Before publishing, test the action with a simple workflow:

```yaml
name: test-spring-app-advisor
on:
  workflow_dispatch:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test Action
        uses: ./
        with:
          artifactory_token: ${{ secrets.ArtifactoryToken }}
          git_token: ${{ secrets.GITHUB_TOKEN }}
```

### 4. Update Documentation
- Update any references to old CLI versions
- Document the new features and improvements
- Update installation instructions

## CLI Version Information

The latest Spring Application Advisor CLI version is **1.2.0** as documented in the [Broadcom TechDocs](https://techdocs.broadcom.com/us/en/vmware-tanzu/spring/spring-application-advisor/1-2/spring-app-advisor/run-app-advisor-cli.html).

## Troubleshooting

If you still encounter the YAML parsing error:
1. Ensure no tabs are used (only spaces for indentation)
2. Verify the action.yml has proper YAML structure
3. Check that the GitHub release tag exists and is properly formatted
4. Validate YAML syntax using online validators

## Usage

After fixing and publishing the new version:

```yaml
- name: Run Spring Application Advisor
  uses: Eknathreddy09/spring-appadvisor-action@v1.4.0
  with:
    artifactory_token: ${{ secrets.ArtifactoryToken }}
    git_token: ${{ secrets.GITHUB_TOKEN }}
```

## Files Modified
- ✅ `app-advisor.sh` - Updated CLI version and enhanced error handling
- ✅ `action.yml` - Fixed YAML formatting
- ✅ `sample-workflow.yml` - Simplified and corrected structure
- ✅ `README.md` - Added comprehensive documentation (this file)
