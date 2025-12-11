#!/bin/bash
set -e # Exit on error
# === CONFIGURATION ===
PROJECT_ID="quantum-resistant-bank" 
BUCKET_NAME="volsim_project_bucket_12345" APP_FOLDER="$(pwd)"
# === STEP 1: Detect build folder ===
echo "🔎 Detecting build folder..." if [ -d "$APP_FOLDER/build" ]; then 
    BUILD_FOLDER="$APP_FOLDER/build"
elif [ -d "$APP_FOLDER/dist" ]; then BUILD_FOLDER="$APP_FOLDER/dist" 
elif [ -d "$APP_FOLDER/out" ]; then
    BUILD_FOLDER="$APP_FOLDER/out" else echo "❌ ERROR: No build folder 
    found (build/, dist/, out/)" exit 1
fi echo "📁 Build folder detected: $BUILD_FOLDER"
# === STEP 2: Install dependencies & build app ===
echo "📦 Installing dependencies..." npm install echo "🚀 Building React 
app..." npm run build
# === STEP 3: Set GCP Project ===
echo "🔧 Setting project to: $PROJECT_ID" gcloud config set project 
"$PROJECT_ID"
# === STEP 4: Ensure bucket exists ===
echo "📂 Checking bucket..." if ! gsutil ls -b "gs://$BUCKET_NAME" 
>/dev/null 2>&1; then
    echo "🆕 Bucket not found. Creating: $BUCKET_NAME" gsutil mb -l 
    us-central1 "gs://$BUCKET_NAME"
else echo "✅ Bucket exists." fi
# === STEP 5: Grant permissions ===
echo "🔑 Granting storage admin permission..." gsutil iam ch 
"user:chrismereality@gmail.com:roles/storage.admin" "gs://$BUCKET_NAME"
# === STEP 6: Clean old bucket files ===
echo "🗑️ Cleaning old files..." gsutil -m rm -r "gs://$BUCKET_NAME/**" || 
true
# === STEP 7: Upload new build files safely ===
echo "📤 Uploading build files..." find "$BUILD_FOLDER" -type f -print0 
| while IFS= read -r -d '' file; do
    relative_path="${file#$BUILD_FOLDER/}" gsutil cp "$file" 
    "gs://$BUCKET_NAME/$relative_path"
done
# === STEP 8: Configure bucket as static website ===
echo "🌐 Configuring static website..." gsutil web set -m index.html -e 
index.html "gs://$BUCKET_NAME"
# === STEP 9: Make files publicly viewable ===
echo "👀 Making files public..." gsutil iam ch 
allUsers:roles/storage.objectViewer "gs://$BUCKET_NAME"
# === DONE ===
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "🌍 Your app is live at: https://storage.googleapis.com/$BUCKET_NAME/index.html"
