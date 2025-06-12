#!/bin/bash

set -e

# Input parameters
ARTIFACTORY_TOKEN="$1"
GIT_TOKEN="$2"
SOURCE_PATH="$4"
CREATE_PR="$5"
PR_TITLE="$6"
PR_BODY="$7"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate inputs
if [ -z "$ARTIFACTORY_TOKEN" ]; then
    log_error "Artifactory token is required"
    exit 1
fi

if [ -z "$GIT_TOKEN" ]; then
    log_error "Git token is required"
    exit 1
fi

log_info "Starting Spring Application Advisor Action..."

# Download and install Spring Application Advisor CLI
install_advisor() {
    log_info "Installing Spring Application Advisor CLI..."
    
    # Create temporary directory for download
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download the advisor CLI (You'll need to replace this URL with the actual Broadcom download URL)
    # This is a placeholder - you need to get the actual download URL from Broadcom/VMware
    VERSION=1.3.1
    ADVISOR_DOWNLOAD_URL="https://packages.broadcom.com/artifactory/spring-enterprise/com/vmware/tanzu/spring/application-advisor-cli-linux/$VERSION/application-advisor-cli-linux-$VERSION.tar"
    
    # Download with authentication
    curl -L -H "Authorization: Bearer $ARTIFACTORY_TOKEN" \
         -o /tmp/advisor-cli.tar \
         "$ADVISOR_DOWNLOAD_URL" || {
        log_error "Failed to download Spring Application Advisor CLI"
        log_error "Please check your artifactory token and download URL"
        exit 1
    }
    
    # Extract and install
    tar -xf /tmp/advisor-cli.tar --strip-components=1 -C /tmp
    
    # Move to /usr/local/bin or appropriate location
    if [ -f advisor ]; then
        mv advisor /usr/local/bin/
        chmod +x /usr/local/bin/advisor
    else
        log_error "Advisor binary not found in downloaded package"
        exit 1
    fi
    
    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
    
    log_success "Spring Application Advisor CLI installed successfully"
}

# Function to run advisor commands
run_advisor() {
    local project_path="$1"
    
    log_info "Running Spring Application Advisor on project: $project_path"
    
    cd "$project_path"
    
    # Generate build configuration
    log_info "Generating build configuration..."
    advisor build-config get -p . || {
        log_error "Failed to generate build configuration"
        exit 1
    }
    log_success "Build configuration generated"
    
    # Get upgrade plan
    log_info "Getting upgrade plan..."
    advisor upgrade-plan get -p . || {
        log_error "Failed to get upgrade plan"
        exit 1
    }
    log_success "Upgrade plan retrieved"
    
    # Apply upgrade plan
    log_info "Applying upgrade plan..."
    advisor upgrade-plan apply -p . || {
        log_error "Failed to apply upgrade plan"
        exit 1
    }
    log_success "Upgrade plan applied"
    
    # Check if there are any changes
    if git diff --quiet; then
        log_info "No changes detected after upgrade"
        echo "upgrade_status=no_changes" >> $GITHUB_OUTPUT
        return 0
    else
        log_success "Changes detected after upgrade"
        echo "upgrade_status=changes_applied" >> $GITHUB_OUTPUT
    fi
}

# Function to create pull request
create_pull_request() {
    local title="$1"
    local body="$2"
    
    log_info "Creating pull request..."
    
    # Configure git
    git config --global user.name "Spring Application Advisor Action"
    git config --global user.email "action@github.com"
    
    # Create a new branch
    BRANCH_NAME="spring-advisor-upgrade-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$BRANCH_NAME"
    
    # Add and commit changes
    git add .
    git commit -m "chore: Spring Application Advisor dependency upgrades"
    
    # Push branch
    git push -u origin "$BRANCH_NAME"
    
    # Create PR using GitHub API
    PR_RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GIT_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls" \
        -d "{
            \"title\": \"$title\",
            \"body\": \"$body\",
            \"head\": \"$BRANCH_NAME\",
            \"base\": \"$GITHUB_REF_NAME\"
        }")
    
    PR_NUMBER=$(echo "$PR_RESPONSE" | jq -r '.number')
    
    if [ "$PR_NUMBER" != "null" ] && [ -n "$PR_NUMBER" ]; then
        log_success "Pull request created successfully: #$PR_NUMBER"
        echo "pr_number=$PR_NUMBER" >> $GITHUB_OUTPUT
    else
        log_error "Failed to create pull request"
        log_error "Response: $PR_RESPONSE"
        exit 1
    fi
}

# Main execution
main() {
    # Install the advisor CLI
    install_advisor
    
    # Change to the source directory
    cd "$GITHUB_WORKSPACE/$SOURCE_PATH"
    
    # Run the advisor
    run_advisor "."
    
    # Create pull request if requested and changes exist
    if [ "$CREATE_PR" = "true" ] && ! git diff --quiet; then
        create_pull_request "$PR_TITLE" "$PR_BODY"
    elif [ "$CREATE_PR" = "true" ]; then
        log_info "No changes to create PR for"
    fi
    
    log_success "Spring Application Advisor Action completed successfully"
}

# Run main function
main
