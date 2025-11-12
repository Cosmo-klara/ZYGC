### 接口文档

- 非本地部署测试

https://marlyn-unalleviative-annabel.ngrok-free.dev 替换 http://localhost:3000

#### 开发用测试接口

返回数据库大体结构和3条示例数据

GET

https://marlyn-unalleviative-annabel.ngrok-free.dev/dev-samples

https://marlyn-unalleviative-annabel.ngrok-free.dev/dev


#### 注册

post

http://localhost:3000/auth/register

- 请求体

```json
{
    "username":"cosmo",
    "password":"111111",
    "province":"北京",
    "schoolName":"某市第一中学"
}
```

- Json 响应

```json
{
  "message": "Register successful",
  "userId": 2025822689
}
```

#### 登录

post

http://localhost:3000/auth/login

- 请求体

```json
{
  "username": "cosmo",
  "password": "111111"
}
```
- Json 响应

```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwMjU4MjI2ODksInVzZXJuYW1lIjoiY29zbW8iLCJwcm92aW5jZSI6IuWMl-S6rCIsInNjaG9vbE5hbWUiOiLmn5DluILnrKzkuIDkuK3lraYiLCJpYXQiOjE3NjI3Njc2MTQsImV4cCI6MTc2MzM3MjQxNH0.KK7_rKfEL8BvkS6Gixuk9Cyw5KlXnajPhaK9ZIvXJ6w",
  "user": {
    "userId": 2025822689,
    "username": "cosmo",
    "province": "北京",
    "schoolName": "某市第一中学"
  }
}
```

#### 院校查询-分页

GET

http://localhost:3000/colleges?page=1&pageSize=3

- Json 响应

```json
{
  "data": [
    {
      "COLLEGE_CODE": 10001,
      "COLLEGE_NAME": "北京大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "北京",
      "CITY_NAME": "北京市"
    },
    {
      "COLLEGE_CODE": 10002,
      "COLLEGE_NAME": "中国人民大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "北京",
      "CITY_NAME": "北京市"
    },
    {
      "COLLEGE_CODE": 10003,
      "COLLEGE_NAME": "清华大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "北京",
      "CITY_NAME": "北京市"
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 3,
    "total": 136,
    "totalPages": 46,
    "hasNext": true
  }
}
```


#### 院校查询-筛选

GET

http://localhost:3000/colleges?province=上海&is985=1&page=1&pageSize=5

- Json 响应

```json
{
  "data": [
    {
      "COLLEGE_CODE": 10246,
      "COLLEGE_NAME": "复旦大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "上海",
      "CITY_NAME": "上海市"
    },
    {
      "COLLEGE_CODE": 10247,
      "COLLEGE_NAME": "同济大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "上海",
      "CITY_NAME": "上海市"
    },
    {
      "COLLEGE_CODE": 10248,
      "COLLEGE_NAME": "上海交通大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "上海",
      "CITY_NAME": "上海市"
    },
    {
      "COLLEGE_CODE": 10269,
      "COLLEGE_NAME": "华东师范大学",
      "IS_985": 1,
      "IS_211": 1,
      "IS_DFC": 1,
      "PROVINCE": "上海",
      "CITY_NAME": "上海市"
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 5,
    "total": 4,
    "totalPages": 1,
    "hasNext": false
  }
}
```

#### 院校历年录取

GET

http://localhost:3000/colleges/10001/admissions?province=北京&year=2018

```json
{
  "data": [
    {
      "ADMISSION_ID": 779234,
      "MAJOR_NAME": "工商管理类(含金融学、经济学(金融)、会计学、市场营销)",
      "TYPE": "理科",
      "PROVINCE": "北京",
      "ADMISSION_YEAR": 2018,
      "MIN_SCORE": "695",
      "MIN_RANK": 106
    },
    {
      "ADMISSION_ID": 779235,
      "MAJOR_NAME": "环境科学(环境、生态、地理与资源环境)",
      "TYPE": "理科",
      "PROVINCE": "北京",
      "ADMISSION_YEAR": 2018,
      "MIN_SCORE": "692",
      "MIN_RANK": 148
    },
    {
      "ADMISSION_ID": 779236,
      "MAJOR_NAME": "生物科学类(含生物科学、生物技术)",
      "TYPE": "理科",
      "PROVINCE": "北京",
      "ADMISSION_YEAR": 2018,
      "MIN_SCORE": "689",
      "MIN_RANK": 215
    },
    // ... 有点长，省略一下
  ]
}

```