-- School LMS Database Schema
-- Corrected version with improvements and fixes

-- Users Table (for authentication)

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'teacher', 'parent', 'worker', 'admin') NOT NULL,
    linked_id INT NULL, -- nullable for flexibility
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL DEFAULT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Students Table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    admission_number VARCHAR(50) UNIQUE NOT NULL,
    age INT NOT NULL,
    grade VARCHAR(10) NOT NULL,
    subjects JSON, -- Changed to JSON for structured data
    health_records TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_admission (admission_number),
    INDEX idx_grade (grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Teachers Table
CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    tsc_number VARCHAR(50) UNIQUE NOT NULL,
    subjects_teaching JSON NOT NULL, -- Changed to JSON
    position VARCHAR(50) NOT NULL,
    groups JSON, -- Changed to JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tsc (tsc_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Parents Table
CREATE TABLE parents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NULL, -- Made nullable
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Workers Table
CREATE TABLE workers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    worker_role VARCHAR(50) NOT NULL, -- Renamed from role
    id_number VARCHAR(50) UNIQUE NOT NULL,
    amount_paid DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_id_number (id_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exam Results Table
CREATE TABLE exam_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    marks DECIMAL(5,2) NOT NULL,
    term VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    INDEX idx_student_subject (student_id, subject)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Homework Results Table
CREATE TABLE homework_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    assignment_title VARCHAR(255) NOT NULL,
    marks DECIMAL(5,2) NOT NULL,
    submitted_date DATE NOT NULL,
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    INDEX idx_student_assignment (student_id, assignment_title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Attendance Table
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('present', 'absent', 'late', 'excused') NOT NULL,
    recorded_by INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by) REFERENCES teachers(id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, date),
    INDEX idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- School Fees Table
CREATE TABLE school_fees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    term VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    amount_paid DECIMAL(10,2) DEFAULT 0.00,
    payment_date DATE NULL,
    status ENUM('pending', 'partial', 'paid') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    INDEX idx_student_term (student_id, term, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Transport Table
CREATE TABLE transport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    parent_phone VARCHAR(20) NOT NULL,
    area_living VARCHAR(100) NOT NULL,
    time_left_school DATETIME NULL,
    time_alighted_bus DATETIME NULL,
    driver_name VARCHAR(100) NOT NULL,
    car_registration VARCHAR(50) NOT NULL,
    teacher_incharge VARCHAR(100) NOT NULL,
    transport_fee_paid BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    INDEX idx_student_transport (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Appointments Table
CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NOT NULL,
    teacher_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    purpose TEXT NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES parents(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_datetime (appointment_datetime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assignments Table
CREATE TABLE assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    due_date DATETIME NOT NULL,
    max_marks DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_subject_due (subject, due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assignment Submissions Table
CREATE TABLE assignment_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    submission_text TEXT,
    submission_file VARCHAR(255),
    marks DECIMAL(5,2) NULL,
    feedback TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('submitted', 'graded', 'late') DEFAULT 'submitted',
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY unique_submission (assignment_id, student_id),
    INDEX idx_assignment_student (assignment_id, student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Polls Table
CREATE TABLE polls (
    id INT AUTO_INCREMENT PRIMARY KEY,
    created_by INT NOT NULL,
    question TEXT NOT NULL,
    options JSON NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Poll Votes Table
CREATE TABLE poll_votes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    poll_id INT NOT NULL,
    student_id INT NOT NULL,
    option_chosen VARCHAR(255) NOT NULL,
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY unique_vote (poll_id, student_id),
    INDEX idx_poll_student (poll_id, student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Questions Table (for Q&A sessions)
CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_id INT NOT NULL,
    question TEXT NOT NULL,
    correct_answer TEXT NOT NULL,
    points INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_active_question (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Answers Table
CREATE TABLE answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    student_id INT NOT NULL,
    answer TEXT NOT NULL,
    points_awarded INT DEFAULT 0,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY unique_answer (question_id, student_id),
    INDEX idx_question_student (question_id, student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tenders Table
CREATE TABLE tenders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    quantity INT NOT NULL,
    expected_delivery_date DATE NOT NULL,
    date_delivered DATE NULL,
    amount_paid DECIMAL(10,2) NULL,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_id VARCHAR(50) NOT NULL,
    supplier_phone VARCHAR(20) NOT NULL,
    status ENUM('open', 'awarded', 'delivered', 'paid') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Live Sessions Table
CREATE TABLE live_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructor_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    session_code VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('scheduled', 'ongoing', 'completed', 'cancelled') DEFAULT 'scheduled',
    recording_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_session_time (start_time, end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Chat Messages Table
CREATE TABLE chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    message_type ENUM('text', 'link', 'file') DEFAULT 'text',
    content TEXT NOT NULL,
    metadata JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES live_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_messages (session_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Calendar Events Table
CREATE TABLE calendar_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type ENUM('class', 'exam', 'meeting', 'holiday', 'event') NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    created_by INT NOT NULL,
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_event_time (start_time, end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Event Participants Table
CREATE TABLE event_participants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('attendee', 'organizer', 'speaker') DEFAULT 'attendee',
    FOREIGN KEY (event_id) REFERENCES calendar_events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_participation (event_id, user_id),
    INDEX idx_user_events (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;