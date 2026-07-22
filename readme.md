# ACAASO TeacherAssessment

![TeacherAssessment Banner](static/img/banner_enviar3.png)

**AI-Powered Assessment Platform for Educational Institutions**

TeacherAssessment is a production-ready multi-tenant assessment platform that enables schools, universities, and training organizations to create, manage, distribute, and evaluate assessments using Artificial Intelligence.

The platform combines AI-assisted assessment generation, institution management, classroom administration, automated grading, and learning analytics into a single solution for managing the complete assessment lifecycle.
---

## 🏛️ Architecture Overview

TeacherAssessment follows a multi-tenant architecture where each educational institution operates independently while sharing the same platform.

```text
                           ROOT
                             │
          ┌──────────────────┴──────────────────┐
          │                                     │
     Institution A                        Institution B
          │                                     │
      Administrators                    Administrators  
          │                                     │
   ┌──────┴────────┐                   ┌────────┴────────┐
   │               │                   │                 │
Professor A   Professor B         Professor A     Professor B
     │              │                   │               │
 Assessments   Assessments        Assessments    Assessments
     │              │                   │               │
     └──────┬───────┘                   └──────┬────────┘
            │                                  │
         Students                         Students
```

Each Institution Administrator manages multiple professors. Each professor manages their own classrooms, students, quizzes, and assessment results. Institutions remain completely isolated from one another.

## Current Platform Modules

- AI Assessment Generation
- Quiz Management
- Student Management
- Classroom Management
- Institution Management
- Email Notification System
- Assessment Configuration
- Automatic Grading
- Results & Analytics
- Student Achievement Dashboard
- Platform Monitoring & Database Analytics


-----
## User Roles

The platform supports multiple user roles with different permissions.

### Root Administrator

The Root Administrator has complete control over the platform.

Responsibilities include:

- Platform administration
- Institution management
- Global configuration
- Access to all organizations
- Database usage monitoring
- Platform health statistics
- Storage utilization reports
- Global system analytics
- Subscription plan administration
 


### Institution Administrator

Each institution can have one or more administrators.

Administrators can:

- Create professors
- Manage classrooms
- Manage students
- Access all quizzes created by professors within their institution
- Review institution-wide statistics
- Manage institution configuration

### Professor

Professors can:

- Generate quizzes using AI
- Generate quizzes from uploaded documents
- Create quizzes manually
- Edit AI-generated quizzes
- Manage classrooms
- Select participants
- Send quiz invitations by email
- Configure assessment options
- Review results and statistics

Professors cannot modify or manage assessments created by other professors unless explicitly authorized by the Institution Administrator.

### Student

Students have access to:

- Assigned assessments
- Personal dashboard
- Assessment history
- Individual achievements
- Performance tracking

## 🚀 Live Demo

https://acaaso-teacherassesment.onrender.com/

Demo Account

Username:  judge 

Password:  judge1234 

> Note: The application is hosted on Render. If it has been inactive, the first request may take 30–60 seconds while the service starts.

---

## Features

### 🤖 AI Quiz Generation

Generate quizzes from:

- Natural language prompts
- Uploaded documents (PDF, DOCX, TXT)
- Manual quiz creation
- AI-assisted question generation and editing

---

### Upcoming Feature – SQL Studio

SQL Studio is an advanced administrative reporting module currently under development.

It allows administrators to build, organize, and execute reusable SQL queries directly from the application, providing instant access to custom reports without requiring direct database access.

Planned capabilities include:

Save reusable SQL queries
Organize queries by category
Execute queries safely from the interface
Display tabular results
Export reports
Manage shared institutional reports

---
### 🏫 Institution Management

- Multi-tenant architecture
- Institution isolation
- Role-based permissions
- Institution Administrator dashboard
- Professor management
- Student management
- Classroom management

---

### 📝 Quiz Management

- Manual question editor
- Multiple question types
- True/False questions
- Automatic answer generation
- Question explanations
- AI-generated question editing
- Quiz publishing and management

---

### 👨‍🏫 Assessment Delivery

- Participant selection
- Email invitations
- Secure access by invitation code
- Direct access link
- QR code access

---

### ⏱ Assessment Configuration

- Time limits
- Multiple attempts
- Automatic grading
- Option to send the answer key after completion
- PDF answer key generation
- Assessment configuration options

---

### 📊 Results & Analytics

 
- Individual results
- Quiz review
- Institution statistics
- Professor statistics
- Student achievements
- Average scores
- Performance reports
- Export results to Excel

---

### 📈 Platform Monitoring

Available for Root Administrators:

- Database usage monitoring
- Storage statistics
- Table size analysis
- Record count reports
- Platform utilization dashboards
---

## Technology Stack

- Python
- Flask
- PostgreSQL
- HTML5
- Bootstrap
- JavaScript
- Jinja2
- OpenAI API
- OpenAI Codex
- GPT-5.6
- GitHub
- Render

---

## How GPT-5.6 and Codex were used

GPT-5.6 and Codex served as AI engineering assistants throughout the development of TeacherAssessment. They accelerated ideation, software architecture, feature design, debugging, database optimization, UI refinement, and rapid iteration. AI enhanced the development process, while all product decisions, business logic, software architecture, and final implementations remained under full developer control.

They helped with:

- Feature design
- Python development
- Flask architecture
- SQL query optimization
- PostgreSQL integration
- JavaScript implementation
- HTML/CSS improvements
- Bug investigation
- Code refactoring
- Performance improvements
- User interface design

The project was designed, implemented, tested, and continuously improved with AI assistance while all architectural and product decisions remained under developer control.

---
## Why TeacherAssessment?

Unlike tools that only generate questions, TeacherAssessment manages the complete assessment lifecycle.

From AI-powered quiz generation to classroom management, student selection, secure quiz distribution, automatic grading, and performance analysis, the platform provides teachers with a complete solution for digital assessments.

The goal is not only to generate assessments, but to provide educational institutions with a complete platform for managing the entire assessment process.

----
## Future Improvements

TeacherAssessment is already a functional platform, and future releases will focus on enhancing assessment quality, analytics, and the overall learning experience.

Planned features include:

- **Advanced Question Banks:** Create large repositories of questions organized by topic, allowing the system to generate different exams that assess the same learning objectives for an entire classroom.

- **Advanced Time Analytics:** Measure the time spent on each question and provide detailed reports to help teachers identify difficult questions and better understand student behavior during assessments.

- **Interactive Dashboards:** Add graphical analytics for teachers and administrators, including performance trends, completion rates, question difficulty, and time distribution per question.

- **Assessment Power-Ups ("Jokers"):** Introduce optional learning aids that teachers can enable, such as hints, second chances, or other configurable assessment features.

- **AI Learning Recommendations:** Use student performance data to recommend reinforcement topics, personalized study plans, and targeted practice quizzes.

- **Expanded Integrations:** Integrate with Learning Management Systems (LMS) and additional educational platforms.

- **Teacher-configurable grading strategies (best score, latest attempt, or custom policies)

- **Mobile Experience:** Develop a dedicated mobile application for teachers and students.

- **Adaptive Assessments:** Generate different follow-up questions in future quizzes based on each student's previous performance and learning progress.

- ****Subscription Enforcement:** Automatically enforce plan limits such as the maximum number of administrators, professors, students, quizzes, and subscription expiration dates.


----
## Repository

https://github.com/pardonAlf/Acaaso-TeacherAssesment

---

## Live Demo

https://acaaso-teacherassesment.onrender.com/