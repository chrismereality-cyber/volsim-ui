#!/bin/bash

echo "🚀 Starting full deployment (Preview + Production)..."

# 1. Commit changes
git add .
git commit -m "Auto-deploy (Preview + Production): $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || \
echo "ℹ️ No changes to commit."

# 2. Push updates to GitHub
git push origin main

############################################
# PREVIEW DEPLOYMENT
############################################
echo "🔄 Deploying Preview environment..."
vercel --prebuilt --confirm > vercel_preview_output.txt

preview_url=$(grep -o 'https://[a-zA-Z0-9.-]*\.vercel\.app' vercel_preview_output.txt | head -n 1)

############################################
# PRODUCTION DEPLOYMENT
############################################
echo "🌍 Deploying Production environment..."
vercel --prod --prebuilt --confirm > vercel_prod_output.txt

prod_url=$(grep -o 'https://[a-zA-Z0-9.-]*\.vercel\.app' vercel_prod_output.txt | head -n 1)

############################################
# OUTPUT RESULTS
############################################

echo ""
echo "===================================="
echo "✅ DEPLOYMENT COMPLETE"
echo "===================================="
echo ""
echo "🔎 Preview URL (Test Build):"
echo "$preview_url"
echo ""
echo "🌍 Production URL (Live Public):"
echo "$prod_url"
echo ""
echo "===================================="
echo "Copy the URLs above to test and share."
echo "===================================="
echo ""
