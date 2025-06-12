#!/bin/bash

# Spring Application Advisor Action Release Script
# Usage: ./release.sh <version>
# Example: ./release.sh v1.4.0

set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "❌ Usage: $0 <version>"
    echo "   Example: $0 v1.4.0"
    exit 1
fi

# Validate version format
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Version must be in format vX.Y.Z (e.g., v1.4.0)"
    exit 1
fi

echo "🚀 Releasing Spring Application Advisor Action $VERSION"

# Check if we're in the right directory
if [ ! -f "action.yml" ]; then
    echo "❌ action.yml not found. Are you in the action directory?"
    exit 1
fi

# Check git status
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working directory not clean. Please commit your changes first."
    git status
    exit 1
fi

# Validate action.yml
echo "📋 Validating action.yml..."
if command -v yq &> /dev/null; then
    yq eval . action.yml > /dev/null
    echo "✅ action.yml is valid"
else
    echo "⚠️ yq not found, skipping action.yml validation"
fi

# Update README if needed
echo "📝 Checking README for version references..."
if grep -q "v1\.[0-9]\.[0-9]" README.md; then
    echo "⚠️ README contains version references. Consider updating them to $VERSION"
    grep -n "v1\.[0-9]\.[0-9]" README.md
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Run tests if available
if [ -f ".github/workflows/test.yml" ]; then
    echo "🧪 Note: Make sure tests pass before releasing"
    echo "   Run: gh workflow run test.yml"
fi

# Create and push tag
echo "🏷️ Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

echo "📤 Pushing tag..."
git push origin "$VERSION"

# Update major version tag (e.g., v1 for v1.4.0)
MAJOR_VERSION=$(echo "$VERSION" | cut -d. -f1)
echo "🏷️ Updating major version tag $MAJOR_VERSION..."
git tag -f "$MAJOR_VERSION" "$VERSION"
git push origin "$MAJOR_VERSION" --force

echo "✅ Release $VERSION completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Go to GitHub and create a release from the tag"
echo "2. Add release notes describing the changes"
echo "3. Optionally publish to GitHub Marketplace"
echo ""
echo "🔗 GitHub Release URL:"
echo "   https://github.com/eknathreddy09/spring-appadvisor-action/releases/new?tag=$VERSION"
echo ""
echo "📖 Example workflow usage:"
echo "   uses: eknathreddy09/spring-appadvisor-action@$VERSION"
echo "   uses: eknathreddy09/spring-appadvisor-action@$MAJOR_VERSION  # Latest $MAJOR_VERSION.x"
