# AWS S3 Integration Requirements

## Approach Recommendation: **Presigned URLs** ✅
This is the most secure approach for mobile apps:
1. Backend generates presigned URL
2. Flutter app uploads directly to S3 using presigned URL
3. Backend validates and processes after upload

## Required Information

### 1. AWS S3 Configuration
- [ ] **S3 Bucket Name**: `_________________`
- [ ] **AWS Region**: `_________________` (e.g., `us-east-1`, `ap-south-1`)
- [ ] **Bucket Base URL/Endpoint**: (optional, if different from standard)
- [ ] **File Path Structure**:
  - Profile pictures: `{user_id}/{filename}` inside profile
  - Degree certificates: `/{user_id}/{filename}` create new folder and put it inside them

### 2. Backend API Endpoints
- [ ] **Get Presigned URL Endpoint**: `POST /api/v1/upload/presigned-url`
  - Request body: `{ "file_type": "profile_picture" | "degree_certificate", "file_name": "image.jpg", "content_type": "image/jpeg" }`
  - Response format: `{
    "data": {
        "url": "https://flyapp-prod.s3.ap-south-1.amazonaws.com/user/profile-pics/image_test_kelrala.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZ2TRRZHJZGQYHBHX%2F20251122%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20251122T070555Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&x-id=PutObject&X-Amz-Signature=5e08d4e7cf5198960482da3e53a66c56b563624688cada673814aee980182c0d",
        "type": "image/png",
        "path": "/user/profile-pics/image_test_kelrala.png"
    },
    "msg": "success"
}`

  Error REsponse: {
    "msg": {
        "error": "unknown file type"
    }
}
- [ ] **Confirm Upload Endpoint** (optional): `POST /api/v1/upload/confirm`
  - After successful upload, confirm with backend

### 3. Security & Access
- [ ] **Authentication**: Do presigned URLs require authentication token in header?
- [ ] **URL Expiration**: How long are presigned URLs valid? (e.g., 15 minutes, 1 hour)
- [ ] **File Size Limits**:
  - Profile pictures: `_________________ MB`
  - Degree certificates: `_________________ MB`
- [ ] **Allowed File Types**:
  - Profile pictures: `jpg, jpeg, png` (or others?)
  - Degree certificates: `pdf, doc, docx, jpg, jpeg, png` (or others?)

### 4. CORS Configuration
- [ ] Is CORS already configured for your S3 bucket?
- [ ] Allowed origins: `*` or specific domains?

### 5. Implementation Preferences
- [ ] **Upload Progress**: Do you want upload progress indicators?
- [ ] **Error Handling**: Should failed uploads be retried automatically?
- [ ] **Compression**: Should images be compressed before upload?
- [ ] **Image Resizing**: Should profile pictures be resized to specific dimensions? (e.g., 500x500)

### 6. Alternative: Direct S3 Upload (Less Secure)
If you prefer direct upload without presigned URLs:
- [ ] AWS Access Key ID
- [ ] AWS Secret Access Key
- ⚠️ **Warning**: This approach is less secure as credentials may be exposed

### 7. Alternative: Backend Proxy Upload (Most Secure)
If you want to upload through your backend:
- [ ] Upload endpoint: `POST /api/v1/upload/file`
- [ ] Request format: Multipart form data
- [ ] Response format: `{ "file_path": "/images/...", "file_url": "https://..." }`

## Questions to Clarify

1. Do you have a backend API endpoint for generating presigned URLs?
2. What's your preferred file naming convention? (UUID, timestamp-based, original name?)
3. Should files be publicly accessible or private with signed URLs?
4. Do you want to store file metadata (size, type, upload date) in your database?

## Next Steps

Once you provide the required information, I will:
1. Install necessary packages (`dio` for uploads, `http` for multipart)
2. Create S3 upload service
3. Integrate with profile creation flow
4. Add progress indicators and error handling
5. Update controller to handle S3 uploads before profile creation

