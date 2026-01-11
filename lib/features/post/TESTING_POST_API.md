# Testing Post API Integration

This document outlines how to test the Post API integration.

## Prerequisites

1. Ensure the backend is running and accessible
2. Ensure you have a valid JWT token (user must be logged in)
3. The API base URL should be configured in `.env` file

## API Endpoints Tested

### 1. Create Post
- **Endpoint**: `POST /post/external/v1`
- **Auth**: Required (JWT token)
- **Description**: Creates a new post
- **Test Method**: Use `PostController.createPostEntry()`

```dart
final controller = Get.find<PostController>();
final success = await controller.createPostEntry(
  tagId: 1, // Required: tag ID
  content: 'Test post content',
  attachments: [
    Attachment(type: 'image', url: 'https://example.com/image.jpg'),
  ],
  // poll: Poll(...) // Optional
);
```

### 2. Get Posts by Author (Current User)
- **Endpoint**: `GET /post/external/v1/author/`
- **Auth**: Required (JWT token - author ID extracted from token)
- **Description**: Gets all posts by the authenticated user
- **Test Method**: Use `PostController.fetchMyPosts()`

```dart
final controller = Get.find<PostController>();
await controller.fetchMyPosts();
final posts = controller.posts.value;
```

### 3. Get Posts by Community
- **Endpoint**: `GET /post/external/v1/community/{communityId}`
- **Auth**: Required (JWT token)
- **Description**: Gets all posts in a specific community
- **Test Method**: Use `PostController.fetchPostsByCommunity()`

```dart
final controller = Get.find<PostController>();
await controller.fetchPostsByCommunity('community-uuid-here');
final posts = controller.posts.value;
```

### 4. Get Posts by Tag
- **Endpoint**: `GET /post/external/v1/tag/{tagId}`
- **Auth**: Required (JWT token)
- **Description**: Gets all posts with a specific tag
- **Test Method**: Use `PostController.fetchPostsByTag()`

```dart
final controller = Get.find<PostController>();
await controller.fetchPostsByTag(1); // tagId: 1
final posts = controller.posts.value;
```

### 5. Get Posts by IDs
- **Endpoint**: `POST /post/external/v1/ids`
- **Auth**: Required (JWT token)
- **Description**: Gets multiple posts by their IDs
- **Test Method**: Use `PostController.fetchPostsByIds()`

```dart
final controller = Get.find<PostController>();
await controller.fetchPostsByIds(['post-id-1', 'post-id-2']);
final posts = controller.posts.value;
```

### 6. Delete Post
- **Endpoint**: `DELETE /post/external/v1/{postId}`
- **Auth**: Required (JWT token)
- **Description**: Deletes a post by ID
- **Test Method**: Use `PostController.deletePostEntry()`

```dart
final controller = Get.find<PostController>();
final success = await controller.deletePostEntry('post-id-here');
```

## Testing Checklist

- [ ] Test create post with text content
- [ ] Test create post with image attachments
- [ ] Test create post with video attachments
- [ ] Test create post with poll
- [ ] Test get posts by author (verify JWT token extraction works)
- [ ] Test get posts by community
- [ ] Test get posts by tag
- [ ] Test get posts by IDs
- [ ] Test delete post
- [ ] Test error handling (invalid token, network errors, etc.)
- [ ] Test JSON parsing (verify all fields are parsed correctly)
- [ ] Test DateTime parsing (verify dates are parsed correctly from backend)

## Expected Response Formats

### Create Post Response
```json
{
  "msg": "Post created successfully",
  "data": "success"
}
```

### Get Posts Response
```json
{
  "msg": "Post fetched successfully",
  "data": [
    {
      "id": "post-uuid",
      "author_id": "author-uuid",
      "community_id": "community-uuid" (optional),
      "tag_id": 1,
      "content": "Post content",
      "attachments": [
        {
          "type": "image",
          "url": "https://example.com/image.jpg"
        }
      ],
      "poll": {
        "question": "Poll question?",
        "options": [
          {
            "option_id": "option-uuid",
            "text": "Option 1",
            "votes": ["user-uuid"]
          }
        ],
        "expires_at": "2024-01-01T00:00:00Z",
        "created_at": "2024-01-01T00:00:00Z"
      },
      "likes": ["user-uuid"],
      "like_count": 0,
      "comment_count": 0,
      "bookmarked_by": ["user-uuid"],
      "bookmark_count": 0,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## Common Issues

1. **JWT Token Missing**: Ensure user is logged in and token is stored
2. **Author ID Not Found**: The backend extracts author ID from JWT token - verify token is valid
3. **DateTime Parsing Errors**: The model handles various date formats, but verify backend returns ISO8601 format
4. **Tag ID Mismatch**: Verify tag IDs match between frontend TagMapping and backend

## Notes

- All post endpoints require JWT authentication
- The `getPostsByAuthorId` endpoint automatically extracts author ID from JWT token (x-fly-uuid header)
- DateTime fields are parsed flexibly to handle different formats
- The PostController manages loading states and error messages
