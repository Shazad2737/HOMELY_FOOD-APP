Notification API — concise details for frontend
Base path: /api/notification
Auth: protected — requires Authorization header and brand header (see notes).

Headers (required)

Authorization: Bearer <JWT token> — token from customer login
brand: <brand_code> — e.g., "mybrand" (case-insensitive)
Accept: application/json
Endpoints

Get notifications
Method: GET
Path: /api/notification
Query parameters:
type (optional, string) — filter by notification type
page (optional, integer) — default: 1
limit (optional, integer) — default: 20
Body: none
Success response: 200 OK
JSON shape:
{
"success": true,
"message": "Notification fetched successfully",
"data": {
"grouped": {
"today": [ {notificationObject}, ... ],
"yesterday": [...],
"this_week": [...],
"this_month": [...],
"older": [...]
},
"pagination": {
"page": <number>,
"limit": <number>,
"total": <number>,
"totalPages": <number>
}
}
}
notificationObject fields in each grouped array:
id (string or integer)
caption (string)
description (string|null)
imageUrl (string|null)
type (string)
priority (string or number)
actionUrl (string|null)
sentAt (string) — formatted date/time (server timezone applied)
timeAgo (string) — human-readable relative time
dayCategory (string) — one of today|yesterday|this_week|this_month|older
isRead (boolean)
readAt (string|null) — formatted read timestamp if read
Errors:
401 Unauthorized — missing/invalid/expired token or session
400 Bad Request — missing/invalid brand header
500 Internal Server Error — server errors
Mark all as read
Method: PATCH
Path: /api/notification/read-all
Query/body: none
Body: none
Success response: 200 OK
JSON shape:
{
"success": true,
"message": "All notifications marked as read",
"data": {
"count": <number> // number of notifications newly marked as read
}
}
Errors:
401 Unauthorized — missing/invalid/expired token or session
400 Bad Request — missing/invalid brand header
500 Internal Server Error
Notes / behavior

Routes are mounted under /api and protected by authCheck middleware: frontend must send a valid customer JWT and the brand header.
The server groups notifications by day category (today, yesterday, this_week, this_month, older) and returns formatted timestamps using the brand/country timezone.
The GET endpoint returns both broadcast notifications (customerId=null) and those targeted to the authenticated customer.
No payloads are required for these endpoints (queries only for GET).
Response envelope format: { success: true|false, message: string, data: any }.