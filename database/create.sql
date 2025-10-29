SHOW DATABASES ;


CREATE DATABASE IF NOT EXISTS `Manager` DEFAULT CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_general_ci';
USE `Manager`;

-- 1) 院校信息表：college_info
DROP TABLE IF EXISTS `college_info`;
CREATE TABLE `college_info` (
                                `COLLEGE_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '院校ID，主键',
                                `COLLEGE_CODE` VARCHAR(50) NOT NULL COMMENT '院校编码（如：10001）',
                                `COLLEGE_NAME` VARCHAR(100) NOT NULL COMMENT '院校名称',
                                `COLLEGE_LEVEL` VARCHAR(20) NOT NULL COMMENT '院校等级（985、211、普通本科等）',
                                `PROVINCE` VARCHAR(64) NOT NULL COMMENT '所在省份',
                                `CITY_NAME` VARCHAR(50) DEFAULT NULL COMMENT '城市名称',
                                `COLLEGE_TYPE` VARCHAR(20) DEFAULT NULL COMMENT '院校类型（综合、理工等）',
                                `WEBSITE` VARCHAR(255) DEFAULT NULL COMMENT '学校网址',
                                `BASE_INTRO` TEXT DEFAULT NULL COMMENT '院校基础介绍',
                                PRIMARY KEY (`COLLEGE_ID`),
                                UNIQUE KEY `ux_college_code` (`COLLEGE_CODE`),
                                KEY `idx_college_province_level` (`PROVINCE`, `COLLEGE_LEVEL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='院校基础信息表';


INSERT INTO `college_info` (`COLLEGE_CODE`, `COLLEGE_NAME`, `COLLEGE_LEVEL`, `PROVINCE`, `CITY_NAME`, `COLLEGE_TYPE`, `WEBSITE`, `BASE_INTRO`)
VALUES
    ('10001','北京大学','985','北京','北京','综合','https://www.pku.edu.cn/','北京大学，简称北大，创建于1898年。'),
    ('10002','清华大学','985','北京','北京','理工','https://www.tsinghua.edu.cn/','清华大学，工科学术传统深厚。');


-- 2) 专业信息表：major_info

