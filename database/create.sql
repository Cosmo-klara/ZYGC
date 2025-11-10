SHOW DATABASES ;

-- 自己先建库哦，这里我是用的本机的
USE `Manager`;

DROP TABLE IF EXISTS `student_score`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `school_enrollment`;
DROP TABLE IF EXISTS `college_plan`;
DROP TABLE IF EXISTS `college_admission_score`;
DROP TABLE IF EXISTS `major_info`;
DROP TABLE IF EXISTS `college_info`;

CREATE TABLE `college_info` (
                                `COLLEGE_CODE` INT NOT NULL COMMENT '院校编码（主键，例如 10001）',
                                `COLLEGE_NAME` VARCHAR(100) NOT NULL COMMENT '院校名称',
                                `IS_985` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否 985（0/1）',
                                `IS_211` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否 211（0/1）',
                                `IS_DFC` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否双一流（0/1）',
                                `PROVINCE` VARCHAR(48) NOT NULL COMMENT '所在省份',
                                `CITY_NAME` VARCHAR(50) DEFAULT NULL COMMENT '所在城市',
                                `BASE_INTRO` TEXT DEFAULT NULL COMMENT '院校基础介绍',
                                PRIMARY KEY (`COLLEGE_CODE`),
                                KEY `idx_college_province` (`PROVINCE`),
                                KEY `idx_college_name` (`COLLEGE_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
    COMMENT='院校基础信息表（COLLEGE_CODE 为业务编码主键）';

ALTER TABLE `college_info`
    ADD CONSTRAINT chk_college_is_flags CHECK (IS_985 IN (0,1) AND IS_211 IN (0,1) AND IS_DFC IN (0,1));


CREATE TABLE `major_info` (
                              `MAJOR_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '专业ID，主键',
                              `MAJOR_NAME` VARCHAR(100) NOT NULL COMMENT '专业名称',
                              `MAJOR_TYPE` VARCHAR(20) DEFAULT NULL COMMENT '专业类型（综合、理工等）',
                              `BASE_INTRO` TEXT DEFAULT NULL COMMENT '专业基础介绍',
                              PRIMARY KEY (`MAJOR_ID`),
                              UNIQUE KEY `ux_major_name` (`MAJOR_NAME`),
                              KEY `idx_major_type` (`MAJOR_TYPE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='专业信息表';

CREATE TABLE `college_admission_score` (
                                          `ADMISSION_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '录取分数线ID，主键',
                                          `COLLEGE_CODE` INT NOT NULL COMMENT '院校编码（关联 college_info.COLLEGE_CODE）',
                                          `TYPE` VARCHAR(20) DEFAULT NULL COMMENT '科类（文/理）',
                                          `MAJOR_NAME` VARCHAR(100) DEFAULT NULL COMMENT '专业名称（字符串形式，便于历史兼容）',
                                          `PROVINCE` VARCHAR(48) NOT NULL COMMENT '录取省份',
                                          `ADMISSION_YEAR` YEAR NOT NULL COMMENT '录取年份',
                                          `MIN_SCORE` DECIMAL(3,0) NOT NULL COMMENT '最低分（整数）',
                                          `MIN_RANK` BIGINT NOT NULL COMMENT '最低位次',
                                          PRIMARY KEY (`ADMISSION_ID`),
                                          KEY `idx_adm_college_year` (`COLLEGE_CODE`, `ADMISSION_YEAR`),
                                          KEY `idx_adm_province_year` (`PROVINCE`, `ADMISSION_YEAR`),
                                          CONSTRAINT `fk_adm_college_code` FOREIGN KEY (`COLLEGE_CODE`) REFERENCES `college_info`(`COLLEGE_CODE`)
                                              ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='历年录取分数线（按院校/省份/年份维度）';


CREATE TABLE `college_plan` (
                                `PLAN_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '计划ID，主键',
                                `COLLEGE_CODE` INT DEFAULT NULL COMMENT '院校编码（关联 college_info.COLLEGE_CODE）',
                                `MAJOR_ID` BIGINT DEFAULT NULL COMMENT '专业ID（关联 major_info.MAJOR_ID）',
                                `PROVINCE` VARCHAR(48) NOT NULL COMMENT '招生省份',
                                `ADMISSION_YEAR` YEAR NOT NULL COMMENT '招生年份',
                                `PLAN_COUNT` INT NOT NULL COMMENT '招生计划数',
                                `DESCRIPTION` VARCHAR(255) DEFAULT NULL COMMENT '备注说明',
                                PRIMARY KEY (`PLAN_ID`),
                                KEY `idx_plan_college_year` (`COLLEGE_CODE`, `ADMISSION_YEAR`),
                                KEY `idx_plan_major` (`MAJOR_ID`),
                                CONSTRAINT `fk_plan_college_code` FOREIGN KEY (`COLLEGE_CODE`) REFERENCES `college_info`(`COLLEGE_CODE`)
                                    ON DELETE SET NULL ON UPDATE CASCADE,
                                CONSTRAINT `fk_plan_major` FOREIGN KEY (`MAJOR_ID`) REFERENCES `major_info`(`MAJOR_ID`)
                                    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='院校招生计划（模拟数据）';


CREATE TABLE `school_enrollment` (
                                    `SCHOOL_ENROLLMENT_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '高中升学ID，主键',
                                    `COLLEGE_NAME` VARCHAR(100) DEFAULT NULL COMMENT '被录取院校名称（字符串，便于演示）',
                                    `GRADUATION_YEAR` YEAR NOT NULL COMMENT '毕业年份',
                                    `ADMISSION_COUNT` INT NOT NULL COMMENT '录取人数',
                                    `MIN_SCORE` DECIMAL(3,0) DEFAULT NULL COMMENT '最低分（整数）',
                                    `MIN_RANK` BIGINT DEFAULT NULL COMMENT '最低位次',
                                    PRIMARY KEY (`SCHOOL_ENROLLMENT_ID`),
                                    KEY `idx_school_grad_year` (`GRADUATION_YEAR`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='高中升学记录（模拟）';

CREATE TABLE `users` (
                        `USER_ID` BIGINT NOT NULL COMMENT '用户ID（学号或系统ID）',
                        `USERNAME` VARCHAR(20) NOT NULL COMMENT '用户名（5-20字符）',
                        `PASSWORD` VARCHAR(255) NOT NULL COMMENT '密码哈希（请存储 bcrypt/hash）',
                        `STATUS` TINYINT NOT NULL DEFAULT 1 COMMENT '账户状态（1-正常，0-禁用）',
                        `GENDER` TINYINT DEFAULT NULL COMMENT '性别（1-男，2-女）',
                        `PROVINCE` VARCHAR(48) NOT NULL COMMENT '考生所在省份',
                        `SCHOOL_NAME` VARCHAR(100) NOT NULL COMMENT '所在高中名称（文本）',
                        `CREATED_AT` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                        PRIMARY KEY (`USER_ID`),
                        UNIQUE KEY `ux_users_username` (`USERNAME`),
                        KEY `idx_users_province` (`PROVINCE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户信息表（存高中名称）';


CREATE TABLE `student_score` (
                                `SCORE_ID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '成绩ID，主键',
                                `STUDENT_ID` BIGINT NOT NULL COMMENT '考生ID（关联 users.USER_ID）',
                                `EXAM_YEAR` YEAR NOT NULL COMMENT '高考年份',
                                `PROVINCE` VARCHAR(48) NOT NULL COMMENT '考生所在省份',
                                `TOTAL_SCORE` DECIMAL(3,0) NOT NULL COMMENT '高考总成绩（整数）',
                                `RANK_IN_PROVINCE` BIGINT DEFAULT NULL COMMENT '省内排名',
                                `CREATED_AT` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
                                PRIMARY KEY (`SCORE_ID`),
                                KEY `idx_score_student_year` (`STUDENT_ID`, `EXAM_YEAR`),
                                KEY `idx_score_province` (`PROVINCE`),
                                CONSTRAINT `fk_score_student` FOREIGN KEY (`STUDENT_ID`) REFERENCES `users`(`USER_ID`)
                                    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='考生成绩表';

ALTER TABLE `college_admission_score`
    ADD INDEX `idx_adm_college_province_year` (`COLLEGE_CODE`, `PROVINCE`, `ADMISSION_YEAR`);

