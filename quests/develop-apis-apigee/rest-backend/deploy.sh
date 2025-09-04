# retrieve GOOGLE_PROJECT_ID and CLOUDRUN_REGION
MYDIR="$(dirname "$0")"
source "${MYDIR}/config.sh"

if [[ -z "${GOOGLE_PROJECT_ID}" ]]; then
  echo "*** GOOGLE_PROJECT_ID not set ***"
  exit 1
fi

if [[ -z "${CLOUDRUN_REGION}" ]]; then
  echo "*** CLOUDRUN_REGION not set ***"
  exit 1
fi

SERVICE_NAME="simplebank-rest"
SVCACCT_NAME="simplebank-rest"
SVCACCT_EMAIL="${SVCACCT_NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com"
ARTIFACT_REGISTRY_REGION="${CLOUDRUN_REGION}"

# build image from code
echo "*** submit build of service ${SERVICE_NAME} to Cloud Build ***"
gcloud builds submit --tag ${ARTIFACT_REGISTRY_REGION}-docker.pkg.dev/${GOOGLE_PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME} \
  --project=${GOOGLE_PROJECT_ID}

# deploy service
# NOTE: in a production environment, you would not use max-instances=1
echo "*** deploy ${SERVICE_NAME} service to ${CLOUDRUN_REGION} with service account ${SVCACCT_EMAIL} ***"
gcloud run deploy ${SERVICE_NAME} \
  --image=${ARTIFACT_REGISTRY_REGION}-docker.pkg.dev/${GOOGLE_PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME} \
  --platform=managed \
  --max-instances=1 \
  --region=${CLOUDRUN_REGION} \
  --no-allow-unauthenticated \
  --service-account=${SVCACCT_EMAIL} \
  --project=${GOOGLE_PROJECT_ID}