DROP TABLE IF EXISTS `major_info`;
CREATE TABLE `major_info` (
                              `MAJOR_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '专业ID，主键',
                              `MAJOR_CODE` VARCHAR(50) NOT NULL COMMENT '专业编码（如：10001）',
                              `MAJOR_NAME` VARCHAR(100) NOT NULL COMMENT '专业名称',
                              `MAJOR_TYPE` VARCHAR(20) DEFAULT NULL COMMENT '专业类型（综合、理工等）',
                              `BASE_INTRO` TEXT DEFAULT NULL COMMENT '专业基础介绍',
                              PRIMARY KEY (`MAJOR_ID`),
                              UNIQUE KEY `ux_major_code` (`MAJOR_CODE`),
                              KEY `idx_major_name` (`MAJOR_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='专业基础信息表';


INSERT INTO `major_info` (`MAJOR_CODE`, `MAJOR_NAME`, `MAJOR_TYPE`, `BASE_INTRO`)
VALUES
    ('M1001','计算机科学与技术','理工','计算机科学与技术专业，包含算法、系统、AI等方向。'),
    ('M1002','软件工程','理工','侧重软件开发生命周期、工程化实践。');


-- 3) 历年录取分数线表：college_admission_score
--    （维护各院校各专业历年录取分数）
DROP TABLE IF EXISTS `college_admission_score`;
CREATE TABLE `college_admission_score` (
                                           `ADMISSION_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '录取分数线ID，主键',
                                           `COLLEGE_ID` BIGINT NOT NULL COMMENT '关联 college_info.COLLEGE_ID',
                                           `MAJOR_ID` BIGINT DEFAULT NULL COMMENT '关联 major_info.MAJOR_ID',
                                           `PROVINCE` VARCHAR(64) NOT NULL COMMENT '录取省份',
                                           `ADMISSION_YEAR` YEAR NOT NULL COMMENT '录取年份',
                                           `MIN_SCORE` DECIMAL(5,1) NOT NULL COMMENT '最低分',
                                           `MIN_RANK` INT NOT NULL COMMENT '最低位次',
                                           `ENROLLMENT_COUNT` INT DEFAULT NULL COMMENT '录取人数',
                                           PRIMARY KEY (`ADMISSION_ID`),
                                           KEY `idx_adm_college_year` (`COLLEGE_ID`, `ADMISSION_YEAR`),
                                           KEY `idx_adm_college_province` (`COLLEGE_ID`, `PROVINCE`),
                                           KEY `idx_adm_major` (`MAJOR_ID`),
                                           CONSTRAINT `fk_adm_college` FOREIGN KEY (`COLLEGE_ID`) REFERENCES `college_info`(`COLLEGE_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
                                           CONSTRAINT `fk_adm_major` FOREIGN KEY (`MAJOR_ID`) REFERENCES `major_info`(`MAJOR_ID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='历年录取分数线表';


INSERT INTO `college_admission_score` (`COLLEGE_ID`, `MAJOR_ID`, `PROVINCE`, `ADMISSION_YEAR`, `MIN_SCORE`, `MIN_RANK`, `ENROLLMENT_COUNT`)
VALUES
    (1, 1, '北京', 2024, 678.5, 12, 30),
    (1, 2, '北京', 2024, 670.0, 48, 25),
    (2, 1, '北京', 2024, 676.0, 20, 28);


-- 4) 院校招生计划表：college_plan

DROP TABLE IF EXISTS `college_plan`;
CREATE TABLE `college_plan` (
                                `PLAN_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '计划ID，主键',
                                `COLLEGE_ID` BIGINT DEFAULT NULL COMMENT '院校ID，关联 college_info',
                                `MAJOR_ID` BIGINT DEFAULT NULL COMMENT '专业ID，关联 major_info',
                                `PROVINCE` VARCHAR(64) NOT NULL COMMENT '招生省份',
                                `ADMISSION_YEAR` YEAR NOT NULL COMMENT '招生年份',
                                `PLAN_COUNT` INT NOT NULL COMMENT '招生计划数',
                                `DESCRIPTION` VARCHAR(255) DEFAULT NULL COMMENT '备注说明（管理员补充信息）',
                                PRIMARY KEY (`PLAN_ID`),
                                KEY `idx_plan_college_year` (`COLLEGE_ID`, `ADMISSION_YEAR`),
                                KEY `idx_plan_major` (`MAJOR_ID`),
                                CONSTRAINT `fk_plan_college` FOREIGN KEY (`COLLEGE_ID`) REFERENCES `college_info`(`COLLEGE_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
                                CONSTRAINT `fk_plan_major` FOREIGN KEY (`MAJOR_ID`) REFERENCES `major_info`(`MAJOR_ID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='院校招生计划表';


INSERT INTO `college_plan` (`COLLEGE_ID`, `MAJOR_ID`, `PROVINCE`, `ADMISSION_YEAR`, `PLAN_COUNT`, `DESCRIPTION`)
VALUES
    (1, 1, '北京', 2025, 30, '2025 年本科普通批次计划'),
    (1, 2, '北京', 2025, 25, '软件方向计划'),
    (2, 1, '北京', 2025, 28, '理工专业计划');


-- 5) 高中升学表：school_enrollment
--    （注：示例仅演示单个高中的升学记录）

DROP TABLE IF EXISTS `school_enrollment`;
CREATE TABLE `school_enrollment` (
                                     `SCHOOL_ENROLLMENT_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '高中升学ID，主键',
                                     `COLLEGE_ID` BIGINT DEFAULT NULL COMMENT '被录取院校ID（college_info）',
                                     `GRADUATION_YEAR` YEAR NOT NULL COMMENT '毕业年份',
                                     `MAJOR_ID` BIGINT DEFAULT NULL COMMENT '录取专业ID（major_info）',
                                     `ADMISSION_COUNT` INT NOT NULL COMMENT '录取人数',
                                     `AVG_SCORE` DECIMAL(5,1) DEFAULT NULL COMMENT '本校该批次最低分或均分（根据实际语义）',
                                     `MIN_RANK` INT DEFAULT NULL COMMENT '最低位次',
                                     PRIMARY KEY (`SCHOOL_ENROLLMENT_ID`),
                                     KEY `idx_school_graduation` (`GRADUATION_YEAR`),
                                     KEY `idx_school_college` (`COLLEGE_ID`),
                                     CONSTRAINT `fk_school_college` FOREIGN KEY (`COLLEGE_ID`) REFERENCES `college_info`(`COLLEGE_ID`) ON DELETE SET NULL ON UPDATE CASCADE,
                                     CONSTRAINT `fk_school_major` FOREIGN KEY (`MAJOR_ID`) REFERENCES `major_info`(`MAJOR_ID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='高中升学记录表（按高中分为多个记录表时可扩展）';


INSERT INTO `school_enrollment` (`COLLEGE_ID`, `GRADUATION_YEAR`, `MAJOR_ID`, `ADMISSION_COUNT`, `AVG_SCORE`, `MIN_RANK`)
VALUES
    (1, 2024, 1, 3, 695.5, 1),
    (1, 2024, 2, 2, 688.0, 4);


-- 6) 用户信息表：users

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
                         `USER_ID` BIGINT NOT NULL COMMENT '用户ID（学号或系统分配）',
                         `USERNAME` VARCHAR(50) NOT NULL COMMENT '用户名（5-20字符，字母数字）',
                         `PASSWORD` VARCHAR(255) NOT NULL COMMENT '密码哈希（请存储 bcrypt 等哈希）',
                         `STATUS` TINYINT NOT NULL DEFAULT 1 COMMENT '账户状态（1-正常，0-禁用）',
                         `GENDER` TINYINT DEFAULT NULL COMMENT '性别（1-男，2-女）',
                         `PROVINCE` VARCHAR(64) DEFAULT NULL COMMENT '考生所在省份',
                         `SCHOOL_ID` BIGINT DEFAULT NULL COMMENT '所在高中ID（若有高中表则可外键）',
                         `CREATED_AT` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         PRIMARY KEY (`USER_ID`),
                         UNIQUE KEY `ux_users_username` (`USERNAME`),
                         KEY `idx_users_province` (`PROVINCE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户信息表';


INSERT INTO `users` (`USER_ID`, `USERNAME`, `PASSWORD`, `STATUS`, `GENDER`, `PROVINCE`, `SCHOOL_ID`)
VALUES
    (202500001, 'cosmo', '$2b$10$EXAMPLEHASHEDPASSWORD', 1, 1, '北京', NULL),
    (202500002, 'alice', '$2b$10$EXAMPLEHASHEDPASSWORD2', 1, 2, '上海', NULL);


-- 7) 考生成绩信息表：student_score

DROP TABLE IF EXISTS `student_score`;
CREATE TABLE `student_score` (
                                 `SCORE_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '成绩ID，主键',
                                 `STUDENT_ID` BIGINT DEFAULT NULL COMMENT '考生ID（关联 users.USER_ID）',
                                 `EXAM_YEAR` YEAR NOT NULL COMMENT '高考年份',
                                 `PROVINCE` VARCHAR(64) NOT NULL COMMENT '考生所在省份',
                                 `TOTAL_SCORE` DECIMAL(5,1) NOT NULL COMMENT '高考总成绩',
                                 `RANK_IN_PROVINCE` INT DEFAULT NULL COMMENT '省内排名',
                                 `CREATED_AT` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交/记录时间',
                                 PRIMARY KEY (`SCORE_ID`),
                                 KEY `idx_score_student_year` (`STUDENT_ID`, `EXAM_YEAR`),
                                 KEY `idx_score_province` (`PROVINCE`),
                                 CONSTRAINT `fk_score_student` FOREIGN KEY (`STUDENT_ID`) REFERENCES `users`(`USER_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='考生成绩信息表';


INSERT INTO `student_score` (`STUDENT_ID`, `EXAM_YEAR`, `PROVINCE`, `TOTAL_SCORE`, `RANK_IN_PROVINCE`)
VALUES
    (202500001, 2025, '北京', 682.5, 7),
    (202500002, 2025, '上海', 655.0, 120);
