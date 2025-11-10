# API 设计文档

## 已实现接口

## 1. 用户注册

**路由**：`/auth/register`
**方法**：`POST`

**请求头**：
```
Content-Type: application/json
```

**请求体**：
```json
{
  "username": "cosmo_user",
  "password": "securepass"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| username | string | 5-50字符，[A-Za-z0-9_] |
| password | string | 最少6字符 |

**响应**（200 OK）：
```json
{
  "message": "Register successful",
  "userId": 202500001,
  "insertId": 1
}
```

**错误响应**：
- 400: `{ "error": "Username already exists" }`
- 400: `{ "error": "Username or ID already exists" }`
- 400: `{ "errors": [...] }`
- 500: `{ "error": "Server error" }`

---

## 2. 用户登录

**路由**：`/auth/login`  
**方法**：`POST`

**请求头**：
```
Content-Type: application/json
```

**请求体**：
```json
{
  "username": "cosmo_user",
  "password": "securepass"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| username | string | 用户名 |
| password | string | 密码 |

**响应**（200 OK）：
```json
{
  "message": "Login successful",
  "token": "eyJhbGc...",
  "user": {
    "userId": 202500001,
    "username": "cosmo_user",
    "province": "北京",
    "schoolId": 123
  }
}
```

**错误响应**：
- 400: `{ "error": "User not found" }`
- 400: `{ "error": "Incorrect password" }`
- 403: `{ "error": "Account disabled" }`
- 500: `{ "error": "Server error" }`

---

## 3. 获取院校列表

**路由**：`/colleges`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| page | number | 页码，默认1 |
| pageSize | number | 每页数量，最大200，默认20 |
| province | string | 省份过滤 |
| level | string | 院校等级过滤 |
| q | string | 搜索关键词 |

**响应**（200 OK）：
```json
{
  "data": [
    {
      "COLLEGE_ID": 1,
      "COLLEGE_CODE": "10001",
      "COLLEGE_NAME": "北京大学",
      "COLLEGE_LEVEL": "985",
      "PROVINCE": "北京",
      "CITY_NAME": "北京",
      "COLLEGE_TYPE": "综合",
      "WEBSITE": "https://www.pku.edu.cn/"
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 20
  }
}
```

**错误响应**：
- 500: `{ "error": "Server error" }`

---

## 4. 获取院校详情

**路由**：`/colleges/:collegeId`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| collegeId | number | 院校ID（路径参数） |

**响应**（200 OK）：
```json
{
  "data": {
    "COLLEGE_ID": 1,
    "COLLEGE_CODE": "10001",
    "COLLEGE_NAME": "北京大学",
    "COLLEGE_LEVEL": "985",
    "PROVINCE": "北京",
    "CITY_NAME": "北京",
    "COLLEGE_TYPE": "综合",
    "WEBSITE": "https://www.pku.edu.cn/",
    "BASE_INTRO": "详细介绍..."
  }
}
```

**错误响应**：
- 404: `{ "error": "College not found" }`
- 500: `{ "error": "Server error" }`

---

## 5. 获取院校录取分数线

**路由**：`/colleges/:collegeId/admissions`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| collegeId | number | 院校ID（路径参数） |
| province | string | 省份过滤 |
| year | number | 年份过滤 |

**响应**（200 OK）：
```json
{
  "data": [
    {
      "ADMISSION_ID": 1,
      "MAJOR_ID": 1,
      "PROVINCE": "北京",
      "ADMISSION_YEAR": 2024,
      "MIN_SCORE": 678.5,
      "MIN_RANK": 12,
      "ENROLLMENT_COUNT": 30
    }
  ]
}
```

**错误响应**：
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---

## 6. 获取专业列表

**路由**：`/majors`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| page | number | 页码，默认1 |
| pageSize | number | 每页数量，最大200，默认30 |
| q | string | 搜索关键词 |

**响应**（200 OK）：
```json
{
  "data": [
    {
      "MAJOR_ID": 1,
      "MAJOR_CODE": "M1001",
      "MAJOR_NAME": "计算机科学与技术",
      "MAJOR_TYPE": "理工",
      "BASE_INTRO": "专业介绍..."
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 30,
    "q": "计算机"
  }
}
```

**错误响应**：
- 500: `{ "error": "Server error", "detail": "..." }`

---

## 7. 获取专业详情

**路由**：`/majors/:majorId`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| majorId | number | 专业ID（路径参数） |

**响应**（200 OK）：
```json
{
  "data": {
    "MAJOR_ID": 1,
    "MAJOR_CODE": "M1001",
    "MAJOR_NAME": "计算机科学与技术",
    "MAJOR_TYPE": "理工",
    "BASE_INTRO": "详细介绍..."
  }
}
```

**错误响应**：
- 404: `{ "error": "Major not found" }`
- 500: `{ "error": "Server error", "detail": "..." }`

---

## 8. 获取招生计划列表

**路由**：`/plans`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| collegeId | number | 院校ID过滤 |
| majorId | number | 专业ID过滤 |
| year | number | 招生年份过滤 |

**响应**（200 OK）：
```json
{
  "data": [
    {
      "PLAN_ID": 1,
      "COLLEGE_ID": 1,
      "MAJOR_ID": 1,
      "PROVINCE": "北京",
      "ADMISSION_YEAR": 2025,
      "PLAN_COUNT": 30,
      "DESCRIPTION": "2025年本科普通批次计划"
    }
  ]
}
```

**错误响应**：
- 500: `{ "error": "Server error" }`

---

## 9. 创建招生计划

**路由**：`/plans`  
**方法**：`POST`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求体**：
```json
{
  "collegeId": 1,
  "majorId": 1,
  "admissionYear": 2025,
  "planCount": 30,
  "description": "2025年招生计划"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| collegeId | number | 院校ID |
| majorId | number | 专业ID |
| admissionYear | number | 招生年份 |
| planCount | number | 招生人数 |
| description | string | 计划说明 |

**响应**（200 OK）：
```json
{
  "message": "Plan created",
  "insertId": 5
}
```

**错误响应**：
- 400: `{ "errors": [...] }`
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---

## 10. 获取高中升学记录

**路由**：`/school-enrollment`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| schoolId | number | 高中ID（必填） |
| graduationYear | number | 毕业年份过滤 |

**响应**（200 OK）：
```json
{
  "data": [
    {
      "SCHOOL_ENROLLMENT_ID": 1,
      "COLLEGE_ID": 1,
      "GRADUATION_YEAR": 2024,
      "MAJOR_ID": 1,
      "ADMISSION_COUNT": 3,
      "AVG_SCORE": 695.5,
      "MIN_RANK": 1
    }
  ]
}
```

**错误响应**：
- 400: `{ "error": "schoolId required" }`
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---

## 11. 提交学生成绩

**路由**：`/student-score`  
**方法**：`POST`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求体**：
```json
{
  "studentId": 202500001,
  "examYear": 2025,
  "province": "北京",
  "totalScore": 682.5,
  "rankInProvince": 7
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| studentId | number | 考生ID |
| examYear | number | 高考年份 |
| province | string | 考生所在省份 |
| totalScore | number | 高考总成绩 |
| rankInProvince | number | 省内排名 |

**响应**（200 OK）：
```json
{
  "message": "Score submitted",
  "insertId": 3
}
```

**错误响应**：
- 400: `{ "errors": [...] }`
- 403: `{ "error": "Cannot submit score for other user" }`
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---

## 12. 获取当前用户最近成绩

**路由**：`/student-score/mine`  
**方法**：`GET`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**：无

**响应**（200 OK）：
```json
{
  "data": [
    {
      "SCORE_ID": 1,
      "STUDENT_ID": 202500001,
      "EXAM_YEAR": 2025,
      "PROVINCE": "北京",
      "TOTAL_SCORE": 682.5,
      "RANK_IN_PROVINCE": 7,
      "CREATED_AT": "2025-11-05 10:30:00"
    }
  ]
}
```

**错误响应**：
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---

## 新增接口

## 1. 更新用户信息

**路由**：`/user/profile`  
**方法**：`POST`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求体**：
```json
{
  "username": "新用户名",
  "province": "浙江省",
  "schoolId": 123
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| username | string | 用户昵称，5-50字符，[A-Za-z0-9_] |
| province | string | 所在省份，1-64字符 |
| schoolId | number | 毕业高中ID，正整数 |

**响应**（200 OK）：
```json
{
  "message": "Profile updated successfully",
  "user": {
    "userId": 202500001,
    "username": "新用户名",
    "province": "浙江省",
    "schoolId": 123
  }
}
```

**错误响应**：
- 400: `{ "errors": [...] }` （参数验证失败）
- 400: `{ "error": "No fields to update" }` （未提供任何字段）
- 400: `{ "error": "Username already exists" }` （用户名已存在）
- 404: `{ "error": "User not found" }` （用户不存在）
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---

## 2. 获取推荐院校列表

**路由**：`/recommend`  
**方法**：`POST`

**请求头**：
```
Content-Type: application/json
Authorization: Bearer <token>
```

**请求体**：
```json
{
  "province": "浙江省",
  "majorIds": [1, 2, 3],
  "page": 1,
  "pageSize": 20
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| province | string | （可选）意向省份，1-64字符 |
| majorIds | array | （可选）意向专业ID列表，正整数数组 |
| page | number | （可选）页码，默认1 |
| pageSize | number | （可选）每页数量，1-200范围，默认20 |

**说明**：考生成绩自动从后端数据库获取，使用用户最新提交的成绩记录。

**响应**（200 OK）：
```json
{
  "data": [
    {
      "collegeId": 1,
      "collegeName": "浙江大学",
      "collegeCode": "10335",
      "province": "浙江",
      "collegeLevel": "985",
      "minScore": 675,
      "matchDegree": 95,
      "risk": "low",
      "admissionYear": 2024
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "total": 50
  }
}
```

**错误响应**：
- 400: `{ "errors": [...] }` （参数验证失败）
- 400: `{ "error": "No score found", "message": "您还未上传成绩，请先提交成绩后再获取推荐" }` （未找到成绩）
- 401: `{ "error": "No authorization header" }`
- 401: `{ "error": "Invalid authorization format" }`
- 401: `{ "error": "Invalid or expired token" }`
- 500: `{ "error": "Server error" }`

---


