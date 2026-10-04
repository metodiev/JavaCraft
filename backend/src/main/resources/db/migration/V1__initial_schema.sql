CREATE TABLE app_user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(80) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_app_user_email UNIQUE (email)
);

CREATE TABLE app_role (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE user_role (
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES app_role(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE learning_path (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(100) NOT NULL UNIQUE,
    title VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    published BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE tutorial (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(120) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    level VARCHAR(40) NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    published BOOLEAN NOT NULL DEFAULT false,
    version INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tutorial_section (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tutorial_id UUID NOT NULL REFERENCES tutorial(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    body_markdown TEXT NOT NULL,
    starter_code TEXT,
    sort_order INTEGER NOT NULL,
    UNIQUE (tutorial_id, sort_order)
);

CREATE TABLE skill (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE skill_prerequisite (
    skill_id UUID NOT NULL REFERENCES skill(id) ON DELETE CASCADE,
    prerequisite_skill_id UUID NOT NULL REFERENCES skill(id) ON DELETE CASCADE,
    PRIMARY KEY (skill_id, prerequisite_skill_id),
    CHECK (skill_id <> prerequisite_skill_id)
);

CREATE TABLE learning_path_tutorial (
    learning_path_id UUID NOT NULL REFERENCES learning_path(id) ON DELETE CASCADE,
    tutorial_id UUID NOT NULL REFERENCES tutorial(id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL,
    PRIMARY KEY (learning_path_id, tutorial_id),
    UNIQUE (learning_path_id, sort_order)
);

CREATE TABLE challenge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(120) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    level VARCHAR(40) NOT NULL,
    difficulty VARCHAR(40) NOT NULL,
    category VARCHAR(100) NOT NULL,
    starter_repository JSONB NOT NULL DEFAULT '{}'::jsonb,
    time_limit_seconds INTEGER NOT NULL DEFAULT 10 CHECK (time_limit_seconds > 0),
    memory_limit_mb INTEGER NOT NULL DEFAULT 256 CHECK (memory_limit_mb > 0),
    published BOOLEAN NOT NULL DEFAULT false,
    version INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE challenge_skill (
    challenge_id UUID NOT NULL REFERENCES challenge(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skill(id) ON DELETE CASCADE,
    PRIMARY KEY (challenge_id, skill_id)
);

CREATE TABLE challenge_test (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenge(id) ON DELETE CASCADE,
    visibility VARCHAR(10) NOT NULL CHECK (visibility IN ('PUBLIC', 'HIDDEN')),
    source_bundle BYTEA NOT NULL,
    sort_order INTEGER NOT NULL,
    UNIQUE (challenge_id, visibility, sort_order)
);

CREATE TABLE hint (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenge(id) ON DELETE CASCADE,
    level SMALLINT NOT NULL CHECK (level BETWEEN 1 AND 5),
    body_markdown TEXT NOT NULL,
    UNIQUE (challenge_id, level)
);

CREATE TABLE project (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(120) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    published BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE project_stage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES project(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    level VARCHAR(40) NOT NULL,
    instructions JSONB NOT NULL DEFAULT '{}'::jsonb,
    sort_order INTEGER NOT NULL,
    UNIQUE (project_id, sort_order)
);

CREATE TABLE achievement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(100) NOT NULL UNIQUE,
    title VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    criteria JSONB NOT NULL
);

CREATE TABLE submission (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(id),
    challenge_id UUID NOT NULL REFERENCES challenge(id),
    challenge_version INTEGER NOT NULL CHECK (challenge_version > 0),
    source_bundle BYTEA NOT NULL,
    idempotency_key VARCHAR(128) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, idempotency_key)
);

CREATE INDEX idx_submission_user_created ON submission(user_id, created_at DESC);

CREATE TABLE execution (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id UUID NOT NULL UNIQUE REFERENCES submission(id) ON DELETE CASCADE,
    state VARCHAR(30) NOT NULL CHECK (state IN (
        'QUEUED', 'RUNNING', 'PASSED', 'FAILED', 'TIMED_OUT',
        'RESOURCE_LIMITED', 'INFRASTRUCTURE_ERROR'
    )),
    queued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_ms BIGINT CHECK (duration_ms IS NULL OR duration_ms >= 0),
    peak_memory_bytes BIGINT CHECK (peak_memory_bytes IS NULL OR peak_memory_bytes >= 0),
    output_truncated BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX idx_execution_queue ON execution(state, queued_at);

CREATE TABLE execution_result (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    execution_id UUID NOT NULL REFERENCES execution(id) ON DELETE CASCADE,
    visibility VARCHAR(10) NOT NULL CHECK (visibility IN ('PUBLIC', 'HIDDEN')),
    passed_count INTEGER NOT NULL CHECK (passed_count >= 0),
    total_count INTEGER NOT NULL CHECK (total_count >= passed_count),
    sanitized_summary TEXT,
    UNIQUE (execution_id, visibility)
);

CREATE TABLE user_skill (
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skill(id) ON DELETE CASCADE,
    proficiency SMALLINT NOT NULL DEFAULT 0 CHECK (proficiency BETWEEN 0 AND 100),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, skill_id)
);

CREATE TABLE progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    learning_path_id UUID NOT NULL REFERENCES learning_path(id) ON DELETE CASCADE,
    tutorial_id UUID REFERENCES tutorial(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED')),
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, learning_path_id, tutorial_id)
);

CREATE TABLE user_achievement (
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievement(id) ON DELETE CASCADE,
    awarded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE code_review (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id UUID NOT NULL REFERENCES submission(id) ON DELETE CASCADE,
    reviewer_type VARCHAR(20) NOT NULL CHECK (reviewer_type IN ('AI', 'HUMAN')),
    feedback JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE architecture_decision (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    project_stage_id UUID REFERENCES project_stage(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    context TEXT NOT NULL,
    decision TEXT NOT NULL,
    consequences TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    token_hash BYTEA NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_session_active ON user_session(user_id, expires_at)
    WHERE revoked_at IS NULL;
